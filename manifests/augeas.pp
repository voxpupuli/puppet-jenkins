# == Definition jenkins::augeas
#
# === Parameters:
#
# [*config_filename*]:  Filename of the configuration file to work on relative to the jenkins localstatedir.
#
# [*changes*]:          String or array with augeas changes to perform.
#
# [*onlyif*]:           Optional augeas command and comparisons to control the execution of this type.
#
# [*plugin*]:           Optionally jenkins::augeas can also install the plugin. If this is set to true,
#                       we use the name of the resource as plugin name. If it's a string, that is used
#                       as plugin name.
#
# [*plugin_version*]:   Optional plugin version to pass through to jenkins::plugin
#
# [*context*]:          Optional context to ease your change rules.
#
# [*restart*]:          If set to true, will trigger a jenkins (safe-)restart in stead of reloading
#                       the configuration.
#
# === Example:
#
#     jenkins::augeas {'git':
#       plugin          => true,
#       config_filename => 'hudson.plugins.git.GitSCM.xml',
#       context         => '/hudson.plugins.git.GitSCM_-DescriptorImpl',
#       changes         => [
#         'set globalConfigName/#text "Bob the Builder"',
#         'set globalConfigEmail/#text "bob@example.com",
#       ],
#     }
#
#
#
define jenkins::augeas (
  $config_filename,
  $changes,
  $onlyif           = undef,
  $context          = '/',
  $plugin_version   = undef,
  $plugin           = false,
  $restart          = false,
) {
  validate_string($config_filename)
  if ! is_string($changes) and ! is_array($changes) {
    fail('$changes must be string or array.')
  }
  if ! is_string($onlyif) and ! is_array($onlyif) {
    fail('$onlyif must be string or array.')
  }
  validate_string($context)
  validate_string($plugin_version)
  if ! is_bool($plugin) and ! is_string($plugin) {
    fail('$plugin must be bool or string.')
  }
  validate_bool($restart)

  include ::jenkins
  include ::jenkins::cli


  case $plugin {
    true: {
      jenkins::plugin {$name:
        version       => $plugin_version,
        manage_config => false,
        before        => Augeas["jenkins::augeas: ${name}"],
      }
    }
    false: {
      # do nothing
    }
    default: {
      jenkins::plugin {$plugin:
        version       => $plugin_version,
        manage_config => false,
        before        => Augeas["jenkins::augeas: ${name}"],
      }
    }
  }

  if $restart {
      $notify_exec = 'safe-restart-jenkins'
  } else {
      $notify_exec = 'reload-jenkins'
  }

  augeas {"jenkins::augeas: ${name}":
    incl    => "${::jenkins::localstatedir}/${config_filename}",
    lens    => 'Xml.lns',
    context => regsubst("/files${::jenkins::localstatedir}/${config_filename}/${context}", '\/{2,}', '/', 'G'),
    notify  => Exec[$notify_exec],
    onlyif  => $onlyif,
    changes => $changes,
  }

}
