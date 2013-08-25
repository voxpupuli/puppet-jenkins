# Class: jenkins::master
#
#
class jenkins::master (
  $version = $jenkins::params::swarm_version ) {

  jenkins::plugin {'swarm':
    version => $version }  
}