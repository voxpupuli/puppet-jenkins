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
# Example use
#
# class{ 'jenkins::config':
#   config_hash => {
#     'PORT' => { 'value' => '9090' }, 'AJP_PORT' => { 'value' => '9009' }
#   }
# }
# The config hash on opensuse has a prefix JENKINS_ (JENKINS_PORT)
# 
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
) {

  class {
    'jenkins::repo':
      lts  => $lts,
      repo => $repo;

    'jenkins::package' :
      version => $version;
  }

  class { 'jenkins::config':
      config_hash => $config_hash,
  }

  class { 'jenkins::plugins':
      plugin_hash => $plugin_hash,
  }

  include jenkins::service
  include jenkins::firewall

  Class['jenkins::repo'] ->
    Class['jenkins::package'] ->
      Class['jenkins::config'] ~>
        Class['jenkins::service']
}

# vim: ts=2 et sw=2 autoindent
