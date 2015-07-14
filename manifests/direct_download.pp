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
    $enable_checksum = $::jenkins::direct_download_checksum ? {
      undef   => false,
      default => true,
    }

    # make download optional if we are removing...
    archive::download { $package_file:
      url              => $::jenkins::direct_download,
      src_target       => $::jenkins::package_cache_dir,
      allow_insecure   => true,
      follow_redirects => true,
      checksum         => $enable_checksum,
      digest_string    => $::jenkins::direct_download_checksum,
      digest_type      => $::jenkins::direct_download_checksum_type,
      proxy_server     => $::jenkins::http_proxy,
      verbose          => false,
      require          => File[$::jenkins::package_cache_dir],
      before           => Package[$::jenkins::package_name],
    }
  }

  package { $::jenkins::package_name:
    ensure   => $::jenkins::version,
    provider => $::jenkins::package_provider,
    source   => $local_file,
  }
}
