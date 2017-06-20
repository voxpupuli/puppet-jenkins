# Class: jenkins::repo::el
#
class jenkins::repo::el
{

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $repo_proxy = $::jenkins::repo_proxy

  if $::jenkins::lts  {
    yumrepo {'jenkins':
      descr    => 'Jenkins',
      baseurl  => 'https://pkg.jenkins.io/redhat-stable/',
      gpgcheck => 1,
      gpgkey   => 'https://pkg.jenkins.io/redhat/jenkins-ci.org.key',
      enabled  => 1,
      proxy    => $repo_proxy,
    }
  }

  else {
    yumrepo {'jenkins':
      descr    => 'Jenkins',
      baseurl  => 'https://pkg.jenkins.io/redhat/',
      gpgcheck => 1,
      gpgkey   => 'https://pkg.jenkins.io/redhat/jenkins-ci.org.key',
      enabled  => 1,
      proxy    => $repo_proxy,
    }
  }
}
