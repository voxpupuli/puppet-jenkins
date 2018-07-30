# Class: jenkins::repo::suse
#
class jenkins::repo::suse {
  assert_private()

  if $jenkins::lts {
    $baseurl = "${jenkins::repo::base_url}/opensuse-stable/"
  } else {
    $baseurl = "${jenkins::repo::base_url}/opensuse/"
  }

  zypprepo {'jenkins':
    descr    => 'Jenkins',
    baseurl  => $baseurl,
    gpgcheck => 1,
    gpgkey   => "${baseurl}${jenkins::repo::gpg_key_filename}",
  }
}
