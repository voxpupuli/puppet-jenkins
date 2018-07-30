# Class: jenkins::repo::debian
#
class jenkins::repo::debian (
  String $gpg_key_id = '150FDE3F7787E7D11EF4E12A9B7D32F2D50582E6',
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
