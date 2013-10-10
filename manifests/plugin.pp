#
#
#
define jenkins::plugin($version=0) {
  $plugin            = "${name}.hpi"
  $plugin_dir        = '/var/lib/jenkins/plugins'
  $plugin_parent_dir = '/var/lib/jenkins'
  $plugin_installed  = '/tmp/plugin-is-installed'

  if ($version != 0) {
    $base_url = "http://updates.jenkins-ci.org/download/plugins/${name}/${version}/"
  }
  else {
    $base_url = 'http://updates.jenkins-ci.org/latest/'
  }

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

  if (!defined(Package['wget'])) {
    package {
      'wget' :
        ensure => present;
    }
  }

  if (!defined(File[$plugin_installed])) {
    file {
      $plugin_installed :
        mode    => '0777',
        content => template("jenkins/plugin-is-installed.erb");
    }
  }

  exec {
    "download-${name}" :
      command    => "rm -rf ${name}* && wget --no-check-certificate ${base_url}${plugin}",
      cwd        => $plugin_dir,
      require    => [File[$plugin_dir], Package['wget'], File[$plugin_installed]],
      path       => ['/usr/bin', '/usr/sbin',],
      unless     => "bash ${plugin_installed} ${name} ${version}";
  }

  file {
    "${plugin_dir}/${plugin}" :
      require => Exec["download-${name}"],
      owner   => 'jenkins',
      mode    => '0644',
      notify  => Service['jenkins'];
  }
}
