#
# jenkins::repo handles pulling in the platform specific repo classes
#
class jenkins::repo(
  Stdlib::Httpurl $base_url = 'https://pkg.jenkins.io',
  String $gpg_key_filename = 'jenkins.io.key',
) {
  assert_private()

  if $jenkins::repo {
    case $facts['os']['family'] {

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
        fail( "Unsupported OS family: ${facts['os']['family']}" )
      }
    }
  }
}
