# @summary Installation of the Jenkins native package.
#
# The package might not specify a dependency on Java, so you may need to
# specify that yourself
#
# @api private
class jenkins::package {
  assert_private()

  package { $jenkins::package_name:
    ensure => $jenkins::version,
  }
}
