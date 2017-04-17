# Class: jenkins::repo::el
#
class jenkins::repo::el
{

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $repo_proxy = $::jenkins::repo_proxy

  if ($::operatingsystemmajrelease == '5'){
    exec { 'EL5 Jenkins Key Workaround':
      command  => 'rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key',
      unless   => "rpm -qa --nodigest --nosignature --qf '%{VERSION}-%{RELEASE} %{SUMMARY}\n' | grep d50582e6",
      path     => ['/bin', '/usr/bin'],
    }

    Exec['EL5 Jenkins Key Workaround'] -> Yumrepo['jenkins']
  }

  if $::jenkins::lts  {
    yumrepo {'jenkins':
      descr    => 'Jenkins',
      baseurl  => 'http://pkg.jenkins-ci.org/redhat-stable/',
      gpgcheck => 1,
      gpgkey   => 'http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key',
      enabled  => 1,
      proxy    => $repo_proxy,
    }
  }

  else {
    yumrepo {'jenkins':
      descr    => 'Jenkins',
      baseurl  => 'http://pkg.jenkins-ci.org/redhat/',
      gpgcheck => 1,
      gpgkey   => 'http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key',
      enabled  => 1,
      proxy    => $repo_proxy,
    }
  }
}
