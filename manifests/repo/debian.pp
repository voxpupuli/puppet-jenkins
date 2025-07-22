# @summary Set up the apt repo on Debian-based distros
# @api private
class jenkins::repo::debian (
  String $gpg_key_id = '63667EE74BBA1F0A08A698725BA31D57EF5975CA',
) {
  assert_private()

  include apt

  if $jenkins::lts {
    $location = "${jenkins::repo::base_url}/debian-stable"
  } else {
    $location = "${jenkins::repo::base_url}/debian"
  }

  apt::source { 'jenkins':
    location => $location,
    release  => 'binary/',
    include  => {
      'src' => false,
    },
    key      => {
      'name'   => 'jenkins.asc',
      'source' => "${location}/${jenkins::repo::gpg_key_filename}",
    },
    notify   => Exec['check Jenkins OpenPGP key fingerprint'],
  }

  exec { 'check Jenkins OpenPGP key fingerprint':
    command     => "/usr/bin/test \"$(/usr/bin/gpg --show-keys --with-colons /etc/apt/keyrings/jenkins.asc | /usr/bin/awk -F: '/^fpr/ {print \$10}' | head -n 1)\" = ${gpg_key_id}",
    refreshonly => true,
    require     => Apt::Source['jenkins'],
  }
}
