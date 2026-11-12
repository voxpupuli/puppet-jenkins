# @summary Default parameters
# @api private
class jenkins::params {
  $swarm_version = '2.2'
  $config_hash_defaults = {
    'JAVA_OPTS' => { value => '-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false -Dhudson.cli.CLIAction.ACCEPT_URL_FROM_REQUEST=true' },
  }
  $default_plugins = [
    'bouncycastle-api', # required by instance-identity
    'commons-lang3-api', # required by credentials plugin
    'commons-text-api', # required by credentials plugin
    'credentials', # required by puppet_helper.groovy
    'ionicons-api', # required by credentials plugin
    'instance-identity', # implied by structs
    'javax-activation-api', # implied by all plugin
    'javax-mail-api', # implied by all plugins
    'structs', # required by credentials plugin
  ]

  case $facts['os']['family'] {
    'Debian': {
      $repo                 = true
      $package_provider     = 'dpkg'
    }
    'RedHat': {
      $repo                 = true
      $package_provider     = 'rpm'
    }
    'Archlinux': {
      $repo                 = false
      $package_provider     = 'pacman'
    }
    default: {
      $repo                 = true
      $package_provider     = undef
    }
  }
}
