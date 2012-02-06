class jenkins::repo::debian {
  file {
      '/etc/apt/sources.list.d' :
          ensure => directory;

      '/etc/apt/sources.list.d/jenkins.list' :
          ensure => present,
          notify => [
                      Exec['install-key'],
                      Exec['refresh-apt'],
                    ],
          source => 'puppet:///modules/jenkins/apt.list',
  }

  file {
      '/root/jenkins-ci.org.key' :
          ensure => present,
          source => 'puppet:///modules/jenkins/jenkins-ci.org.key';
  }

  exec {
      'refresh-apt' :
          refreshonly => true,
          require     => [
                          File['/etc/apt/sources.list.d/jenkins.list'],
                          Exec['install-key']],
          path        => ['/usr/bin', '/usr/sbin'],
          command     => 'apt-get update';

      'install-key' :
          notify  => Exec['refresh-apt'],
          require => [
                      File['/etc/apt/sources.list.d/jenkins.list'],
                      File['/root/jenkins-ci.org.key'],
                      ],
          # Don't install the key unless it's not already installed
          unless  => '/usr/bin/apt-key list | grep \'D50582E6\'',
          command => '/usr/bin/apt-key add /root/jenkins-ci.org.key';
  }
}

