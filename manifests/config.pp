# This class should be considered private
#
class jenkins::config {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  ensure_resource('jenkins::plugin', $::jenkins::default_plugins)

  $config_hash = merge(
    $::jenkins::params::config_hash_defaults,
    $::jenkins::config_hash
  )
  create_resources('jenkins::sysconfig', $config_hash)

  $dir_params = {
    ensure => directory,
    owner  => $::jenkins::user,
    group  => $::jenkins::group,
    mode   => '0755',
  }

  # ensure_resource is used to try to maintain backwards compatiblity with
  # manifests that were able to external declare resources due to the
  # old conditional behavior of jenkins::plugin
  if $::jenkins::manage_user {
    ensure_resource('user', $::jenkins::user, {
      ensure     => present,
      gid        => $::jenkins::group,
      home       => $::jenkins::localstatedir,
      managehome => false,
      system     => true,
    })
  }

  if $::jenkins::manage_group {
    ensure_resource('group', $::jenkins::group, {
      ensure => present,
      system => true,
    })
  }

  $plugin_dir_params = $::jenkins::purge_plugins ? {
    true    => merge($dir_params, {
      purge   => true,
      recurse => true,
      force   => true,
      notify  => Service['jenkins'],
    }),
    default => $dir_params,
  }

  if $::jenkins::manage_datadirs {
    ensure_resource('file', $::jenkins::localstatedir, $dir_params)
    ensure_resource('file', $::jenkins::plugin_dir, $plugin_dir_params)
    ensure_resource('file', $::jenkins::job_dir, $dir_params)
  }
}
