# @summary Install a master
#
# @param version
#   Version of the swarm plugin
class jenkins::master (
  String $version = $jenkins::params::swarm_version
) inherits jenkins::params {
  jenkins::plugin { 'swarm':
    version => $version,
  }
}
