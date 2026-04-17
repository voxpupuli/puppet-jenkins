# @summary Set up the apt repo on Debian-based distros
# @api private
class jenkins::repo::debian {
  assert_private()

  include apt

  if $jenkins::lts {
    $location = "${jenkins::repo::base_url}/debian-stable"
    $location_key = "${jenkins::repo::base_url}/debian-stable/${jenkins::repo::gpg_key_filename}"
  } else {
    $location = "${jenkins::repo::base_url}/debian"
    $location_key = "${jenkins::repo::base_url}/debian/${jenkins::repo::gpg_key_filename}"
  }

  apt::keyring { 'jenkins':
    source   => $location_key,
    filename => 'jenkins-keyring.asc',
  }

  apt::source { 'jenkins':
    location => $location,
    release  => 'binary/',
    include  => {
      'src' => false,
    },
    keyring  => '/etc/apt/keyrings/jenkins-keyring.asc',
  }
}
