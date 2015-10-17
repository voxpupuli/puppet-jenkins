# This class should be considered private
#
class jenkins::config {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  create_resources( 'jenkins::sysconfig', $::jenkins::config_hash )

  $dir_params = {
    ensure => directory,
    owner  => $::jenkins::user,
    group  => $::jenkins::group,
    mode   => '0755',
  }

  # ensure_resource is used to try to maintain backwards compatiblity with
  # manifests that were able to external declare resources due to the
  # old conditional behavior of jenkins::plugin
  if $::jenkins::manage_user {
    ensure_resource('user', $::jenkins::user, {
      ensure     => present,
      gid        => $::jenkins::group,
      home       => $::jenkins::localstatedir,
      managehome => false,
      system     => true,
    })
  }

  if $::jenkins::manage_group {
    ensure_resource('group', $::jenkins::group, {
      ensure => present,
      system => true,
    })
  }
  # Allow users to set jenkins home to a link in order to allow for NFS or 
  # other remote file mounts to symlink to the directory. 
  if $::jenkins::localstatedir_type == 'directory' {
    ensure_resource('file', $::jenkins::localstatedir, $dir_params)
  }
  elsif $::jenkins::localstatedir_type == 'link' {
    $link_params = {
      ensure => link,
      target => $::jenkins::localstatedir_link,
      owner  => $::jenkins::user,
      group  => $::jenkins::group,
      mode   => '0755',
    }
    ensure_resource('file',  $::jenkins::localstatedir, $link_params)
  }

  ensure_resource('file', $::jenkins::plugin_dir, $dir_params)
  ensure_resource('file', $::jenkins::job_dir, $dir_params)
}
