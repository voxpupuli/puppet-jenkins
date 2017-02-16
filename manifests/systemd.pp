# This class should be considered private
#
# This type handles setting up a systemd service and, if applicable, managing
# the transition from a sysv -> systemd service without leaving zombie services
# running.
define jenkins::systemd(
  $user,
  $libdir,
) {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }
  $service = $name

  include ::systemd

  $sysv_init = "/etc/init.d/${service}"

  file { "${libdir}/${service}-run":
    content => template("${module_name}/${service}-run.erb"),
    owner   => $user,
    mode    => '0700',
    notify  => Service[$service],
  }

  transition { "stop ${service} service":
    resource   => Service[$service],
    attributes => {
      # lint:ignore:ensure_first_param
      ensure => stopped,
      # lint:endignore
    },
    prior_to   => [
      File[$sysv_init],
    ],
  }

  # transition can not set a prior_to on
  # Systemd::Unit_file['jenkins-slave.service'] as it is not a native type so
  # we must us the sysv init script as a proxy
  file { $sysv_init:
    ensure                  => 'absent',
    # XXX if this is not set, the seluser property will claim is it out
    # of sync and the transition resource will always fire.  It isn't
    # clear if this is a bug or a feature of the file resource.
    selinux_ignore_defaults => true,
  }

  systemd::unit_file { "${service}.service":
    content => template("${module_name}/${service}.service.erb"),
    notify  => Service[$service],
    require => File[$sysv_init],
  }
}
