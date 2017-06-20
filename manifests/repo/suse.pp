# Class: jenkins::repo::suse
#
class jenkins::repo::suse
{

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $::jenkins::lts {
    zypprepo {'jenkins':
      descr    => 'Jenkins',
      baseurl  => 'https://pkg.jenkins.io/opensuse-stable/',
      gpgcheck => 1,
      gpgkey   => 'https://pkg.jenkins.io/redhat/jenkins-ci.org.key',
    }
  } else {
    zypprepo {'jenkins':
      descr    => 'Jenkins',
      baseurl  => 'https://pkg.jenkins.io/opensuse/',
      gpgcheck => 1,
      gpgkey   => 'https://pkg.jenkins.io/redhat/jenkins-ci.org.key',
    }
  }
}
