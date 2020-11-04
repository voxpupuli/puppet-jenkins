# @summary Create Jenkins users
# @api private
class jenkins::users {
  assert_private()

  create_resources('jenkins::user', $jenkins::user_hash)
}
