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
  $version         = undef,
  $manage_config   = false,
  $config_filename = undef,
  $config_content  = undef,
  $update_url      = undef,
  $enabled         = true,
  $source          = undef,
  $digest_string   = undef,
  $digest_type     = 'sha1',
  $pin             = true,
  # no worky
  $timeout         = undef,
  # deprecated
  $plugin_dir      = undef,
  $username        = undef,
  $group           = undef,
  $create_user     = undef,
) {
  validate_string($version)
  validate_bool($manage_config)
  validate_string($config_filename)
  validate_string($config_content)
  validate_string($update_url)
  validate_bool($enabled)
  validate_string($source)
  validate_string($digest_string)
  validate_string($digest_type)
  validate_bool($pin)

  if $timeout {
    warning('jenkins::plugin::timeout presently has effect')
  }

  if $plugin_dir {
    warning('jenkins::plugin::plugin_dir is deprecated and has no effect -- see jenkins::localstatedir')
  }
  if $username {
    warning('jenkins::plugin::username is deprecated and has no effect -- see jenkins::user')
  }
  if $group {
    warning('jenkins::plugin::group is deprecated and has no effect -- see jenkins::group')
  }
  if $create_user {
    warning('jenkins::plugin::create_user is deprecated and has no effect')
  }

  include ::jenkins

  if $version {
    $plugins_host = $update_url ? {
      undef   => $::jenkins::default_plugins_host,
      default => $update_url,
    }
    $base_url = "${plugins_host}/download/plugins/${name}/${version}/"
    $search   = "^${name} ${version}$"
  }
  else {
    $plugins_host = $update_url ? {
      undef   => $::jenkins::default_plugins_host,
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
  # sanity check extension
  if ! $plugin_ext {
    fail("unsupported plugin extension in source url: ${download_url}")
  }

  $installed_plugins = $::jenkins_plugins ? {
    undef   => [],
    default => strip(split($::jenkins_plugins, ',')),
  }

  if (empty(grep($installed_plugins, $search))) {
    $enabled_ensure = $enabled ? {
      false   => present,
      default => absent,
    }

    # at least as of jenkins 1.651, if the version of a plugin being downloaded
    # has a .hpi extension, and there is an existing version of the plugin
    # present with a .jpi extension, jenkins will actually delete the .hpi
    # version when restarted. Essentially making it impossible to
    # (up|down)grade a plugin from .jpi -> .hpi via puppet across extension
    # changes.  Regardless, we should be relying on jenkins to guess which
    # plugin archive to use and cleanup any conflicting extensions.
    $inverse_plugin_ext = $plugin_ext ? {
      'hpi'   => 'jpi',
      'jpi'   => 'hpi',
    }
    $inverse_plugin     = "${name}.${inverse_plugin_ext}"

    file {[
      "${::jenkins::plugin_dir}/${inverse_plugin}",
      "${::jenkins::plugin_dir}/${inverse_plugin}.disabled",
      "${::jenkins::plugin_dir}/${inverse_plugin}.pinned",
    ]:
      ensure => absent,
      before => Archive[$plugin],
    }


    # Allow plugins that are already installed to be enabled/disabled.
    file { "${::jenkins::plugin_dir}/${plugin}.disabled":
      ensure  => $enabled_ensure,
      owner   => $::jenkins::user,
      group   => $::jenkins::group,
      mode    => '0644',
      require => Archive[$plugin],
      notify  => Service['jenkins'],
    }

    $pinned_ensure = $pin ? {
      true    => file,
      default => undef,
    }

    file { "${::jenkins::plugin_dir}/${plugin}.pinned":
      ensure  => $pinned_ensure,
      owner   => $::jenkins::user,
      group   => $::jenkins::group,
      require => Archive[$plugin],
      notify  => Service['jenkins'],
    }

    if $digest_string {
      $checksum_verify = true
      $checksum = $digest_string
    } else {
      $checksum_verify = false
      $checksum = undef
    }

    archive { $plugin:
      source          => $download_url,
      path            => "${::jenkins::plugin_dir}/${plugin}",
      checksum_verify => $checksum_verify,
      checksum        => $checksum,
      checksum_type   => $digest_type,
      proxy_server    => $::jenkins::proxy_server,
      cleanup         => false,
      extract         => false,
      require         => File[$::jenkins::plugin_dir],
      notify          => Service['jenkins'],
    }

    file { "${::jenkins::plugin_dir}/${plugin}" :
      owner   => $::jenkins::user,
      group   => $::jenkins::group,
      mode    => '0644',
      require => Archive[$plugin],
      before  => Service['jenkins'],
    }
  }

  if $manage_config {
    if $config_filename == undef or $config_content == undef {
      fail 'To deploy config file for plugin, you need to specify both $config_filename and $config_content'
    }

    file {"${::jenkins::localstatedir}/${config_filename}":
      ensure  => present,
      content => $config_content,
      owner   => $::jenkins::user,
      group   => $::jenkins::group,
      mode    => '0644',
      notify  => Service['jenkins']
    }
  }
}
