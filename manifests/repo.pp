#
# jenkins::repo handles pulling in the platform specific repo classes
#
class jenkins::repo {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if ( $::jenkins::repo ) {
    case $::osfamily {

      'RedHat', 'Linux': {
        class { 'jenkins::repo::el': }
      }

      'Debian': {
        class { 'jenkins::repo::debian': }
      }

      'Suse' : {
        class { 'jenkins::repo::suse': }
      }

      default: {
        fail( "Unsupported OS family: ${::osfamily}" )
      }
    }
  }
}

