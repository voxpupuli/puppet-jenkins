#
class jenkins::proxy (
  $host = undef,
  $port = undef,
) {

  file { '/var/lib/jenkins/proxy.xml':
    content => template('jenkins/proxy.xml.erb'),
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0644'
  }

}
