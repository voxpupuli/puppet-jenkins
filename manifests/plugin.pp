#
# config_filename = undef
#   Name of the config file for this plugin.
#
# config_content = undef
#   Content of the config file for this plugin. It is up to the caller to
#   create this content from a template or any other mean.
#
define jenkins::plugin (
  $version         = 0,
  $manage_config   = false,
  $config_filename = undef,
  $config_content  = undef,
) {
  $plugin            = "${name}.hpi"
  $plugin_dir        = '/var/lib/jenkins/plugins'
  $plugin_parent_dir = '/var/lib/jenkins'
  validate_bool ($manage_config)

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
        ensure  => present,
        require => Package['jenkins'];
    }
  }

  if (!defined(User['jenkins'])) {
    user {
      'jenkins' :
        ensure  => present,
        require => Package['jenkins'];
    }
  }

  if (!defined(Package['wget'])) {
    package {
      'wget' :
        ensure => present;
    }
  }

  exec {
    "download-${name}" :
      command    => "wget --no-check-certificate ${base_url}${plugin}",
      cwd        => $plugin_dir,
      require    => [File[$plugin_dir], Package['wget']],
      path       => ['/usr/bin', '/usr/sbin',],
      unless     => "test -f ${plugin_dir}/${name}.hpi || test -f ${plugin_dir}/${name}.jpi",
  }

  file {
    "${plugin_dir}/${plugin}" :
      require => Exec["download-${name}"],
      owner   => 'jenkins',
      mode    => '0644',
      notify  => Service['jenkins']
  }
  
  if $manage_config {
    if $config_filename == undef or $config_content == undef {
      fail 'To deploy config file for plugin, you need to specify both $config_filename and $config_content'
    }

    file {"${plugin_parent_dir}/${config_filename}":
      ensure  => present,
      content => $config_content,
      owner   => 'jenkins',
      group   => 'jenkins',
      mode    => '0644',
      notify  => Service['jenkins']
    }
  }
}
