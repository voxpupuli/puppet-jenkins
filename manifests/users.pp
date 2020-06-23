# @summary Create Jenkins users
# @api private
class jenkins::users {
  assert_private()

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $_bootstrap_users = $::jenkins::bootstrapuser_hash
  $_authentication_realm = $::jenkins::authentication_realm

  if $::jenkins::manage_bootstrapping {
    if empty($_bootstrap_users) {
      $_bootstrap_groovy_ensure = absent
    } else {
      $_bootstrap_groovy_ensure = present
    }
  } else {
    $_bootstrap_groovy_ensure = absent
  }

  file { "${::jenkins::jenkins_home}/init.groovy.d/puppet.bootstrapping.groovy":
    ensure    => $_bootstrap_groovy_ensure,
    owner     => $::jenkins::user,
    group     => $::jenkins::group,
    mode      => '0640',
    tag       => 'jenkins_groovy_init_script',
    show_diff => false,
    content   => template('jenkins/home/jenkins/init.groovy.d/puppet.bootstrapping.groovy.erb'),
  }

  create_resources('jenkins::user', $::jenkins::user_hash)

}
