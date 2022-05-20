# @summary Wire up the configuration
# @api private
class jenkins::config {
  assert_private()

  ensure_resource('jenkins::plugin', $jenkins::default_plugins)
}
