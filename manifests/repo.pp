#
# jenkins::repo handles pulling in the platform specific repo classes
#
class jenkins::repo ($lts=0, $repo=1) {
  # JJM These anchors work around #8040
  anchor { 'jenkins::repo::alpha': }
  anchor { 'jenkins::repo::omega': }

  if ($repo == 1) {
    case $::osfamily {

      'RedHat': {
        class {
          'jenkins::repo::el':
            lts     => $lts,
            require => Anchor['jenkins::repo::alpha'],
            before  => Anchor['jenkins::repo::omega'],
        }
      }

      'Linux': {
        class {
          'jenkins::repo::el':
            lts     => $lts,
            require => Anchor['jenkins::repo::alpha'],
            before  => Anchor['jenkins::repo::omega'],
        }
      }

      'Debian': {
        class {
          'jenkins::repo::debian':
            lts     => $lts,
            require => Anchor['jenkins::repo::alpha'],
            before  => Anchor['jenkins::repo::omega'],
        }
      }

      default: {
        fail( "Unsupported OS family: ${::osfamily}" )
      }
    }
  }
}

