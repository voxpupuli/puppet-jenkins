class jenkins($version = 'installed') {
  include jenkins::repo
  class {
    'jenkins::package':
      version => $version,
  }
  include jenkins::service
  include jenkins::firewall

  Class['jenkins::repo'] -> Class['jenkins::package']
  -> Class['jenkins::service']
}
# vim: ts=2 et sw=2 autoindent
