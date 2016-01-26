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
) {

  include ::jenkins

  validate_string($config_filename)
  validate_string($context)

  # validate $plugin embedded in case.

  if $plugin_version { validate_string($plugin_version) }

  # changes and onlyif can be both a string or an array...
  if ! is_string($onlyif) { validate_array($onlyif) }
  if ! is_string($changes) { validate_array($changes) }

  case $plugin {
    true,'true': { # lint:ignore:quoted_booleans
      jenkins::plugin {$name:
        version       => $plugin_version,
        manage_config => false,
        before        => Augeas["jenkins::augeas: ${name}"],
      }
    }
    false,'false': { # lint:ignore:quoted_booleans
      #do nothing
    }
    default: {
      validate_string($plugin)

      jenkins::plugin {$plugin:
        version       => $plugin_version,
        manage_config => false,
        before        => Augeas["jenkins::augeas: ${name}"],
      }
    }
  }

  augeas {"jenkins::augeas: ${name}":
    incl    => "${::jenkins::localstatedir}/${config_filename}",
    lens    => 'Xml.lns',
    context => regsubst("/files${::jenkins::localstatedir}/${config_filename}/${context}", '\/\/', '/'),
    notify  => Exec['reload-jenkins'],
    onlyif  => $onlyif,
    changes => $changes,
  }


}
