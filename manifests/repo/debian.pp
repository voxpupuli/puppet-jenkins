# @summary Set up the apt repo on Debian-based distros
# @api private
class jenkins::repo::debian (
  String $gpg_key_id = '62A9756BFD780C377CF24BA8FCEF32E745F2C3D5',
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
    repos    => '',
    include  => {
      'src' => false,
    },
    key      => {
      'id'     => $gpg_key_id,
      'source' => "${location}/${jenkins::repo::gpg_key_filename}",
    },
  }
}
