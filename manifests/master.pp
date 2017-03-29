# Class: jenkins::master
#
#
class jenkins::master (
  String $version = $jenkins::params::swarm_version
) inherits jenkins::params {
  jenkins::plugin {'swarm':
    version => $version ,
  }
}
