class jenkins::repo::debian {
    if $lts == 0 {
	    apt::source { 'jenkins':
	      location    => 'http://pkg.jenkins-ci.org/debian',
	      release     => 'binary/',
	      repos       => '',
	      key         => 'D50582E6',
	      key_source  => 'http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key',
	      include_src => false,
	    }

    }
    elsif $lts == 1 {
	    apt::source { 'jenkins':
	      location    => 'http://pkg.jenkins-ci.org/debian-stable',
	      release     => 'binary/',
	      repos       => '',
	      key         => 'D50582E6',
	      key_source  => 'http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key',
	      include_src => false,
	    }
    }
  
}
