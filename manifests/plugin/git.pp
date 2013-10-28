class jenkins::plugin::git (
  $version            = 0,
  $manage_config      = false,
  $config_filename    = 'hudson.plugins.git.GitSCM.xml',
  $config_content     = undef,
  $git_name           = 'Jenkins',
  $git_email          = 'jenkins@example.net',
  $git_create_account = false,) {
  validate_bool($git_create_account)

  if $config_content == undef {
    $real_content = template('jenkins/plugin/git.config.xml.erb')
  } else {
    $real_content = $config_content
  }

  jenkins::plugin { 'git':
    version         => $version,
    manage_config   => $manage_config,
    config_filename => $config_filename,
    config_content  => $real_content,
  }
}