#
#
#
define jenkins::plugin($version=0, $plugin_owner='jenkins', $plugin_group='jenkins') {
  $plugin            = "${name}.hpi"
  $plugin_dir        = '/var/lib/jenkins/plugins'
  $plugin_parent_dir = '/var/lib/jenkins'

  if ($version != 0) {
    $base_url = "http://updates.jenkins-ci.org/download/plugins/${name}/${version}/"
    $search   = "${name} ${version},"
  }
  else {
    $base_url = 'http://updates.jenkins-ci.org/latest/'
    $search   = "${name} "
  }

  if (!defined(File[$plugin_dir])) {
    file {
      [$plugin_parent_dir, $plugin_dir]:
        ensure  => directory,
        owner   => $plugin_owner,
        group   => $plugin_group,
        require => [Group['jenkins'], User['jenkins']];
    }
  }

  if (!defined(Group[$plugin_group])) {
    group {
      $plugin_group :
        ensure  => present,
        require => Package['jenkins'];
    }
  }

  if (!defined(User[$plugin_owner])) {
    user {
      $plugin_owner :
        ensure  => present,
        home    => $plugin_parent_dir,
        require => Package['jenkins'];
    }
  }

  if (!defined(Package['wget'])) {
    package {
      'wget' :
        ensure => present;
    }
  }

  if (empty(grep([ $::jenkins_plugins ], $search))) {
    exec {
      "download-${name}" :
        command    => "rm -rf ${name} ${name}.* && wget --no-check-certificate ${base_url}${plugin}",
        cwd        => $plugin_dir,
        require    => [File[$plugin_dir], Package['wget']],
        path       => ['/usr/bin', '/usr/sbin', '/bin'];
    }

    file {
      "${plugin_dir}/${plugin}" :
        require => Exec["download-${name}"],
        owner   => 'jenkins',
        mode    => '0644',
        notify  => Service['jenkins'];
    }
  }

}
