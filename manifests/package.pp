#
# jenkins::package handles the actual installation of the Jenkins native
# package installation.
#
# The package might not specify a dependency on Java, so you may need to
# specify that yourself
class jenkins::package {
  assert_private()

  package { $jenkins::package_name:
    ensure => $jenkins::version,
  }
}
