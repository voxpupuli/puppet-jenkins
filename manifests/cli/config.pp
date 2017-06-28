# == Class: jenkins::cli::config
#
# This class provides configuration values to override defaults and fact data
# for PuppetX::Jenkins::Provider::Clihelper based providers.
#
# Default and fact data is managed internal to the
# PuppetX::Jenkins::Provider::Clihelper class for compatiblity with the puppet
# resource face.  No defaults should be set in this classes definition.
class jenkins::cli::config(
  Optional[String] $url                           = undef,
  Optional[String] $ssh_private_key_content       = undef,
  Optional[Stdlib::Absolutepath] $cli_jar         = undef,
  Optional[Stdlib::Absolutepath] $ssh_private_key = undef,
  Optional[Stdlib::Absolutepath] $puppet_helper   = undef,
  Optional[Integer] $cli_tries                    = undef,
  Optional[Numeric] $cli_try_sleep                = undef,
) {

  if str2bool($::is_pe) {
    $gem_provider = 'pe_gem'
  } elsif $::puppetversion
      and (versioncmp($::puppetversion, '4.0.0') >= 0)
      and $::rubysitedir
      and ('/opt/puppetlabs/puppet/lib/ruby' in $::rubysitedir) {
    # AIO puppet
    $gem_provider = 'puppet_gem'
  } else {
    $gem_provider = 'gem'
  }

  # required by PuppetX::Jenkins::Provider::Clihelper base
  if ! defined(Package['retries']) {
    package { 'retries':
      provider => $gem_provider,
    }
  }

  if $ssh_private_key and $ssh_private_key_content {
    file { $ssh_private_key:
      ensure  => 'file',
      mode    => '0400',
      backup  => false,
      content => $ssh_private_key_content,
    }

    # allow this class to be included when not running as root
    if $::id == 'root' {
      File[$ssh_private_key] {
        # the owner/group should probably be set externally and retrieved if
        # present in the manfiest. At present, there is no authoritative place
        # to retrive this information from.
        owner => 'jenkins',
        group => 'jenkins',
      }
    }
  }
}
