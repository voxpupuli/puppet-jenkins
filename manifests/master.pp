# Class: jenkins::master
#
#
class jenkins::master (
  $version = $jenkins::params::swarm_version,
  $source  = undef,
) inherits jenkins::params {
  validate_string($version)

  jenkins::plugin {'swarm':
    version => $version,
    source  => $source,
  }
}
