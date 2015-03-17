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
  if $::jenkins::version {
    validate_string($::jenkins::version)  
  }

  # stdlib 4.6 has 'basename'
  #$package_file = basename($::jenkins::download_url)
  $package_file = regsubst($::jenkins::direct_download, '(.*?)([^/]+)$', '\2')
  $local_file = "${::jenkins::package_cache_dir}/${package_file}"
  
  validate_absolute_path($local_file)

  if $::jenkins::version {
    # make download optional if we are removing...
    staging::file { $package_file:
      source  => $jenkins::direct_download,
      target  => $local_file,
      before  => Package[$::jenkins::package_name],
    }
  } 
  
  package { $::jenkins::package_name:
    ensure   => $::jenkins::version,
    provider => $::jenkins::package_provider,
    source   => $local_file,
  } 
}
