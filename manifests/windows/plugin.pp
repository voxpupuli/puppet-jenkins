#
# config_filename = undef
#   Name of the config file for this plugin.
#
# config_content = undef
#   Content of the config file for this plugin. It is up to the caller to
#   create this content from a template or any other mean.
#
# update_url = undef
#
# source = undef
#   Direct URL from which to download plugin without modification.  This is
#   particularly useful for development and testing of plugins which may not be
#   hosted in the typical Jenkins' plugin directory structure.  E.g.,
#
#   https://example.org/myplugin.hpi
#
define jenkins::windows::plugin(
  $version         = 0,
  $manage_config   = false,
  $config_filename = undef,
  $config_content  = undef,
  $update_url      = undef,
  $plugin_dir      = "${jenkins::params::libdir}/plugins",
  $username        = 'jenkins',
  $group           = 'jenkins',
  $enabled         = true,
  $create_user     = false,
  $source          = undef,
  $digest_string   = '',
  $digest_type     = 'sha1',
) {
  include ::jenkins::params
##Validation
  $plugin            = "${name}.hpi"
  $plugin_parent_dir = inline_template('<%= @plugin_dir.split(\'/\')[0..-2].join(\'/\') %>')
  validate_bool($manage_config)
  validate_bool($enabled)
  # TODO: validate_str($update_url)
  validate_string($source)
  validate_string($digest_string)
  validate_string($digest_type)

##if version isn't 0 set the plungins_host based on what the value of update_url is
  if ($version != 0) {
    $plugins_host = $update_url ? {
      undef   => $::jenkins::params::default_plugins_host,
      default => $update_url,
    }
    $base_url = "${plugins_host}/download/plugins/${name}/${version}/"
    $search   = "${name} ${version}(,|$)"
  }
##Else set to latest url
  else {
    $plugins_host = $update_url ? {
      undef   => $::jenkins::params::default_plugins_host,
      default => $update_url,
    }
    $base_url = "${plugins_host}/latest/"
    $search   = "${name} "
  }

 
  if (empty(grep([ $::jenkins_plugins ], $search))) {
    if ($jenkins::proxy_host) {
      $proxy_server = "${jenkins::proxy_host}:${jenkins::proxy_port}"
    } else {
      $proxy_server = undef
    }

    $enabled_ensure = $enabled ? {
      false   => present,
      default => absent,
    }

	
    # Allow plugins that are already installed to be enabled/disabled.
    file { "${plugin_dir}/${plugin}.disabled":
      ensure  => $enabled_ensure,
      require => File["${plugin_dir}/${plugin}"],
      notify  => Service['jenkins'],
    }

    # Create disabled file for jpi extensions too.
    file { "${plugin_dir}/${name}.jpi.disabled":
      ensure  => $enabled_ensure,
      require => File["${plugin_dir}/${plugin}"],
      notify  => Service['jenkins'],
    }

    # create a pinned file if the plugin has a .jpi extension
    #   to override the builtin module versions

      exec { "create-pinnedfile-${name}" :
        command  => "new-item -ItemType file '${plugin_dir}/${name}.jpi.pinned' -value '${version}'  -force ",
        cwd      => $plugin_dir,
        onlyif   => "if ((test-path '${plugin_dir}/${name}.jpi')  -and -not (test-path '${plugin_dir}/${name}.jpi.pinned')) {exit 0} else {exit 1}",
        before   => Pget["${plugin}"],
        #require => Exec['wait_for_plugindir'],
        provider => 'powershell'
      }
    

    # if $source is specified, it overrides any other URL construction
    $download_url = $source ? {
      undef   => "${base_url}${plugin}",
      default => $source,
    }

    if $digest_string == '' {
      $checksum = false
    } else {
      $checksum = true
    }
	 
    ##archive::download will not work on windows, replace with pget mod 
      pget { "${plugin}" :
        source => $download_url,
        target => "C:/windows/temp",
        notify => File["${plugin_dir}/${plugin}"],
      } 
      file { "${plugin_dir}/${plugin}" :
        require            => Pget["${plugin}"],
        source             => "C:/windows/temp/${plugin}",
        source_permissions => ignore,
        notify             => Service['jenkins'],
      }
  }

  if $manage_config {
    if $config_filename == undef or $config_content == undef {
      fail 'To deploy config file for plugin, you need to specify both $config_filename and $config_content'
    }

    file {"${plugin_parent_dir}/${config_filename}":
      ensure  => present,
      content => $config_content,
      notify  => Service['jenkins']
    }
  }
}
