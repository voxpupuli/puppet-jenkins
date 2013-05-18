define jenkins::sysconfig ( $value ) {
  $path = $::osfamily ? {
    RedHat  => '/etc/sysconfig',
    Debian  => '/etc/defaults',
    default => fail( "Unsupported OSFamily ${::osfamily}" )
  }

  file_line { "Jenkins sysconfig setting ${name}":
    path  => "${path}/jenkins",
    line  => "JENKINS_${name}=\"${value}\"",
    match => "^JENKINS_${name}=",
  }
}

