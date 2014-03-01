#
# jenkins::package handles the actual installation of the Jenkins native
# package installation.
#
# The package might not specify a dependency on Java, so you may need to
# specify that yourself
class jenkins::package {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  package { 'jenkins' :
    ensure => $::jenkins::version;
  }
}
