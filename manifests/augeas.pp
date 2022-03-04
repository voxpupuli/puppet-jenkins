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
# [*show_diff*]:        Whether to display differences when the file changes, defaulting to true.
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
  String $config_filename,
  Variant[Array[String], String] $changes,
  Optional[Variant[Array[String], String]] $onlyif = undef,
  Optional[String] $plugin_version                 = undef,
  String $context                                  = '/',
  Variant[Boolean,String] $plugin                  = false,
  Boolean $restart                                 = false,
  Boolean $show_diff                               = true,
) {
  include jenkins
  include jenkins::cli

  case $plugin {
    true: {
      jenkins::plugin { $name:
        version => $plugin_version,
        before  => Augeas["jenkins::augeas: ${name}"],
      }
    }
    false: {
      # do nothing
    }
    default: {
      jenkins::plugin { $plugin:
        version => $plugin_version,
        before  => Augeas["jenkins::augeas: ${name}"],
      }
    }
  }

  if $restart {
    $notify_exec = 'safe-restart-jenkins'
  } else {
    $notify_exec = 'reload-jenkins'
  }

  augeas { "jenkins::augeas: ${name}":
    incl      => "${jenkins::localstatedir}/${config_filename}",
    lens      => 'Xml.lns',
    context   => regsubst("/files${jenkins::localstatedir}/${config_filename}/${context}", '\/{2,}', '/', 'G'),
    notify    => Exec[$notify_exec],
    onlyif    => $onlyif,
    changes   => $changes,
    show_diff => $show_diff,
  }
}
