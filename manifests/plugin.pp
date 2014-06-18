#
# config_filename = undef
#   Name of the config file for this plugin.
#
# config_content = undef
#   Content of the config file for this plugin. It is up to the caller to
#   create this content from a template or any other mean.
#
# group_id = undef
#   allow overriding the default $jenkins::default_plugin_group_id
#
# core = false
#   Set to true for a core plugin (aka pinned plugin: https://wiki.jenkins-ci.org/display/JENKINS/Pinned+Plugins).
#   This is needed if you want to set a different version of a core plugin from the version hardcoded
#   within jenkins.
#
define jenkins::plugin(
  $version=0,
  $manage_config   = false,
  $config_filename = undef,
  $config_content  = undef,
  $group_id        = undef,
  $core            = undef,
) {

  $plugin            = "${name}.hpi"
  $plugin_dir        = '/var/lib/jenkins/plugins'
  $plugin_parent_dir = inline_template('<%= @plugin_dir.split(\'/\')[0..-2].join(\'/\') %>')
  validate_bool ($manage_config)

  if ($version != 0) {
    if ($jenkins::plugin_repository_maven_style) {
      if ($group_id) {
        $id = $group_id
      } else {
        $id = $jenkins::default_plugin_group_id
      }
      $group_id_path = regsubst( $id, '\.', '/', 'G' )
      $hpi_url = "${jenkins::plugin_repository_base_url}${group_id_path}/${name}/${version}/${name}-${version}.hpi"
    } else {
      $hpi_url = "${jenkins::plugin_repository_base_url}${name}/${version}/${name}.hpi"
    }
    $search   = "${name} ${version}(,|$)"
  }
  else {
    if ($jenkins::plugin_repository_maven_style) {
      fail('When using maven style plugin repository, plugin versions must be specified')
    } else {
      $hpi_url = "${jenkins::plugin_repository_base_url}latest/${name}.hpi"
      $search   = "${name} "
    }
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
      command    => "rm -rf ${name} ${name}.* && wget --no-check-certificate ${hpi_url} -O ${name}.hpi",
      cwd        => $plugin_dir,
      require    => [File[$plugin_dir], Package['wget']],
      path       => ['/usr/bin', '/usr/sbin', '/bin'],
    }

    if ($core) {
      # core plugins need to be pinned in order to update
      # see : https://wiki.jenkins-ci.org/display/JENKINS/Plugin+tutorial#Plugintutorial-Deployingacustombuildofacoreplugin
      file { "${plugin_dir}/${name}.hpi.pinned":
        ensure  => 'present',
        content => '',
        owner   => 'jenkins',
        mode    => '0644',
        # note: the download command cleans ${name}.* and therefore must be executed before this
        require => [Exec["download-${name}"],File["${plugin_dir}/${name}.hpi"]],
      }
    }

    file { "${plugin_dir}/${name}.hpi" :
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
