# Class: jenkins::plugins
#
class jenkins::plugins (
  $plugin_hash = {}
) {
  validate_hash( $plugin_hash )
  create_resources('jenkins::plugin',$plugin_hash)
}
