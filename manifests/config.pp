# @summary Wire up the configuration
# @api private
class jenkins::config {
  assert_private()

  ensure_resource('jenkins::plugin', $jenkins::default_plugins)

  $config_hash = merge(
    $jenkins::params::config_hash_defaults,
    $jenkins::config_hash
  )

  systemd::dropin_file { 'puppet-overrides.conf':
    unit    => 'jenkins.service',
    content => epp("${module_name}/jenkins-override.epp", { 'dropin_config' => $config_hash }),
  }
}
