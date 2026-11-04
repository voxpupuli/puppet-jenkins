# @summary Manage the Jenkins Configuration as Code (JCasC) file
#
# Writes `jenkins::casc_config` as YAML to `${localstatedir}/jenkins.yaml`,
# which the configuration-as-code plugin loads by default when
# CASC_JENKINS_CONFIG is not set. The content is Sensitive, as it often holds
# credentials (for example an LDAP manager password from eyaml).
#
# @api private
class jenkins::casc {
  assert_private()

  unless empty($jenkins::casc_config) {
    $casc_file = "${jenkins::localstatedir}/jenkins.yaml"

    file { $casc_file:
      ensure  => file,
      content => Sensitive(stdlib::to_yaml($jenkins::casc_config)),
      owner   => $jenkins::user,
      group   => $jenkins::group,
      mode    => '0600',
    }

    Package[$jenkins::package_name] -> File[$casc_file]

    if $jenkins::manage_service {
      File[$casc_file] ~> Class['jenkins::service']
    }
  }
}
