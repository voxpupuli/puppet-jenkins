# == Class: jenkins::slave
#
# This module setups up a swarm client for a jenkins server.  It requires the swarm plugin on the Jenkins master.
#
# https://wiki.jenkins-ci.org/display/JENKINS/Swarm+Plugin
#
# It allows users to add more workers to Jenkins without having to specifically add them on the Jenkins master.
#
# === Parameters
#
# [*slave_name*]
#   Specify the name of the slave.  Not required, by default it will use the fqdn.
#
# [*masterurl*]
#   Specify the URL of the master server.  Not required, the plugin will do a UDP autodiscovery. If specified, the autodiscovery will
#   be skipped.
#
# [*autodiscoveryaddress*]
#   Use this addresss for udp-based auto-discovery (default: 255.255.255.255)
#
# [*ui_user*] & [*ui_pass*]
#   User name & password for the Jenkins UI.  Not required, but may be ncessary for your config, depending on your security model.
#
# [*version*]
#   The version of the swarm client code. Must match the pluging version on the master.  Typically it's the latest available.
#
# [*executors*]
#   Number of executors for this slave.  (How many jenkins jobs can run simultaneously on this host.)
#
# [*manage_slave_user*]
#   Should the class add a user to run the slave code?  1 is currently true
#   TODO: should be updated to use boolean.
#
# [*slave_user*]
#   Defaults to 'jenkins-slave'. Change it if you'd like..
#
# [*slave_groups*]
#   Not required.  Use to add the slave_user to other groups if you need to.  Defaults to undef.
#
# [*slave_uid*]
#   Not required.  Puppet will let your system add the user, with the new UID if necessary.
#
# [*slave_home*]
#   Defaults to '/home/jenkins-slave'.  This is where the code will be installed, and the workspace will end up.
#
# [*slave_mode*]
#   Defaults to 'normal'. Can be either 'normal' (utilize this slave as much as possible) or 'exclusive'
#   (leave this machine for tied jobs only).
#
# [*disable_ssl_verification*]
#   Disable SSL certificate verification on Swarm clients. Not required, but is necessary if you're using a self-signed SSL cert.
#   Defaults to false.
#
# [*disable_clients_unique_id*]
#   Disable setting the unique id for the swarm client
#   Defaults to false
#
# [*labels*]
#   Not required.  String, or Array, that contains the list of labels to be assigned for this slave.
#
# [*tool_locations*]
#   Not required.  Single string of whitespace-separated list of tool locations to be defined on this slave. A tool location is specified
#   as 'toolName:location'.
#
# [*description*]
#   Not required.  Description which will appear on the jenkins master UI.
#
# [*manage_client_jar*]
#   Should the class download the client jar file from the web? Defaults to true.
#
# [*ensure*]
#   Service ensure control for jenkins-slave service. Default running
#
# [*enable*]
#   Service enable control for jenkins-slave service. Default true.
#
# [*source*]
#   File source for jenkins slave jar. Default pulls from http://maven.jenkins-ci.org
#
# [*java_args*]
#   Java arguments to add to slave command line. Allows configuration of heap, etc. This
#   can be a String, or an Array.
#
# [*proxy_server*]
#
#   Serves the same function as `::jenkins::proxy_server` but is an independent
#   parameter so the `::jenkins` class does not need to be the catalog for
#   slave only nodes.
#
# [*swarm_client_args*]
#   Swarm client arguments to add to slave command line. More info: https://github.com/jenkinsci/swarm-plugin/blob/master/client/src/main/java/hudson/plugins/swarm/Options.java
#

