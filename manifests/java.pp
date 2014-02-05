#
# jenkins::java class integrates with the puppetlabs-java module
# to install java
#
class jenkins::java(
) {
  if defined('::java') {
    class {'::java':
      distribution => 'jdk'
    }
  }
}
