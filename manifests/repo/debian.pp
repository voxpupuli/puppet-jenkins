# @summary Set up the apt repo on Debian-based distros
# @api private
class jenkins::repo::debian (
  String $gpg_key_id = '5E386EADB55F01504CAE8BCF7198F4B714ABFC68',
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
      'id'     => $gpg_key_id,
      'source' => "${location}/${jenkins::repo::gpg_key_filename}",
    },
  }
}
