#
# jenkins::firewall class integrates with the puppetlabs-firewall module for
# opening the port to Jenkins automatically
#
class jenkins::java(
) {
  if defined('::java') {
    class {'::java':
      distribution => 'jdk'
    }
  }
}
