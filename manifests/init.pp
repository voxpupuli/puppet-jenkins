# Parameters:
# lts = 0  (Default)
#   Use the most up to date version of jenkins
#
#lts =1  - Use LTS verison of jenkins
#
# repo = 1 (Default)
#   install the jenkins repo.
# repo = 0
#   Do NOT install a repo.  This means you'll manage a repo manually, outside this module.
# This is for folks that use a custom repo, or the like.


class jenkins($version = 'installed', $lts=0, $repo=1, $firewall=1) {

  class {
    'jenkins::repo':
      lts  => $lts,
      repo => $repo,
     }

  class {
    'jenkins::package':
      version => $version,
  }

  include jenkins::service
  class {
    'jenkins::firewall':
      firewall => $firewall
  }

  Class['jenkins::repo'] -> Class['jenkins::package']
  -> Class['jenkins::service']
}
# vim: ts=2 et sw=2 autoindent
