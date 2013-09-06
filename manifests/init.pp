# Parameters:
# lts = 0  (Default)
#   Use the most up to date version of jenkins
#
# lts = 1
#   Use LTS verison of jenkins
#
# repo = 1 (Default)
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
# use_http_proxy = false
#   use an HTTP proxy to download plugins
#
# http_proxy_host
#   proxy host
#
# http_proxy_port
#   proxy port
#
# http_proxy_username
#   username for proxy
#
# http_proxy_password
#   password for proxy
#
# Example use
#
# class{ 'jenkins::config':
#   config_hash => {
#     'PORT' => { 'value' => '9090' }, 'AJP_PORT' => { 'value' => '9009' }
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
class jenkins(
  $version     = 'installed',
  $lts         = 0,
  $repo        = 1,
  $config_hash = undef,
  $plugin_hash = undef,
  $configure_firewall  = true,
  $use_http_proxy      = false,
  $http_proxy_host     = undef,
  $http_proxy_port     = undef,
  $http_proxy_username = undef,
  $http_proxy_password = undef,
) {
  anchor {'jenkins::begin':}
  anchor {'jenkins::end':}

  validate_bool ($use_http_proxy)
  if $use_http_proxy
      and ($http_proxy_host == undef or $http_proxy_port == undef) {
    fail 'To use proxy you must define $http_proxy_host and $http_proxy_port'
  } else {
    if !is_integer($http_proxy_port) {
      fail '$http_proxy_port should be an integer'
    }
    if $http_proxy_username != undef and $http_proxy_password == undef {
      fail 'if you have to authenticate to the proxy, you need to define both username and password'
    }
  }

  class {'jenkins::repo':
      lts  => $lts,
      repo => $repo;
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

  class {'jenkins::service':}

  if ($configure_firewall){
      class {'jenkins::firewall':}
    }

  Anchor['jenkins::begin'] ->
    Class['jenkins::repo'] ->
      Class['jenkins::package'] ->
        Class['jenkins::config'] ->
          Class['jenkins::plugins']~>
            Class['jenkins::service'] ->
                Anchor['jenkins::end']

  if $configure_firewall {
    Class['jenkins::service'] ->
      Class['jenkins::firewall'] ->
        Anchor['jenkins::end']
  }
}
# vim: ts=2 et sw=2 autoindent
