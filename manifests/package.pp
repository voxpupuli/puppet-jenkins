#
# jenkins::package handles the actual installation of the Jenkins native
# package installation.
#
class jenkins::package(
  $version        = 'installed',
  $required_class = undef,
) {
  if $required_class {
      Package {
            require => Class[$required_class],
      }
  }

  package { 'jenkins' :
      ensure  => $version,
  }
}
