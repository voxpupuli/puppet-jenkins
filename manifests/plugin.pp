#
# config_filename = undef
#   Name of the config file for this plugin.
#
# config_content = undef
#   Content of the config file for this plugin. It is up to the caller to
#   create this content from a template or any other mean.
#
define jenkins::plugin(
  $version=0,
  $manage_config   = false,
  $config_filename = undef,
  $config_content  = undef,
) {

  $plugin            = "${name}.hpi"
  $plugin_dir        = '/var/lib/jenkins/plugins'
  $plugin_parent_dir = inline_template('<%= @plugin_dir.split(\'/\')[0..-2].join(\'/\') %>')
  validate_bool ($manage_config)

  if ($version != 0) {
    $base_url = "http://updates.jenkins-ci.org/download/plugins/${name}/${version}/"
    $search   = "${name} ${version}(,|$)"
  }
  else {
    $base_url = 'http://updates.jenkins-ci.org/latest/'
    $search   = "${name} "
  }

  if (!defined(File[$plugin_dir])) {
    file { [$plugin_parent_dir, $plugin_dir]:
      ensure  => directory,
      owner   => 'jenkins',
      group   => 'jenkins',
      mode    => '0755',
      require => [Group['jenkins'], User['jenkins']],
    }
  }

  if (!defined(Group['jenkins'])) {
    group { 'jenkins' :
      ensure  => present,
      require => Package['jenkins'],
    }
  }

  if (!defined(User['jenkins'])) {
    user { 'jenkins' :
      ensure  => present,
      home    => $plugin_parent_dir,
      require => Package['jenkins'],
    }
  }

  if (!defined(Package['wget'])) {
    package { 'wget' :
      ensure => present,
    }
  }

  if (empty(grep([ $::jenkins_plugins ], $search))) {

    if ($jenkins::proxy_host){
      Exec {
        environment => [
          "http_proxy=${jenkins::proxy_host}:${jenkins::proxy_port}",
          "https_proxy=${jenkins::proxy_host}:${jenkins::proxy_port}"
        ]
      }
    }

    exec { "download-${name}" :
      command    => "rm -rf ${name} ${name}.* && wget --no-check-certificate ${base_url}${plugin}",
      cwd        => $plugin_dir,
      require    => [File[$plugin_dir], Package['wget']],
      path       => ['/usr/bin', '/usr/sbin', '/bin'],
    }

    file { "${plugin_dir}/${plugin}" :
      require => Exec["download-${name}"],
      owner   => 'jenkins',
      mode    => '0644',
      notify  => Service['jenkins'],
    }
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
