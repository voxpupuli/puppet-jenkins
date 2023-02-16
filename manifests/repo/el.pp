# @summary Set up the yum repo on Red Hat-based distros
# @api private
class jenkins::repo::el {
  assert_private()

  if $jenkins::lts {
    $baseurl = "${jenkins::repo::base_url}/redhat-stable/"
  } else {
    $baseurl = "${jenkins::repo::base_url}/redhat/"
  }

  yumrepo { 'jenkins':
    descr    => 'Jenkins',
    baseurl  => $baseurl,
    gpgcheck => 1,
    gpgkey   => "${baseurl}${jenkins::repo::gpg_key_filename}",
    enabled  => $jenkins::repo::enabled,
    proxy    => $jenkins::repo_proxy,
  }
}
