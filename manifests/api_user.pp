# == Define: jenkins::api_user
#
# Create an account within Jenkins and set it's API token to a pre-hashed
# value. Unfortunately the Jenkins API doesn't expose the ability to
# create/modify users, so this is a bit of a hack. The configurations are
# owned by root:root to prevent them from being modified in the Jenkins UI.
#
# === Parameters
#
# [*token_hash*]
#   Hashed token that will be written to the user's `config.xml`.
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
  $token_hash,
  $ensure = present,
  $users_dir = '/var/lib/jenkins/users'
) {
  $ensure_directory = $ensure ? {
    /^present$/ => directory,
    default     => absent,
  }

  File {
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
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
  }
}
