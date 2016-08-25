#
# Support for directly downloading a package file - for when no repository
# is available
#
class jenkins::direct_download {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }
  validate_string($::jenkins::package_provider)
  validate_string($::jenkins::direct_download)
  validate_absolute_path($::jenkins::package_cache_dir)

  # directory for temp files
  file { $::jenkins::package_cache_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  # equivalent to basename() - get the filename
  $package_file = regsubst($::jenkins::direct_download, '(.*?)([^/]+)$', '\2')
  $local_file = "${::jenkins::package_cache_dir}/${package_file}"

  validate_absolute_path($local_file)

  if $::jenkins::version != 'absent' {
    # make download optional if we are removing...
    archive { $package_file:
      source       => $jenkins::direct_download,
      path         => $local_file,
      proxy_server => $::jenkins::proxy_server,
      cleanup      => false,
      extract      => false,
      before       => Package[$::jenkins::package_name],
    }
  }

  package { $::jenkins::package_name:
    ensure   => $::jenkins::version,
    provider => $::jenkins::package_provider,
    source   => $local_file,
  }
}
