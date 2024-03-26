# @summary Optionally create the jenkins user and make sure all directories
#   have proper permissions setup.
#
# By having this in a separate class that is managed before
# installing the package, we can effectivly override the
# default local dir that is otherwise possibly created by
# the package.
#
# @api private
class jenkins::user_setup {
  assert_private()

  $dir_params = {
    ensure => directory,
    owner  => $jenkins::user,
    group  => $jenkins::group,
    mode   => '0755',
  }

  # ensure_resource is used to try to maintain backwards compatiblity with
  # manifests that were able to external declare resources due to the
  # old conditional behavior of jenkins::plugin
  if $jenkins::manage_user {
    ensure_resource('user', $jenkins::user, {
        ensure     => present,
        gid        => $jenkins::group,
        home       => $jenkins::localstatedir,
        managehome => false,
        system     => true,
    })
  }

  if $jenkins::manage_group {
    ensure_resource('group', $jenkins::group, {
        ensure => present,
        system => true,
    })
  }

  $plugin_dir_params = $jenkins::purge_plugins ? {
    true    => $dir_params + {
      'purge'   => true,
      'recurse' => true,
      'force'   => true,
      'notify'  => Service['jenkins'],
    },
    default => $dir_params,
  }

  if $jenkins::manage_datadirs {
    ensure_resource('file', $jenkins::localstatedir, $dir_params)
    ensure_resource('file', $jenkins::plugin_dir, $plugin_dir_params)
    ensure_resource('file', $jenkins::job_dir, $dir_params)
  }

  # On Debian the service is started by default so it must be configured prior
  # to installation which is why it's configured in this file rather than config.pp
  $config_hash = $jenkins::params::config_hash_defaults + $jenkins::config_hash

  systemd::dropin_file { 'puppet-overrides.conf':
    unit           => 'jenkins.service',
    content        => epp("${module_name}/jenkins-override.epp", { 'environment' => $config_hash, 'dropin_config' => $jenkins::service_override }),
    notify_service => true,
  }
}
