class jenkins {
  package {
    'jre':
        ensure => '1.7.0',
        noop   => true
  }
  include jenkins::repo
  include jenkins::package
  include jenkins::service
  include jenkins::firewall

  Class['jenkins::repo'] -> Class['jenkins::package']
  -> Class['jenkins::service']
}
# vim: ts=2 et sw=2 autoindent
