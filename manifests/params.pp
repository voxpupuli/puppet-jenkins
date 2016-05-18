# Class: jenkins::params
# for windows - install_java set to false because of https://tickets.puppetlabs.com/browse/PUP-4708
#
#
class jenkins::params {
  $version               = 'installed'
  $lts                   = false
  $service_enable        = true
  $service_ensure        = 'running'
  $swarm_version         = '1.22'
  $default_plugins_host  = 'https://updates.jenkins-ci.org'
  $port                  = '8080'
  $prefix                = ''
  $cli_tries             = 10
  $cli_try_sleep         = 10
  $package_name          = 'jenkins'
  $user                  = 'jenkins'  
  $group                 = 'jenkins'

  case $::osfamily {
    'Debian': {
      $libdir            = '/usr/share/jenkins'
      $package_provider  = 'dpkg'
      $install_java      = true
	  $localstatedir     = '/var/lib/jenkins'
	  $package_cache_dir = '/var/cache/jenkins_pkgs'
	  $manage_user       = true
      $manage_group      = true
	  $provider          = shell
	  $path              = ['/bin', '/usr/bin']
      $cwd               = '/tmp'
      $difftool          = '/usr/bin/diff -b -q'
	  $repo              = true
	  $javapath          = '/usr/bin/'
    $cred_unless = "\$HELPER_CMD"
    }
    'RedHat': {
      $libdir            = '/usr/lib/jenkins'
      $package_provider  = 'rpm'
      $install_java      = true
	  $localstatedir     = '/var/lib/jenkins'
	  $package_cache_dir = '/var/cache/jenkins_pkgs'
	  $manage_user       = true
	  $manage_group      = true
	  $provider          = shell
	  $path              = ['/bin', '/usr/bin', '/sbin' , '/usr/sbin']
      $cwd               = '/tmp'
      $difftool          = '/usr/bin/diff -b -q'
	  $repo              = true
	  $javapath          = '/usr/bin/'
	  $cred_unless = "\$HELPER_CMD"
    }
    'windows': {
      $libdir            = 'C:/Program Files (x86)/Jenkins'
      $package_provider  = 'chocolatey'
      $install_java      = false
	  $localstatedir     = 'C:/Program Files (x86)/Jenkins'
	  $package_cache_dir = 'C:/Windows/Temp'
	  $manage_user       = false
      $manage_group      = false
	  $provider          = 'powershell'
	  $path              = ''
      $cwd               = 'C:/windows/temp'
      $difftool          = '& diff'
	  $repo              = false
	  $javapath          = ''
	  $cred_unless = "${::jenkins::cli_helper::helper_cmd}"
	  }
    default: {
      $libdir = '/usr/lib/jenkins'
      $package_provider  = false
      $install_java      = true
      $localstatedir     = '/var/lib/jenkins'
	  $package_cache_dir = '/var/cache/jenkins_pkgs'
	  $manage_user       = true
	  $manage_group      = true
	  $provider          = shell
	  $path              = ['/bin', '/usr/bin']
      $cwd               = '/tmp'
      $difftool          = '/usr/bin/diff -b -q'
	  $repo              = true
	  $javapath          = '/usr/bin/'
	  $cred_unless = "\$HELPER_CMD"
	  }
  }
}
