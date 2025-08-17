# @summary Set up the apt repo on Debian-based distros
# @api private
class jenkins::repo::debian {
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
  }
}
