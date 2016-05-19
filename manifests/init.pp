# Parameters:
#
# version = 'installed' (Default)
#   Will NOT update jenkins to the most recent version.
#
# version = 'latest'
#    Will automatically update the version of jenkins to the current version available via your package manager.
#
# lts = false
#   Use the most up to date version of jenkins
#
# lts = true (Default)
#   Use LTS verison of jenkins
#
# port = 8080 (default)
#   Sets firewall port to 8080 if puppetlabs-firewall module is installed
#
# repo = true (Default)
#   install the jenkins repo.
#
# repo = 0
#   Do NOT install a repo. This means you'll manage a repo manually outside
#   this module.
#   This is for folks that use a custom repo, or the like.
#
# package_name = 'jenkins'
#   Optionally override the package name
#
# direct_download = 'http://...'
#   Ignore repostory based package installation and download and install
#   package directly.  Leave as `undef` (the default) to download using your
#   OS package manager
#
# package_cache_dir  = '/var/cache/jenkins_pkgs'
#   Optionally specify an alternate location to download packages to when using
#   direct_download
#
# service_enable = true (default)
#   Enable (or not) the jenkins service
#
# service_ensure = 'running' (default)
#   Status of the jenkins service.  running, stopped
#
# config_hash = undef (Default)
#   Hash with config options to set in sysconfig/jenkins defaults/jenkins
#
# manage_datadirs = true (default)
#   true if this module should manage the local state dir, plugins dir and jobs dir
#
# localstatedir = '/var/lib/jenkins' (default)
#   base path, in the autoconf sense, for jenkins local data including jobs and
#   plugins
#
# executors = undef (Default)
#   Integer number of executors on the Jenkin's master.
#
# slaveagentport = undef (Default)
#   Integer number of portnumber for the slave agent.
#
# manage_user = true (default)
#
# user = 'jenkins' (default)
#`  system user that owns the jenkins master's files
#
# manage_group = true (default)
#
# group = 'jenkins' (default)
#`  system group that owns the jenkins master's files
#
# Example use
#
# class{ 'jenkins':
#   config_hash => {
#     'HTTP_PORT' => { 'value' => '9090' }, 'AJP_PORT' => { 'value' => '9009' }
#   }
# }
#
# plugin_hash = undef (Default)
# Hash with config plugins to install
#
# Example use
#
# class{ 'jenkins::plugins':
#   plugin_hash => {
#     'git' => { version => '1.1.1' },
#     'parameterized-trigger' => {},
#     'multiple-scms' => {},
#     'git-client' => {},
#     'token-macro' => {},
#   }
# }
#
# OR in Hiera
#
# jenkins::plugin_hash:
#    'git':
#       version: 1.1.1
#    'parameterized-trigger': {}
#    'multiple-scms': {}
#    'git-client': {}
#    'token-macro': {}
#
#
# user_hash = {} (Default)
# Hash with users to create in jenkins
#
# Example use
#
# class{ 'jenkins':
#   user_hash => {
#     'user1' => { 'password' => 'pass1',
#                     'email' => 'user1@example.com'}
#
# Or in Hiera
#
# jenkins::user_hash:
#     'user1':
#       password: 'pass1'
#       email: 'user1@example.com'
#
# configure_firewall = false (default)
#   For folks that want to manage the puppetlabs firewall module.
#    - If it's not present in the catalog, nothing happens.
#    - If it is, you need to explicitly set this true / false.
#       - We didn't want you to have a service opened automatically, or unreachable inexplicably.
#    - This default changed in v1.0 to be undef.
#
#
# install_java = true (default)
#   - use puppetlabs-java module to install the correct version of a JDK.
#   - Jenkins requires a JRE
#
#
# cli = true (default)
#   - force installation of the jenkins CLI jar to $libdir/cli/jenkins-cli.jar
#   - the cli is automatically installed when needed by components that use it,
#     such as the user and credentials types, and the security class
#   - CLI installation (both implicit and explicit) requires the unzip command
#
#
# cli_ssh_keyfile = undef (default)
#   Provides the location of an ssh private key file to make authenticated
#   connections to the Jenkins CLI.
#
#
# cli_tries = 10 (default)
#   Retries until giving up talking to jenkins API
#
#
# cli_try_sleep = 10 (default)
#   Seconds between tries to contact jenkins API
#
# repo_proxy = undef (default)
#   If you environment requires a proxy to download packages
#
# proxy_host = undef (default)
# proxy_port = undef (default)
#   If your environment requires a proxy host to download plugins it can be configured here
#
#
# no_proxy_list = undef (default)
#   List of hostname patterns to skip using the proxy.
#   - Accepts input as array only.
#   - Only effective if "proxy_host" and "proxy_port" are set.
#
# user = 'jenkins' (default)
#
# group = 'jenkins' (default)
#
#
class jenkins(
  $version            = $jenkins::params::version,
  $lts                = $jenkins::params::lts,
  $repo               = $jenkins::params::repo,
  $package_name       = $jenkins::params::package_name,
  $direct_download    = $::jenkins::params::direct_download,
  $package_cache_dir  = $jenkins::params::package_cache_dir,
  $package_provider   = $jenkins::params::package_provider,
  $service_enable     = $jenkins::params::service_enable,
  $service_ensure     = $jenkins::params::service_ensure,
  $service_provider   = $jenkins::params::service_provider,
  $config_hash        = {},
  $plugin_hash        = {},
  $job_hash           = {},
  $user_hash          = {},
  $configure_firewall = false,
  $install_java       = $jenkins::params::install_java,
  $repo_proxy         = undef,
  $proxy_host         = undef,
  $proxy_port         = undef,
  $no_proxy_list      = undef,
  $cli                = true,
  $cli_ssh_keyfile    = undef,
  $cli_tries          = $jenkins::params::cli_tries,
  $cli_try_sleep      = $jenkins::params::cli_try_sleep,
  $port               = $jenkins::params::port,
  $libdir             = $jenkins::params::libdir,
  $manage_datadirs    = $jenkins::params::manage_datadirs,
  $localstatedir      = $::jenkins::params::localstatedir,
  $executors          = undef,
  $slaveagentport     = undef,
  $manage_user        = $::jenkins::params::manage_user,
  $user               = $::jenkins::params::user,
  $manage_group       = $::jenkins::params::manage_group,
  $group              = $::jenkins::params::group,
) inherits jenkins::params {

  validate_string($version)
  validate_bool($lts)
  validate_bool($repo)
  validate_string($package_name)
  validate_string($direct_download)
  validate_absolute_path($package_cache_dir)
  validate_string($package_provider)
  validate_bool($service_enable)
  validate_re($service_ensure, '^running$|^stopped$')
  validate_string($service_provider)
  validate_hash($config_hash)
  validate_hash($plugin_hash)
  validate_hash($job_hash)
  validate_hash($user_hash)
  validate_bool($configure_firewall)
  validate_bool($install_java)
  validate_string($repo_proxy)
  validate_string($proxy_host)
  if $proxy_port { validate_integer($proxy_port) }
  if $no_proxy_list { validate_array($no_proxy_list) }
  validate_bool($cli)
  if $cli_ssh_keyfile { validate_absolute_path($cli_ssh_keyfile) }
  validate_integer($cli_tries)
  validate_integer($cli_try_sleep)
  validate_integer($port)
  validate_absolute_path($libdir)
  validate_bool($manage_datadirs)
  validate_absolute_path($localstatedir)
  if $executors { validate_integer($executors) }
  if $slaveagentport { validate_integer($slaveagentport) }
  validate_bool($manage_user)
  validate_string($user)
  validate_bool($manage_group)
  validate_string($group)

  $plugin_dir = "${localstatedir}/plugins"
  $job_dir = "${localstatedir}/jobs"

  anchor {'jenkins::begin':}
  anchor {'jenkins::end':}

  if $install_java {
    include ::java
  }

  if $direct_download {
    $repo_ = false
    $jenkins_package_class = 'jenkins::direct_download'
  } else {
    $jenkins_package_class = 'jenkins::package'
    if $repo {
      $repo_ = true
      include jenkins::repo
    } else {
      $repo_ = false
    }
  }
  include $jenkins_package_class

  include jenkins::config
  include jenkins::plugins
  include jenkins::jobs
  include jenkins::users

  if $proxy_host and $proxy_port {
    class { 'jenkins::proxy':
      require => Package['jenkins'],
      notify  => Service['jenkins']
    }

    # param format needed by puppet/archive
    $proxy_server = "http://${jenkins::proxy_host}:${jenkins::proxy_port}"
  } else {
    $proxy_server = undef
  }


  include jenkins::service

  if defined('::firewall') {
    if $configure_firewall == undef {
      fail('The firewall module is included in your manifests, please configure $configure_firewall in the jenkins module')
    } elsif $configure_firewall {
      include jenkins::firewall
    }
  }

  if $cli {
    include jenkins::cli
    include jenkins::cli_helper
  }

  if $executors {
    jenkins::cli::exec { 'set_num_executors':
      command => ['set_num_executors', $executors],
      unless  => "[ \$(\$HELPER_CMD get_num_executors) -eq ${executors} ]"
    }

    Class['jenkins::cli'] ->
      Jenkins::Cli::Exec['set_num_executors'] ->
        Class['jenkins::jobs']
  }

  if ($slaveagentport != undef) {
    jenkins::cli::exec { 'set_slaveagent_port':
      command => ['set_slaveagent_port', $slaveagentport],
      unless  => "[ \$(\$HELPER_CMD get_slaveagent_port) -eq ${slaveagentport} ]"
    }

    Class['jenkins::cli'] ->
      Jenkins::Cli::Exec['set_slaveagent_port'] ->
        Class['jenkins::jobs']
  }

  Anchor['jenkins::begin'] ->
    Class[$jenkins_package_class] ->
      Class['jenkins::config'] ->
        Class['jenkins::plugins'] ~>
          Class['jenkins::service'] ->
            Class['jenkins::jobs'] ->
              Anchor['jenkins::end']

  if $install_java {
    Anchor['jenkins::begin'] ->
      Class['java'] ->
        Class[$jenkins_package_class] ->
          Anchor['jenkins::end']
  }

  if $repo_ {
    Anchor['jenkins::begin'] ->
      Class['jenkins::repo'] ->
        Class['jenkins::package'] ->
          Anchor['jenkins::end']
  }

  if $configure_firewall {
    Class['jenkins::service'] ->
      Class['jenkins::firewall'] ->
        Anchor['jenkins::end']
  }
}
# vim: ts=2 et sw=2 autoindent
