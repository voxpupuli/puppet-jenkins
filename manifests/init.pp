# Parameters:

# version = 'installed' (Default)
#   Will NOT update jenkins to the most recent version.
# version = 'latest'
#    Will automatically update the version of jenkins to the current version available via your package manager.
#
# lts = false  (Default)
#   Use the most up to date version of jenkins
#
# lts = true
#   Use LTS verison of jenkins
#
# repo = true (Default)
#   install the jenkins repo.
#
# repo = 0
#   Do NOT install a repo. This means you'll manage a repo manually outside
#   this module.
#   This is for folks that use a custom repo, or the like.
#
# config_hash = undef (Default)
# Hash with config options to set in sysconfig/jenkins defaults/jenkins
#
# Example use
#
# class{ 'jenkins::config':
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
#     'git' -> { version => '1.1.1' },
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
class jenkins(
  $version            = $jenkins::params::version,
  $lts                = $jenkins::params::lts,
  $repo               = $jenkins::params::repo,
  $service_enable     = $jenkins::params::service_enable,
  $service_ensure     = $jenkins::params::service_ensure,
  $config_hash        = {},
  $plugin_hash        = {},
  $configure_firewall = undef,
  $install_java       = $jenkins::params::install_java,
  $proxy_host         = undef,
  $proxy_port         = undef,
  $cli                = undef,
) inherits jenkins::params {

  validate_bool($lts, $install_java, $repo)
  validate_hash($config_hash, $plugin_hash)

  if $configure_firewall {
    validate_bool($configure_firewall)
  }

  anchor {'jenkins::begin':}
  anchor {'jenkins::end':}

  if $install_java {
    class {'java':
      distribution => 'jdk'
    }
  }

  if $repo {
    class {'jenkins::repo':}
  }

  class {'jenkins::package': }

  class { 'jenkins::config': }

  class { 'jenkins::plugins': }

  if $proxy_host and $proxy_port {
    class { 'jenkins::proxy':
      require => Package['jenkins'],
      notify  => Service['jenkins']
    }
  }

  class {'jenkins::service':}

  if defined('::firewall') {
    if $configure_firewall == undef {
      fail('The firewall module is included in your manifests, please configure $configure_firewall in the jenkins module')
    } elsif $configure_firewall {
      class {'jenkins::firewall':}
    }
  }
  if $cli {
    class {'jenkins::cli':}
  }

  Anchor['jenkins::begin'] ->
    Class['jenkins::package'] ->
      Class['jenkins::config'] ->
        Class['jenkins::plugins']~>
          Class['jenkins::service'] ->
              Anchor['jenkins::end']

  if $install_java {
    Anchor['jenkins::begin'] ->
      Class['java'] ->
        Class['jenkins::package'] ->
          Anchor['jenkins::end']
  }

  if $repo {
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
