class jenkins::repo {
  # JJM These anchors work around #8040
  anchor { 'jenkins::repo::alpha': }
  anchor { 'jenkins::repo::omega': }
  case $::operatingsystem {
    centos, redhat, oel: {
      class { 'jenkins::repo::el':
        require => Anchor['jenkins::repo::alpha'],
        before  => Anchor['jenkins::repo::omega'],
      }
    }
    opensuse: {
      # XXX: Need to figure out how to set up the zypper repo for openSUSE
    }

    default: {
      class { 'jenkins::repo::debian':
        require => Anchor['jenkins::repo::alpha'],
        before  => Anchor['jenkins::repo::omega'],
      }
    }
  }
}

