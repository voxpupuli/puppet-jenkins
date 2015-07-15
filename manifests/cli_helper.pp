# Class jenkins::cli_helper
#
# A helper script for creating resources via the Jenkins cli
#
class jenkins::cli_helper (
  $jenkins_ssh_private_key_contents = '',
  $jenkins_ssh_public_key_contents = '',
  $ssh_keyfile = undef,
){
  include ::jenkins
  include ::jenkins::cli
  
  $libdir = $::jenkins::libdir
  $cli_jar = $::jenkins::cli::jar
  $port = jenkins_port()

  file { "${libdir}/.ssh/" :
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0700',
    require => User['jenkins'],
  }

  if ($jenkins_ssh_private_key_contents) {
    file { "${libdir}/.ssh/id_rsa" :
      owner   => 'jenkins',
      group   => 'jenkins',
      mode    => '0600',
      content => $jenkins_ssh_private_key_contents,
      replace => true,
      require => File["${libdir}/.ssh/"],
    }
  }
  
  if ($jenkins_ssh_public_key_contents) { 
    file { "${libdir}/.ssh/id_rsa.pub" :
      owner   => 'jenkins',
      group   => 'jenkins',
      mode    => '0644',
      content => "${jenkins_ssh_public_key_contents} jenkins@master",
      replace => true,
      require => File["${libdir}/.ssh"],
    }
  }

  $helper_groovy = "${libdir}/puppet_helper.groovy"
  file {$helper_groovy:
    source  => 'puppet:///modules/jenkins/puppet_helper.groovy',
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0444',
    require => Class['jenkins::cli'],
  }

  if $ssh_keyfile {
    $auth_arg = "-i ${ssh_keyfile}"
  } else {
    $auth_arg = undef
  }
  $helper_cmd = join(
    delete_undef_values([
      '/usr/bin/java',
      "-jar ${::jenkins::cli::jar}",
      "-s http://127.0.0.1:${port}",
      $auth_arg,
      "groovy ${helper_groovy}",
    ]),
    ' '
  )
}
