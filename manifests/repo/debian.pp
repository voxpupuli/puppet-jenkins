class jenkins::repo::debian {
  apt::source { "jenkins":
    location    => "http://pkg.jenkins-ci.org/debian",
    release     => "",
    repos       => "binary/",
    key         => "D50582E6",
    key_source  => "http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key",
    include_src => false,
  }
}
