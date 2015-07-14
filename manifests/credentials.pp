# Class: jenkins::credentials
#
class jenkins::credentials {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  create_resources('jenkins::credential', $::jenkins::credential_hash)

}
