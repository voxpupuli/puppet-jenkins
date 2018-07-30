# Class: jenkins::repo::el
#
class jenkins::repo::el {
  assert_private()

  if $jenkins::lts {
    $baseurl = "${jenkins::repo::base_url}/redhat-stable/"
  } else {
    $baseurl = "${jenkins::repo::base_url}/redhat/"
  }

  yumrepo {'jenkins':
    descr    => 'Jenkins',
    baseurl  => $baseurl,
    gpgcheck => 1,
    gpgkey   => "${baseurl}${jenkins::repo::gpg_key_filename}",
    enabled  => 1,
    proxy    => $jenkins::repo_proxy,
  }
}
