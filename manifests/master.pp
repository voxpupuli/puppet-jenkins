# Class: jenkins::master
#
#
class jenkins::master inherits jenkins::params (
  $version = $jenkins::params::swarm_version ) {

  jenkins::plugin {'swarm':
    version => $version }
}