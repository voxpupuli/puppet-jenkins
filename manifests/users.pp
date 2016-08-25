# Class: jenkins::users
#
class jenkins::users {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  create_resources('jenkins::user', $::jenkins::user_hash)

}
