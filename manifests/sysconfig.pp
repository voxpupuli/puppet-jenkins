# Class: jenkins::sysconfig
#
define jenkins::sysconfig ( $value ) {
  $path = $::osfamily ? {
    RedHat  => '/etc/sysconfig',
    Debian  => '/etc/default',
    default => fail( "Unsupported OSFamily ${::osfamily}" )
  }

  file_line { "Jenkins sysconfig setting ${name}":
    path  => "${path}/jenkins",
    line  => "${name}=\"${value}\"",
    match => "^${name}=",
  }
}

