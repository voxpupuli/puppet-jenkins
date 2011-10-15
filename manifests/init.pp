
class jenkins {
  include jenkins::repo
  include jenkins::package

  Class["jenkins::repo"] -> Class["jenkins::package"]
}

class jenkins::package {
  package {
    "jenkins" :
      ensure => installed;
  }
}

class jenkins::repo {
  file {
      "/etc/apt/sources.list.d" :
          ensure => directory;

      "/etc/apt/sources.list.d/jenkins.list" :
          ensure => present,
          notify => [
                      Exec["install-key"],
                      Exec["refresh-apt"],
                    ],
          source => "puppet:///modules/jenkins/apt.list",
  }

  file {
      "/root/jenkins-ci.org.key" :
          source => "puppet:///modules/jenkins/jenkins-ci.org.key",
          ensure => present;
  }

  exec {
      "refresh-apt" :
          refreshonly => true,
          require => [
                      File["/etc/apt/sources.list.d/jenkins.list"],
                      Exec["install-key"],
                      ],
          path    => ["/usr/bin", "/usr/sbin"],
          command => "apt-get update";

      "install-key" :
          notify => Exec["refresh-apt"],
          require => [
                      File["/etc/apt/sources.list.d/jenkins.list"],
                      File["/root/jenkins-ci.org.key"],
                      ],
          command => "/usr/bin/apt-key add /root/jenkins-ci.org.key";
  }
}

define install-jenkins-plugin($name, $version=0) {
  $base_url   = "http://updates.jenkins-ci.org/latest/"

  $plugin     = "${name}.hpi"
  $plugin_dir = "/var/lib/jenkins/plugins"

  if ($version != 0) {
    $base_url = "http://updates.jenkins-ci.org/download/plugins/${name}/${version}/"
  }

  file {
    "${plugin_dir}" :
      ensure => directory;
  }

  exec {
    "download-plugin" :
      command  => "wget --no-check-certificate ${base_url}${plugin}",
      cwd      => "${plugin_dir}",
      require  => File["${plugin_dir}"],
      path     => ["/usr/bin", "/usr/sbin",],
      unless   => "test -f ${plugin_dir}/${plugin}",
  }
}

# vim: ts=2 et sw=2 autoindent
