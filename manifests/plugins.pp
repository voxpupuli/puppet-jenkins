# Class: jenkins::plugins
#
class jenkins::plugins {
  assert_private()

  create_resources('jenkins::plugin',$jenkins::plugin_hash)

}
