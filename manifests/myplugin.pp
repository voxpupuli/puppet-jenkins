define jenkins::myplugin($version=0) {
  $plugin            = "${name}.hpi"
  $plugin_dir        = '/var/lib/jenkins/plugins'
  $plugin_parent_dir = '/var/lib/jenkins'

  if (!defined(File[$plugin_dir])) {
    file {
      [$plugin_parent_dir, $plugin_dir]:
        ensure  => directory,
        owner   => 'jenkins',
        group   => 'jenkins',
        require => [Group['jenkins'], User['jenkins']];
    }
  }

  if (!defined(Group['jenkins'])) {
    group {
      'jenkins' :
        ensure => present;
    }
  }

  if (!defined(User['jenkins'])) {
    user {
      'jenkins' :
        ensure => present;
    }
  }

  file { "${plugin_dir}/$plugin":
       ensure => 'present',
       path => "${plugin_dir}/$plugin",
        require  => File[$plugin_dir],
        owner     => 'jenkins',
        notify   => Service['jenkins'],
       source => "puppet:///modules/jenkins/$plugin",
       ;
  }
}
