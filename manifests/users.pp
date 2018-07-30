# Class: jenkins::users
#
class jenkins::users {
  assert_private()

  create_resources('jenkins::user', $::jenkins::user_hash)

}
