class jenkins {
  include jenkins::repo
  include jenkins::package
  include jenkins::service

  Class["jenkins::repo"] -> Class["jenkins::package"] -> Class["jenkins::service"]

  define plugin($version=0) {
    install-jenkins-plugin {
      $name :
        version => $version;
    }
  }
}
# vim: ts=2 et sw=2 autoindent
