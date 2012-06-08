class jenkins($version = 'installed') {
  package {
    'jre':
        ensure => '1.7.0',
        noop   => true
  }
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
