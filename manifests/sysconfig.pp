# Class: jenkins::sysconfig
#
define jenkins::sysconfig(
  $value,
) {
  validate_string($value)

  if ($value =~ /\$/) {
    warning("Jenkins::Sysconfig[${name}]: detected \'\$\' in value -- be advised the variable interpolation will not work under systemd")
  }

  file_line { "Jenkins sysconfig setting ${name}":
    path   => "${::jenkins::sysconfdir}/jenkins",
    line   => "${name}=\"${value}\"",
    match  => "^${name}=",
    notify => Service['jenkins'],
  }

}
