# Class: jenkins::master
#
#
class jenkins::master (
  $version = $jenkins::params::swarm_version
) inherits jenkins::params {

  jenkins::plugin {'swarm':
    version => $version ,
  }
}
