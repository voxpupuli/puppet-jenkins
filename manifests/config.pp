# This class should be considered private
#
class jenkins::config {
  assert_private()

  ensure_resources('jenkins::plugin', $jenkins::default_plugins)

  $config_hash = merge(
    $jenkins::params::config_hash_defaults,
    $jenkins::config_hash
  )
  create_resources('jenkins::sysconfig', $config_hash)


}
