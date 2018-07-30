#
# jenkins::repo handles pulling in the platform specific repo classes
#
class jenkins::repo {
  assert_private()

  if $::jenkins::repo {
    case $::osfamily {

      'RedHat', 'Linux': {
        contain jenkins::repo::el
      }

      'Debian': {
        contain jenkins::repo::debian
      }

      'Suse' : {
        contain jenkins::repo::suse
      }

      default: {
        fail( "Unsupported OS family: ${::osfamily}" )
      }
    }
  }
}
