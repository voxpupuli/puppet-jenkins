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
#   Specify the URL of the master server.  Not required, the plugin will do a UDP autodiscovery. If specified, the autodiscovery will be skipped.
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
# [*slave_uid*]
#   Not required.  Puppet will let your system add the user, with the new UID if necessary.
#
# [*slave_home*]
#   Defaults to '/home/jenkins-slave'.  This is where the code will be installed, and the workspace will end up.
#
# [*slave_mode*]
#   Defaults to 'normal'. Can be either 'normal' (utilize this slave as much as possible) or 'exclusive' (leave this machine for tied jobs only).
#
# [*disable_ssl_verification*]
#   Disable SSL certificate verification on Swarm clients. Not required, but is necessary if you're using a self-signed SSL cert. Defaults to false.
#
# [*labels*]
#   Not required.  Single string of whitespace-separated list of labels to be assigned for this slave.
#
# [*tool_locations*]
#   Not required.  Single string of whitespace-separated list of tool locations to be defined on this slave. A tool location is specified as 'toolName:location'.
#
# [*java_version*]
#   Specified which version of java will be used.
#
# [*description*]
#   Not required.  Description which will appear on the jenkins master UI.
#

# === Examples
#
#  class { 'jenkins::slave':
#    masterurl => 'http://jenkins-master1.example.com:8080',
#    ui_user => 'adminuser',
#    ui_pass => 'adminpass',
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
  $slave_name               = undef,
  $description              = undef,
  $masterurl                = undef,
  $autodiscoveryaddress     = undef,
  $ui_user                  = undef,
  $ui_pass                  = undef,
  $version                  = $jenkins::params::swarm_version,
  $executors                = 2,
  $manage_slave_user        = true,
  $slave_user               = 'jenkins-slave',
  $slave_uid                = undef,
  $slave_home               = '/home/jenkins-slave',
  $slave_mode               = 'normal',
  $disable_ssl_verification = false,
  $labels                   = undef,
  $tool_locations           = undef,
  $install_java             = $jenkins::params::install_java,
  $ensure                   = 'running',
  $enable                   = true,
  $checksum                 = undef,
  $checksum_type            = 'sha1',
) inherits jenkins::params {
  validate_string($checksum)
  validate_string($checksum_type)

  $client_jar = "swarm-client-${version}-jar-with-dependencies.jar"
  $client_url = "http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/${version}/"

  if $install_java {
    class { 'java':
      distribution => 'jdk',
    }
  }

#add jenkins slave user if necessary.
  if $manage_slave_user and $slave_uid {
    user { 'jenkins-slave_user':
      ensure     => present,
      name       => $slave_user,
      comment    => 'Jenkins Slave user',
      home       => $slave_home,
      managehome => true,
      uid        => $slave_uid,
    }
  }

  if ($manage_slave_user) and (! $slave_uid) {
    user { 'jenkins-slave_user':
      ensure     => present,
      name       => $slave_user,
      comment    => 'Jenkins Slave user',
      home       => $slave_home,
      managehome => true,
    }
  }

  $enable_checksum = $checksum ? {
    undef   => false,
    default => true,
  }

  archive::download { $client_jar:
    url              => "${client_url}/${client_jar}",
    src_target       => $slave_home,
    allow_insecure   => true,
    follow_redirects => true,
    checksum         => $enable_checksum,
    digest_string    => $checksum,
    digest_type      => $checksum_type,
    user             => $slave_user,
    proxy_server     => $::jenkins::http_proxy,
    verbose          => false,
    notify           => Service['jenkins-slave'],
  }

  # customizations based on the OS family
  case $::osfamily {
    'Debian': {
      $defaults_location = '/etc/default'

      package { 'daemon':
        ensure => present,
        before => Service['jenkins-slave'],
      }
    }
    default: {
      $defaults_location = '/etc/sysconfig'
    }
  }

  file { '/etc/init.d/jenkins-slave':
    ensure => 'file',
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
    source => "puppet:///modules/${module_name}/jenkins-slave.${::osfamily}",
    notify => Service['jenkins-slave'],
  }

  file { "${defaults_location}/jenkins-slave":
    ensure  => 'file',
    mode    => '0600',
    owner   => 'root',
    group   => 'root',
    content => template("${module_name}/jenkins-slave-defaults.erb"),
    notify  => Service['jenkins-slave'],
  }

  service { 'jenkins-slave':
    ensure     => $ensure,
    enable     => $enable,
    hasstatus  => true,
    hasrestart => true,
  }

  if $install_java {
    Class['java'] ->
    Service['jenkins-slave']
  }
}
