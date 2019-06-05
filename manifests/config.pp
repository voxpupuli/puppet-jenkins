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


}
