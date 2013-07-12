# == Define: jenkins::api_user
#
# Create an account within Jenkins that will subsequently be used for API
# access. No API token will be set as it needs to be hashed against a seed
# that it specific to that installation of Jenkins. You will need to
# subsequently generate a token through the Jenkins UI. The contents of the
# user config file will not be managed after initial creation to prevent
# conflicts with the Jenkins UI.
# 
# The name of the instance ($title) is used as the account name.
#
# === Parameters
#
# [*ensure*]
#   Standard ensure param. Can be used to remove an existing user.
#   Default: present
#
# [*users_dir*]
#   Directory that Jenkins keeps it's user configs. The default should be
#   fine for installations from the official packages.
#   Default: /var/lib/jenkins/users
#
define jenkins::api_user(
  $ensure = present,
  $users_dir = '/var/lib/jenkins/users'
) {
  $ensure_directory = $ensure ? {
    /^present$/ => directory,
    default     => absent,
  }

  File {
    owner  => 'jenkins',
    mode   => '0640',
    notify => Class['jenkins::service'],
  }

  file { "${users_dir}/${title}":
    ensure  => $ensure_directory,
    recurse => true,
    purge   => true,
    force   => true,
  }

  file { "${users_dir}/${title}/config.xml":
    ensure  => $ensure,
    content => template('jenkins/api_user.xml.erb'),
    replace => false,
  }
}
