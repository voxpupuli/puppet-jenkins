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
define jenkins::plugin(
  $version         = 0,
  $manage_config   = false,
  $config_filename = undef,
  $config_content  = undef,
  $update_url      = undef,
  $plugin_dir      = '/var/lib/jenkins/plugins',
  $username        = 'jenkins',
  $group           = 'jenkins',
  $enabled         = true,
  $create_user     = true,
  $source          = undef,
  $digest_string   = '',
  $digest_type     = 'sha1',
) {
  include ::jenkins::params

  $plugin_parent_dir = inline_template('<%= @plugin_dir.split(\'/\')[0..-2].join(\'/\') %>')
  validate_bool($manage_config)
  validate_bool($enabled)
  # TODO: validate_str($update_url)
  validate_string($source)
  validate_string($digest_string)
  validate_string($digest_type)

  if ($version != 0) {
    $plugins_host = $update_url ? {
      undef   => $::jenkins::params::default_plugins_host,
      default => $update_url,
    }
    $base_url = "${plugins_host}/download/plugins/${name}/${version}/"
    $search   = "${name} ${version}(,|$)"
  }
  else {
    $plugins_host = $update_url ? {
      undef   => $::jenkins::params::default_plugins_host,
      default => $update_url,
    }
    $base_url = "${plugins_host}/latest/"
    $search   = "${name} "
  }

  # if $source is specified, it overrides any other URL construction
  $download_url = $source ? {
    undef   => "${base_url}${name}.hpi",
    default => $source,
  }

  $plugin_ext = regsubst($download_url, '^.*\.(hpi|jpi)$', '\1')
  $plugin     = "${name}.${plugin_ext}"

  if (!defined(File[$plugin_dir])) {
    if (!defined(File[$plugin_parent_dir])) {
      # ensure ownership only when it's home directory for the new user
      if $create_user {
        file { $plugin_parent_dir:
          ensure => directory,
          owner  => $username,
          group  => $group,
          mode   => '0755',
        }
      } else {
        file { $plugin_parent_dir:
          ensure => directory,
        }
      }
    }

    file { $plugin_dir:
      ensure => directory,
      owner  => $username,
      group  => $group,
      mode   => '0755',
    }

  }

  if $create_user {
    if (!defined(Group[$group])) {
      group { $group :
        ensure  => present,
        require => Package[$::jenkins::package_name],
      }
    }
    if (!defined(User[$username])) {
      user { $username :
        ensure  => present,
        home    => $plugin_parent_dir,
        require => Package[$::jenkins::package_name],
      }
    }
    User[$username] -> File[$plugin_dir]
    Group[$group] -> File[$plugin_dir]
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
      owner   => $username,
      mode    => '0644',
      require => File["${plugin_dir}/${plugin}"],
      notify  => Service['jenkins'],
    }

    file { "${plugin_dir}/${plugin}.pinned":
      owner   => $username,
      require => Archive::Download[$plugin],
    }

    if $digest_string == '' {
      $checksum = false
    } else {
      $checksum = true
    }

    archive::download { $plugin:
      url              => $download_url,
      src_target       => $plugin_dir,
      allow_insecure   => true,
      follow_redirects => true,
      checksum         => $checksum,
      digest_string    => $digest_string,
      digest_type      => $digest_type,
      user             => $username,
      proxy_server     => $proxy_server,
      notify           => Service['jenkins'],
      require          => File[$plugin_dir],
    }

    file { "${plugin_dir}/${plugin}" :
      require => Archive::Download[$plugin],
      owner   => $username,
      mode    => '0644',
    }
  }

  if $manage_config {
    if $config_filename == undef or $config_content == undef {
      fail 'To deploy config file for plugin, you need to specify both $config_filename and $config_content'
    }

    file {"${plugin_parent_dir}/${config_filename}":
      ensure  => present,
      content => $config_content,
      owner   => $username,
      group   => $group,
      mode    => '0644',
      notify  => Service['jenkins']
    }
  }
}
