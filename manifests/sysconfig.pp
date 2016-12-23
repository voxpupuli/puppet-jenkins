# Class: jenkins::sysconfig
#
define jenkins::sysconfig(
  $value,
) {
  validate_string($value)

  file_line { "Jenkins sysconfig setting ${name}":
    path   => "${::jenkins::sysconfdir}/jenkins",
    line   => "${name}=\"${value}\"",
    match  => "^${name}=",
    notify => Service['jenkins'],
  }

}
