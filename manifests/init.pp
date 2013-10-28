# Parameters:

# version = 'installed' (Default)
#   Will NOT update jenkins to the most recent version.
# version = 'latest'
#    Will automatically update the version of jenkins to the current version available via your pacakge manager.
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
# configure_firewall = true (default)
#   For folks that want to manage the puppetlabs firewall module.
#    -  If it's not present, it will not be installed and nothing happens
#    - This default could change in the future.
#
#
# installl_java = true (Default)
#   - use puppetlabs-java module to install the correct version of a JDK.
#   - Jenkins requires a JRE
#
class jenkins(
  $version            = $jenkins::params::version,
  $lts                = $jenkins::params::lts,
  $repo               = $jenkins::params::repo,
  $config_hash        = undef,
  $plugin_hash        = undef,
  $configure_firewall = $jenkins::params::configure_firewall,
  $install_java       = $jenkins::params::install_java,
  $proxy_host         = undef,
  $proxy_port         = undef,
) inherits jenkins::params {

  $lts_real = str2bool($lts)
  $java_real = str2bool($install_java)
  $repo_real = str2bool($repo)
  $firewall_real = str2bool($configure_firewall)

  anchor {'jenkins::begin':}
  anchor {'jenkins::end':}

  if $java_real {
    class {'java':
      distribution => 'jdk'
    }
  }

  if $repo_real {
    class {'jenkins::repo':}
  }

  class {'jenkins::package' :
    version => $version;
  }

  class { 'jenkins::config':
    config_hash => $config_hash,
  }

  class { 'jenkins::plugins':
    plugin_hash => $plugin_hash,
  }

  if $proxy_host {
    class { 'jenkins::proxy':
      host    => $proxy_host,
      port    => $proxy_port,
      require => Package['jenkins'],
      notify  => Service['jenkins']
    }
  }

  class {'jenkins::service':}

  if $firewall_real {
    class {'jenkins::firewall':}
  }

  Anchor['jenkins::begin'] ->
    Class['jenkins::package'] ->
      Class['jenkins::config'] ->
        Class['jenkins::plugins']~>
          Class['jenkins::service'] ->
              Anchor['jenkins::end']

  if $java_real {
    Anchor['jenkins::begin'] ->
      Class['java'] ->
        Class['jenkins::package'] ->
          Anchor['jenkins::end']
  }

  if $repo_real {
    Anchor['jenkins::begin'] ->
      Class['jenkins::repo'] ->
        Class['jenkins::package'] ->
          Anchor['jenkins::end']
  }

  if $firewall_real {
    Class['jenkins::service'] ->
      Class['jenkins::firewall'] ->
        Anchor['jenkins::end']
  }
}
# vim: ts=2 et sw=2 autoindent
