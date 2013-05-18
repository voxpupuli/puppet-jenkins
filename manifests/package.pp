#
# jenkins::package handles the actual installation of the Jenkins native
# package installation.
#
# The package might not specify a dependency on Java, so you may need to
# specify that yourself
class jenkins::package($version = 'installed') {
  package {
    'jenkins' :
      ensure => $version;
  }
}
