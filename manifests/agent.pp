# == Class: jenkins::agent
#
# This module setups up a swarm client for a jenkins server.  It requires the swarm plugin on the Jenkins controller.
#
# https://wiki.jenkins-ci.org/display/JENKINS/Swarm+Plugin
#
# It allows users to add more workers to Jenkins without having to specifically add them on the Jenkins controller.
#
# === Parameters
#
# [*agent_name*]
#   Specify the name of the agent.  Not required, by default it will use the fqdn.
#
# [*controllerurl*]
#   Specify the URL of the controller server.  Not required, the plugin will do a UDP autodiscovery. If specified, the autodiscovery will
#   be skipped.
#
# [*autodiscoveryaddress*]
#   Use this addresss for udp-based auto-discovery (default: 255.255.255.255)
#
# [*ui_user*] & [*ui_pass*]
#   User name & password for the Jenkins UI.  Not required, but may be ncessary for your config, depending on your security model.
#
# [*version*]
#   The version of the swarm client code. Must match the pluging version on the controller.  Typically it's the latest available.
#
# [*executors*]
#   Number of executors for this agent.  (How many jenkins jobs can run simultaneously on this host.)
#
# [*tunnel*]
#   Connect to the specified host and port, instead of connecting directly to Jenkins. Useful when connection to
#   Hudson needs to be tunneled. Can be also HOST: or :PORT, in which case the missing portion will be
#   auto-configured like the default behavior
#
# [*manage_agent_user*]
#   Should the class add a user to run the agent code?  1 is currently true
#   TODO: should be updated to use boolean.
#
# [*agent_user*]
#   Defaults to 'jenkins-agent'. Change it if you'd like..
#
# [*agent_groups*]
#   Not required.  Use to add the agent_user to other groups if you need to.  Defaults to undef.
#
# [*agent_uid*]
#   Not required.  Puppet will let your system add the user, with the new UID if necessary.
#
# [*agent_home*]
#   Defaults to '/home/jenkins-agent'.  This is where the code will be installed, and the workspace will end up.
#
# [*agent_mode*]
#   Defaults to 'normal'. Can be either 'normal' (utilize this agent as much as possible) or 'exclusive'
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
#   Not required.  String, or Array, that contains the list of labels to be assigned for this agent.
#
# [*tool_locations*]
#   Not required.  Single string of whitespace-separated list of tool locations to be defined on this agent. A tool location is specified
#   as 'toolName:location'.
#
# [*description*]
#   Not required.  Description which will appear on the jenkins controller UI.
#
# [*manage_client_jar*]
#   Should the class download the client jar file from the web? Defaults to true.
#
# [*ensure*]
#   Service ensure control for jenkins-agent service. Default running
#
# [*enable*]
#   Service enable control for jenkins-agent service. Default true.
#
# [*source*]
#   File source for jenkins agent jar. Default pulls from http://maven.jenkins-ci.org
#
# [*java_args*]
#   Java arguments to add to agent command line. Allows configuration of heap, etc. This
#   can be a String, or an Array.
#
# [*proxy_server*]
#   Serves the same function as `::jenkins::proxy_server` but is an independent
#   parameter so the `::jenkins` class does not need to be the catalog for
#   agent only nodes.
#
# [*swarm_client_args*]
#   Swarm client arguments to add to agent command line. More info: https://github.com/jenkinsci/swarm-plugin/blob/master/client/src/main/java/hudson/plugins/swarm/Options.java
#
# [*java_cmd*]
#   Path to the java command in ${defaults_location}/jenkins-agent. Defaults to '/usr/bin/java'
#
# === Examples
#
#  class { 'jenkins::agent':
#    controllerurl => 'http://jenkins-controller1.example.com:8080',
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
class jenkins::agent (
  Optional[String] $agent_name            = undef,
  Optional[String] $description           = undef,
  Optional[String] $controllerurl         = undef,
  Optional[String] $autodiscoveryaddress  = undef,
  Optional[String] $ui_user               = undef,
  Optional[String] $ui_pass               = undef,
  Optional[String] $tool_locations        = undef,
  Optional[String] $source                = undef,
  Optional[String] $proxy_server          = undef,
  Optional[Jenkins::Tunnel] $tunnel       = undef,
  String $version                         = $jenkins::params::swarm_version,
  Integer $executors                      = 2,
  Boolean $manage_agent_user              = true,
  String $agent_user                      = 'jenkins-agent',
  Optional[String] $agent_groups          = undef,
  Optional[Integer] $agent_uid            = undef,
  Stdlib::Absolutepath $agent_home        = '/home/jenkins-agent',
  Enum['normal', 'exclusive'] $agent_mode = 'normal',
  Boolean $disable_ssl_verification       = false,
  Boolean $disable_clients_unique_id      = false,
  Array[String[1]] $labels                = [],
  Any $install_java                       = true,
  Boolean $manage_client_jar              = true,
  Enum['running', 'stopped'] $ensure      = 'running',
  Boolean $enable                         = true,
  Array[String[1]] $java_args             = [],
  Array[String[1]] $swarm_client_args     = [],
  Boolean $delete_existing_clients        = false,
  Any $java_cmd                           = '/usr/bin/java',
) inherits jenkins::params {
  if versioncmp($version, '3.0') < 0 {
    $client_jar = "swarm-client-${version}-jar-with-dependencies.jar"
  } else {
    $client_jar = "swarm-client-${version}.jar"
  }

  $client_url = $source ? {
    undef   => "https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/${version}/",
    default => $source,
  }
  $quoted_ui_user = shellquote($ui_user)
  $quoted_ui_pass = shellquote($ui_pass)

  # the "public" API for tool_locations is a space seperated string in the
  # format "<name>:<path> [<name>:<path> ...]"
  # XXX a hash would be a more reasonable interface
  $_real_tool_locations = $tool_locations ? {
    undef   => undef,
    default => regsubst($tool_locations, ':', '=', 'G'),
  }

  if $install_java and ($facts['os']['family'] != 'Darwin') {
    # Currently the puppetlabs/java module doesn't support installing Java on
    # Darwin
    include java
    Class['java'] -> Service['jenkins-agent']
  }

  case $facts['kernel'] {
    'Linux': {
      $service_name     = 'jenkins-agent'
      $defaults_user    = 'root'
      $defaults_group   = 'root'
      $manage_user_home = true

      $defaults_location = $facts['os']['family'] ? {
        'Archlinux' => '/etc/conf.d',
        'Debian'    => '/etc/default',
        default     => '/etc/sysconfig',
      }

      file { "${defaults_location}/jenkins-agent":
        ensure  => 'file',
        mode    => '0600',
        owner   => $defaults_user,
        group   => $defaults_group,
        content => template("${module_name}/jenkins-agent-defaults.erb"),
        notify  => Service['jenkins-agent'],
      }

      file { "${agent_home}/${service_name}-run":
        content => template("${module_name}/${service_name}-run.erb"),
        owner   => $agent_user,
        mode    => '0755',
        seltype => 'bin_t',
        notify  => Service[$service_name],
      }

      systemd::unit_file { "${service_name}.service":
        content => template("${module_name}/${service_name}.service.erb"),
        notify  => Service[$service_name],
      }
    }
    'Darwin': {
      $service_name     = 'org.jenkins-ci.agent.jnlp'
      $defaults_user    = 'jenkins'
      $defaults_group   = 'wheel'
      $manage_user_home = false

      file { '/Library/LaunchDaemons/org.jenkins-ci.agent.jnlp.plist':
        ensure  => 'file',
        content => template("${module_name}/org.jenkins-ci.agent.jnlp.plist.epp"),
        mode    => '0644',
        owner   => 'root',
        group   => 'wheel',
      }
      -> Service['jenkins-agent']

      file { '/var/log/jenkins':
        ensure => 'directory',
        owner  => $agent_user,
      }
      -> Service['jenkins-agent']

      if $manage_agent_user {
        # osx doesn't have managehome support, so create directory
        file { $agent_home:
          ensure  => directory,
          mode    => '0755',
          owner   => $agent_user,
          require => User['jenkins-agent_user'],
        }
      }
    }
    default: {}
  }

  #a Add jenkins agent user if necessary.
  if $manage_agent_user {
    user { 'jenkins-agent_user':
      ensure     => present,
      name       => $agent_user,
      comment    => 'Jenkins agent user',
      home       => $agent_home,
      managehome => $manage_user_home,
      system     => true,
      uid        => $agent_uid,
      groups     => $agent_groups,
    }
  }

  if ($manage_client_jar) {
    archive { 'get_swarm_client':
      source       => "${client_url}/${client_jar}",
      path         => "${agent_home}/${client_jar}",
      proxy_server => $proxy_server,
      cleanup      => false,
      extract      => false,
    }
    -> Service['jenkins-agent']
  }

  service { 'jenkins-agent':
    ensure     => $ensure,
    name       => $service_name,
    enable     => $enable,
    hasstatus  => true,
    hasrestart => true,
  }

  if $manage_agent_user and $manage_client_jar {
    User['jenkins-agent_user']
    -> Archive['get_swarm_client']
  }
}
