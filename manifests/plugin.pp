#
# config_filename = undef
#   Name of the config file for this plugin.
#
# config_content = undef
#   Content of the config file for this plugin. It is up to the caller to
#   create this content from a template or any other mean.
#
# update_url = undef
#   
define jenkins::plugin(
  $version         = 0,
  $manage_config   = false,
  $config_filename = undef,
  $config_content  = undef,
  $update_url      = undef,
) {
  include ::jenkins::params

  $plugin            = "${name}.hpi"
  $plugin_dir        = '/var/lib/jenkins/plugins'
  $plugin_parent_dir = inline_template('<%= @plugin_dir.split(\'/\')[0..-2].join(\'/\') %>')
  validate_bool($manage_config)
  # TODO: validate_str($update_url)

  if ($version != 0) {
    $plugins_host = $update_url ? {
      undef   => $::jenkins::params::default_plugins_host,
      default => $update_url,
    }
    $base_url = "${plugins_host}/download/plugins/${name}/${version}/"
    $search   = "${name} ${version}(,|$)"
  }
  else {
    $plugins_host = $update_url ? {
      undef   => $::jenkins::params::default_plugins_host,
      default => $update_url,
    }
    $base_url = "${plugins_host}/latest/"
    $search   = "${name} "
  }

  if (!defined(File[$plugin_dir])) {
    if (!defined(File[$plugin_parent_dir])) {
      file { $plugin_parent_dir:
        ensure  => directory,
        owner   => 'jenkins',
        group   => 'jenkins',
        mode    => '0755',
        require => [Group['jenkins'], User['jenkins']],
      }
    }

    file { $plugin_dir:
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
    if ($jenkins::proxy_host) {
      Exec {
        environment => [
          "http_proxy=${jenkins::proxy_host}:${jenkins::proxy_port}",
          "https_proxy=${jenkins::proxy_host}:${jenkins::proxy_port}"
        ]
      }
    }

    # create a pinned file if the plugin has a .jpi extension
    #   to override the builtin module versions
    exec { "create-pinnedfile-${name}" :
      command => "touch ${plugin_dir}/${name}.jpi.pinned",
      cwd     => $plugin_dir,
      require => File[$plugin_dir],
      path    => ['/usr/bin', '/usr/sbin', '/bin'],
      onlyif  => "test -f ${plugin_dir}/${name}.jpi -a ! -f ${plugin_dir}/${name}.jpi.pinned",
      before  => Exec["download-${name}"],
    }


    exec { "download-${name}" :
      command => "rm -rf ${name} ${name}.hpi ${name}.jpi && wget --no-check-certificate ${base_url}${plugin}",
      cwd     => $plugin_dir,
      require => [File[$plugin_dir], Package['wget']],
      path    => ['/usr/bin', '/usr/sbin', '/bin'],
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

