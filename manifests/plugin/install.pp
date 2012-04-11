define jenkins::plugin::install($version=0) {
  $plugin     = "${name}.hpi"
  $plugin_parent_dir = '/var/lib/jenkins'
  $plugin_dir = '/var/lib/jenkins/plugins'

  if ($version != 0) {
    $base_url = "http://updates.jenkins-ci.org/download/plugins/${name}/${version}/"
  }
  else {
    $base_url   = 'http://updates.jenkins-ci.org/latest/'
  }

  if (!defined(File[$plugin_dir])) {
    file {
      [$plugin_parent_dir, $plugin_dir]:
        ensure => directory,
        owner  => 'jenkins',
        group  => 'jenkins';
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
        ensure => present,
        gid    => 'jenkins';
    }
  }

  exec {
    "download-${name}" :
      command  => "wget --no-check-certificate ${base_url}${plugin}",
      cwd      => $plugin_dir,
      require  => File[$plugin_dir],
      path     => ['/usr/bin', '/usr/sbin',],
      user     => 'jenkins',
      unless   => "test -f ${plugin_dir}/${plugin}",
      notify   => Service['jenkins'];
  }
}
