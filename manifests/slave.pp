# Class: jenkins::slave
#
#
#  ensure is not immplemented yet, since i'm
#  assuming you want to actually run the slave
#  by declaring it..
#
class jenkins::slave (
  $masterurl = undef,
  $ui_user = undef,
  $ui_pass = undef,
  $version = '1.8',
  $executors = 2,
  $manage_slave_user = 1,
  $slave_user = 'jenkins-slave',
  $slave_uid = undef,
  $slave_home = '/home/jenkins-slave',
  $labels = 'default',
  $broadcast_address = '255.255.255.255'
) {

  $client_jar = "swarm-client-${version}-jar-with-dependencies.jar"
  $client_url = "http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/${version}/"

  #add jenkins slave if necessary.

  if $manage_slave_user == 1 and $slave_uid {
    user { 'jenkins-slave_user':
      ensure     => present,
      name       => $slave_user,
      comment    => 'Jenkins Slave user',
      home       => $slave_home,
      managehome => true,
      uid        => $slave_uid
    }
  }

  if ($manage_slave_user == 1) and (! $slave_uid) {
    user { 'jenkins-slave_user':
      ensure     => present,
      name       => $slave_user,
      comment    => 'Jenkins Slave user',
      home       => $slave_home,
      managehome => true,
    }
  }

  exec { 'test_java_installed':
    command => 'java -version',
    path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
  }

  exec { 'get_swarm_client':
    command      => "wget -O ${slave_home}/${client_jar} ${client_url}/${client_jar}",
    path         => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    user         => $slave_user,
    #refreshonly => true,
    creates      => "${slave_home}/${client_jar}"
    ## needs to be fixed if you create another version..
  }

  if $ui_user {
    $ui_user_flag = "-username ${ui_user}"
  }
  else {$ui_user_flag = ''}

  if $ui_pass {
    $ui_pass_flag = "-password ${ui_pass}"
  } else {
    $ui_pass_flag = ''
  }

  if $masterurl {
    $masterurl_flag = "-master ${masterurl}"
  } else {
    $masterurl_flag = ''
  }



  file { '/etc/init/jenkins-slave.conf':
      ensure  => 'file',
      mode    => '0700',
      owner   => 'root',
      group   => 'root',
      content => template("${module_name}/jenkins-slave.erb"),
      notify  => Service['jenkins-slave']
  }

  # FIXME: Forcing stop+start to workaround upstart restart.
  service { 'jenkins-slave':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => false,
  }

  Exec['test_java_installed']
  -> Exec['get_swarm_client']
  -> Service['jenkins-slave']

}