# === Examples
#
#  class { 'jenkins::slave':
#    masterurl => 'http://jenkins-master1.example.com:8080',
#    ui_user => 'adminuser',
#    ui_pass => 'adminpass'
#  }
#
# === Authors
#
# Matthew Barr <mbarr@mbarr.net>
#
# === Copyright
#
# Copyright 2013 Matthew Barr , but can be used for anything by anyone..
class jenkins::slave (
  $slave_name                = undef,
  $description               = undef,
  $masterurl                 = undef,
  $autodiscoveryaddress      = undef,
  $ui_user                   = undef,
  $ui_pass                   = undef,
  $version                   = $jenkins::params::swarm_version,
  $executors                 = 2,
  $manage_slave_user         = true,
  $slave_user                = 'jenkins-slave',
  $slave_groups              = undef,
  $slave_uid                 = undef,
  $slave_home                = '/home/jenkins-slave',
  $slave_mode                = 'normal',
  $disable_ssl_verification  = false,
  $disable_clients_unique_id = false,
  $labels                    = undef,
  $tool_locations            = undef,
  $install_java              = $jenkins::params::install_java,
  $manage_client_jar         = true,
  $ensure                    = 'running',
  $enable                    = true,
  $source                    = undef,
  $java_args                 = undef,
  $proxy_server              = undef,
  $swarm_client_args         = undef,
  $delete_existing_clients   = false,
) inherits jenkins::params {
  validate_string($slave_name)
  validate_string($description)
  validate_string($masterurl)
  validate_string($autodiscoveryaddress)
  validate_string($ui_user)
  validate_string($ui_pass)
  validate_string($version)
  validate_integer($executors)
  validate_bool($manage_slave_user)
  validate_string($slave_user)
  if $slave_groups { validate_string($slave_groups) }
  if $slave_uid { validate_integer($slave_uid) }
  validate_absolute_path($slave_home)
  validate_re($slave_mode, '^normal$|^exclusive$')
  validate_string($tool_locations)
  validate_bool($install_java)
  validate_bool($manage_client_jar)
  validate_re($ensure, '^running$|^stopped$')
  validate_bool($enable)
  validate_string($source)
  validate_string($proxy_server)
  validate_bool($delete_existing_clients)

  $client_jar = "swarm-client-${version}-jar-with-dependencies.jar"
  $client_url = $source ? {
    undef   => "https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/${version}/",
    default => $source,
  }
  $quoted_ui_user = shellquote($ui_user)
  $quoted_ui_pass = shellquote($ui_pass)

  if $labels {
    if is_array($labels) {
      $_combined_labels = hiera_array('jenkins::slave::labels', $labels)
      $_real_labels = join($_combined_labels, ' ')
    }
    else {
      $_real_labels = $labels
    }
  }

  if $java_args {
    if is_array($java_args) {
      $_combined_java_args = hiera_array('jenkins::slave::java_args', $java_args)
      $_real_java_args = join($_combined_java_args, ' ')
    }
    else {
      $_real_java_args = $java_args
    }
  }

  if $swarm_client_args {
    if is_array($swarm_client_args) {
      $_combined_swarm_client_args = hiera_array('jenkins::slave::swarm_client_args', $swarm_client_args)
      $_real_swarm_client_args = join($_combined_swarm_client_args, ' ')
    }
    else {
      $_real_swarm_client_args = $swarm_client_args
    }
  }

  # the "public" API for tool_locations is a space seperated string in the
  # format "<name>:<path> [<name>:<path> ...]"
  # XXX a hash would be a more reasonable interface
  $_real_tool_locations = $tool_locations ? {
    undef   => undef,
    default => regsubst($tool_locations, ':', '=', 'G'),
  }

  if $install_java and ($::osfamily != 'Darwin') {
    # Currently the puppetlabs/java module doesn't support installing Java on
    # Darwin
    include ::java
    Class['java'] -> Service['jenkins-slave']
  }

  # customizations based on the OS family
  case $::osfamily {
    'Debian': {
      $defaults_location = $::jenkins::params::sysconfdir

      ensure_packages(['daemon'])
      Package['daemon'] -> Service['jenkins-slave']
    }
    'Darwin': {
      $defaults_location = $slave_home
    }
    default: {
      $defaults_location = $::jenkins::params::sysconfdir
    }
  }

  case $::kernel {
    'Linux': {
      $service_name     = 'jenkins-slave'
      $defaults_user    = 'root'
      $defaults_group   = 'root'
      $manage_user_home = true
      $sysv_init        = '/etc/init.d/jenkins-slave'

      if $::systemd {
        jenkins::systemd { 'jenkins-slave':
          user   => $slave_user,
          libdir => $slave_home,
        }
      } else {
        file { "${slave_home}/${service_name}-run":
          content => template("${module_name}/${service_name}-run.erb"),
          owner   => $slave_user,
          mode    => '0755',
          notify  => Service[$service_name],
        }

        file { $sysv_init:
          ensure  => 'file',
          mode    => '0755',
          owner   => 'root',
          group   => 'root',
          content => template("${module_name}/${service_name}.${::osfamily}.erb"),
          notify  => Service[$service_name],
        }
      }
    }
    'Darwin': {
      $service_name     = 'org.jenkins-ci.slave.jnlp'
      $defaults_user    = 'jenkins'
      $defaults_group   = 'wheel'
      $manage_user_home = false

      file { "${slave_home}/start-slave.sh":
        ensure  => 'file',
        content => template("${module_name}/start-slave.sh.erb"),
        mode    => '0755',
        owner   => 'root',
        group   => 'wheel',
      }

      file { '/Library/LaunchDaemons/org.jenkins-ci.slave.jnlp.plist':
        ensure  => 'file',
        content => template("${module_name}/org.jenkins-ci.slave.jnlp.plist.erb"),
        mode    => '0644',
        owner   => 'root',
        group   => 'wheel',
      } ->
      Service['jenkins-slave']

      file { '/var/log/jenkins':
        ensure => 'directory',
        owner  => $slave_user,
      } ->
      Service['jenkins-slave']

      if $manage_slave_user {
        # osx doesn't have managehome support, so create directory
        file { $slave_home:
          ensure  => directory,
          mode    => '0755',
          owner   => $slave_user,
          require => User['jenkins-slave_user'],
        }
      }
    }
    default: { }
  }

  #a Add jenkins slave user if necessary.
  if $manage_slave_user {
    user { 'jenkins-slave_user':
      ensure     => present,
      name       => $slave_user,
      comment    => 'Jenkins Slave user',
      home       => $slave_home,
      managehome => $manage_user_home,
      system     => true,
      uid        => $slave_uid,
      groups     => $slave_groups,
    }
  }

  file { "${defaults_location}/jenkins-slave":
    ensure  => 'file',
    mode    => '0600',
    owner   => $defaults_user,
    group   => $defaults_group,
    content => template("${module_name}/jenkins-slave-defaults.erb"),
    notify  => Service['jenkins-slave'],
  }

  if ($manage_client_jar) {
    archive { 'get_swarm_client':
      source       => "${client_url}/${client_jar}",
      path         => "${slave_home}/${client_jar}",
      proxy_server => $proxy_server,
      cleanup      => false,
      extract      => false,
    } ->
    Service['jenkins-slave']
  }

  service { 'jenkins-slave':
    ensure     => $ensure,
    name       => $service_name,
    enable     => $enable,
    hasstatus  => true,
    hasrestart => true,
  }

  if $manage_slave_user and $manage_client_jar {
    User['jenkins-slave_user']->
      Archive['get_swarm_client']
  }
}
