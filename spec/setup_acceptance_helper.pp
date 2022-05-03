# Facter < 4 needs lsb-release for os.distro.codename
if versioncmp($facts['facterversion'], '4.0.0') < 0 and $facts['os']['family'] == 'Debian' {
  package { 'lsb-release':
    ensure => 'installed',
  }
}
