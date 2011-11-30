# This is an example of how to use this module
# in your node definitions and enable the Git plugin

# Define the site:jenkins class where resources and classes are composed in
# manner specific to a single site where Puppet is deployed.
class site::jenkins {

  # Declare the jenkins module in the catalog
  class { 'jenkins': }

  # Add the class managing the git plugin.
  class { 'jenkins::git':
    require => Class['jenkins::package'],
    notify  => Class['jenkins::service'],
  }
}

node default {
  # Classify all nodes with the site specific jenkins class.
  class { 'site::jenkins': }
}

# EOF
