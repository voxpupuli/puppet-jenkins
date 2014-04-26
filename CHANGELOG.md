# Changelog

This is a manually kept file, and may not entirely reflect reality


## v1.1.0 - Duckworth

### Features

 * [#86](https://github.com/jenkinsci/puppet-jenkins/issues/86),
   [#122](https://github.com/jenkinsci/puppet-jenkins/pull/122) - Add support
   for disabling SSL verification on slaves
 * [#116](https://github.com/jenkinsci/puppet-jenkins/pull/116) - Add support
   for setting the `-fsroot` option for slaves
 * `init` script for Debian-family slaves added
 * Initial code for a [jpm](https://github.com/rtyler/jpm) based `Package`
   provider merged


### Bug fixes

 * [#107](https://github.com/jenkinsci/puppet-jenkins/pull/107) - Private/internal classes made truly private
 * [#109](https://github.com/jenkinsci/puppet-jenkins/pull/109) - Fix for
   dependency issue between repo and package installation.
 * `$jenkins_plugins` fact refactored and RSpec tests added
 * [#121](https://github.com/jenkinsci/puppet-jenkins/pull/121) - `daemon`
   package installed to make Debian slave installs functional
 * [#126](https://github.com/jenkinsci/puppet-jenkins/issues/126) - Facter
   exception bug fixed

