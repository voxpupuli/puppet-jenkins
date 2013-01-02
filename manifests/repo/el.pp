class jenkins::repo::el ( $lts=0 )
{
  File {
    owner => 'root',
    group => 'root',
    mode  => 0644,
  }
 
 
  if $lts = 0 {
	  yumrepo {'jenkins':
	    descr    => 'Jenkins',
	    baseurl  => 'http://pkg.jenkins-ci.org/redhat/',
	    gpgcheck => 1,
		gpgkey   => "http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key"
	  }
  }
  elsif $lts=1 {
	  yumrepo {'jenkins':
	    descr    => 'Jenkins',
	    baseurl  => 'http://pkg.jenkins-ci.org/redhat-stable/',
	    gpgcheck => 1,
		gpgkey   => "http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key"
	  }
  }
  
  
}



