#
# jenkins::repo handles pulling in the platform specific repo classes
#
class jenkins::repo {
  anchor { 'jenkins::repo::begin': }
  anchor { 'jenkins::repo::end': }

  assert_private()

  if ( $::jenkins::repo ) {
    case $::osfamily {

      'RedHat', 'Linux': {
        class { 'jenkins::repo::el': }
        Anchor['jenkins::repo::begin']
          -> Class['jenkins::repo::el']
          -> Anchor['jenkins::repo::end']
      }

      'Debian': {
        class { 'jenkins::repo::debian': }
        Anchor['jenkins::repo::begin']
          -> Class['jenkins::repo::debian']
          -> Anchor['jenkins::repo::end']
      }

      'Suse' : {
        class { 'jenkins::repo::suse': }
        Anchor['jenkins::repo::begin']
          -> Class['jenkins::repo::suse']
          -> Anchor['jenkins::repo::end']
      }

      default: {
        fail( "Unsupported OS family: ${::osfamily}" )
      }
    }
  }
}
