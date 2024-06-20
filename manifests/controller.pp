# @summary Install a controller
#
# @param version
#   Version of the swarm plugin
class jenkins::controller (
  String $version = $jenkins::params::swarm_version
) inherits jenkins::params {
  jenkins::plugin { 'swarm':
    version => $version,
  }
}
