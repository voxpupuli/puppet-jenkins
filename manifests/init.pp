# Parameters:

# version = 'installed' (Default)
#   Will NOT update jenkins to the most recent version.
#
# version = 'latest'
#    Will automatically update the version of jenkins to the current version available via your package manager.
#
# lts = false  (Default)
#   Use the most up to date version of jenkins
#
# lts = true
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
#   package directly.  Leave as `false` (the default) to download using your
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
# executors = undef (Default)
#   Integer number of executors on the Jenkin's master.
#
# Example use
#
# class{ 'jenkins':
#   config_hash => {
#     'HTTP_PORT' => { 'value' => '9090' }, 'AJP_PORT' => { 'value' => '9009' }
#   }
# V
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
# configure_firewall = undef (default)
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
# cli = false (default)
#   - force installation of the jenkins CLI jar to $libdir/cli/jenkins-cli.jar
#   - the cli is automatically installed when needed by components that use it,
#     such as the user and credentials types, and the security class
#   - CLI installation (both implicit and explicit) requires the unzip command
#
#
# cli_tries = 10 (default)
#   Retries until giving up talking to jenkins API
#
#
# cli_try_sleep = 10 (default)
#   Seconds between tries to contact jenkins API
#
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
#
class jenkins(
  $version            = $jenkins::params::version,
  $lts                = $jenkins::params::lts,
  $repo               = $jenkins::params::repo,
  $package_name       = $jenkins::params::package_name,
  $direct_download    = false,
  $package_cache_dir  = $jenkins::params::package_cache_dir,
  $package_provider   = $jenkins::params::package_provider,
  $service_enable     = $jenkins::params::service_enable,
  $service_ensure     = $jenkins::params::service_ensure,
  $config_hash        = {},
  $plugin_hash        = {},
  $job_hash           = {},
  $configure_firewall = undef,
  $install_java       = $jenkins::params::install_java,
  $proxy_host         = undef,
  $proxy_port         = undef,
  $no_proxy_list      = undef,
  $cli                = undef,
  $cli_tries          = $jenkins::params::cli_tries,
  $cli_try_sleep      = $jenkins::params::cli_try_sleep,
  $port               = $jenkins::params::port,
  $libdir             = $jenkins::params::libdir,
  $executors          = undef,
) inherits jenkins::params {

  validate_bool($lts, $install_java, $repo)
  validate_hash($config_hash, $plugin_hash)

  if $configure_firewall {
    validate_bool($configure_firewall)
  }

  if $no_proxy_list {
    validate_array($no_proxy_list)
  }

  if $executors {
    validate_integer($executors)
  }

  anchor {'jenkins::begin':}
  anchor {'jenkins::end':}

  if $install_java {
    class {'java':
      distribution => 'jdk'
    }
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

  if $proxy_host and $proxy_port {
    class { 'jenkins::proxy':
      require => Package['jenkins'],
      notify  => Service['jenkins']
    }
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
    include jenkins::cli::reload
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

  Anchor['jenkins::begin'] ->
    Class[$jenkins_package_class] ->
      Class['jenkins::config'] ->
        Class['jenkins::plugins'] ~>
          Class['jenkins::service'] ->
            Class['jenkins::jobs'] ->
              Anchor['jenkins::end']

  if $cli {
    Anchor['jenkins::begin'] ->
      Class['jenkins::service'] ->
        Class['jenkins::cli'] ->
          Class['jenkins::cli::reload'] ->
            Class['jenkins::jobs'] ->
              Anchor['jenkins::end']
  }

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
