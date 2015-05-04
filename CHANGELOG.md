# Changelog

This is a manually kept file, and may not entirely reflect reality

## v1.4.0 - Smithers

* [#222](https://github.com/jenkinsci/puppet-jenkins/pull/222) - Add retry to credentials execs
* [#229](https://github.com/jenkinsci/puppet-jenkins/pull/229) - Jenkins slave defaults bugfix
* [#233](https://github.com/jenkinsci/puppet-jenkins/pull/233) - fixes timeouts on restart
* [#235](https://github.com/jenkinsci/puppet-jenkins/pull/235) - Make creation of user optional
* [#236](https://github.com/jenkinsci/puppet-jenkins/pull/236) - Cleanup metadata.json for better mechanical score
* [#237](https://github.com/jenkinsci/puppet-jenkins/pull/237) - Update the README with a few puppet-lint things and puppet highlighting.
* [#238](https://github.com/jenkinsci/puppet-jenkins/pull/238) - Fix Bracket issue
* [#239](https://github.com/jenkinsci/puppet-jenkins/pull/239) - Refactor acceptance tests to use beaker-rspec
* [#244](https://github.com/jenkinsci/puppet-jenkins/pull/244) - Add instructions for acceptance tests
* [#245](https://github.com/jenkinsci/puppet-jenkins/pull/245) - Added support for the 'toolLocations' parameter.
* [#256](https://github.com/jenkinsci/puppet-jenkins/pull/256) - Direct package
* [#260](https://github.com/jenkinsci/puppet-jenkins/pull/260) - Feature/puppet helper num executors
* [#261](https://github.com/jenkinsci/puppet-jenkins/pull/261) - Escape job names for shell commands
* [#262](https://github.com/jenkinsci/puppet-jenkins/pull/262) - Change apt key to full fingerprint
* [#264](https://github.com/jenkinsci/puppet-jenkins/issues/264) - Broken link on puppetlabs.com page
* [#266](https://github.com/jenkinsci/puppet-jenkins/pull/266) - pin puppetlabs-apt fixtures version to 1.8.0
* [#268](https://github.com/jenkinsci/puppet-jenkins/pull/268) - Improvements on job import via cli
* [#270](https://github.com/jenkinsci/puppet-jenkins/pull/270) - remove rspec gem ~> 2.99.0 constraint
* [#271](https://github.com/jenkinsci/puppet-jenkins/pull/271) - fix rspec > 3 compatiblity
* [#272](https://github.com/jenkinsci/puppet-jenkins/pull/272) - use mainline puppetlabs_spec_helper gem
* [#273](https://github.com/jenkinsci/puppet-jenkins/pull/273) - update spec_helper_acceptance boiler plate
* [#274](https://github.com/jenkinsci/puppet-jenkins/pull/274) - remove puppet module versions constraints from beaker setup
* [#275](https://github.com/jenkinsci/puppet-jenkins/pull/275) - add .bundle to .gitignore
* [#276](https://github.com/jenkinsci/puppet-jenkins/pull/276) - add log/ to .gitignore
* [#277](https://github.com/jenkinsci/puppet-jenkins/pull/277) - add puppet 3.7.0 to travis matrix
* [#278](https://github.com/jenkinsci/puppet-jenkins/pull/278) - remove unnecessary whitespace from $::jenkins::cli_helper::helper_cmd
* [#279](https://github.com/jenkinsci/puppet-jenkins/pull/279) - add metadata-json-lint to Gemfile & enable rake validate target
* [#280](https://github.com/jenkinsci/puppet-jenkins/pull/280) - change puppetlabs/stdlib version dep to >= 4.6.0
* [#282](https://github.com/jenkinsci/puppet-jenkins/pull/282) - Feature/puppet 4
* [#285](https://github.com/jenkinsci/puppet-jenkins/pull/285) - convert raw execs of puppet_helper.groovy to jenkins::cli::exec define


## v1.3.0 - Barnard

* [#134](https://github.com/jenkinsci/puppet-jenkins/pull/134) - Added in ability for user to redefine update center plugin URL
* [#139](https://github.com/jenkinsci/puppet-jenkins/pull/139) - document additional class params
* [#169](https://github.com/jenkinsci/puppet-jenkins/pull/169) - Allow build jobs to be configured and managed by puppet. Includes #163 a...
* [#174](https://github.com/jenkinsci/puppet-jenkins/issues/174) - setting configure_firewall true returns error, port is undefined
* [#177](https://github.com/jenkinsci/puppet-jenkins/issues/177) - switch to metadata.json
* [#188](https://github.com/jenkinsci/puppet-jenkins/pull/188) - Fix installation of core plugins
* [#189](https://github.com/jenkinsci/puppet-jenkins/pull/189) - Fix test.
* [#191](https://github.com/jenkinsci/puppet-jenkins/pull/191) - set default port for firewall
* [#195](https://github.com/jenkinsci/puppet-jenkins/pull/195) - Bump up swarm version to 1.17
* [#198](https://github.com/jenkinsci/puppet-jenkins/issues/198) - Relationship error when testing Jenkins::jobs
* [#199](https://github.com/jenkinsci/puppet-jenkins/pull/199) - missing include causes issuse #198
* [#202](https://github.com/jenkinsci/puppet-jenkins/pull/202) - Proxy work
* [#203](https://github.com/jenkinsci/puppet-jenkins/pull/203) - Fix typo in job/present.pp
* [#204](https://github.com/jenkinsci/puppet-jenkins/pull/204) - Fix for #174 allows setting $jenkins::port
* [#206](https://github.com/jenkinsci/puppet-jenkins/issues/206) - Refactor some of the firewall port configuration
* [#207](https://github.com/jenkinsci/puppet-jenkins/pull/207) - Introduce the jenkins_port function


## v1.2.0 - Nestor

* [#117](https://github.com/jenkinsci/puppet-jenkins/pull/117) - Add feature to disable SSL verification on Swarm clients
* [#131](https://github.com/jenkinsci/puppet-jenkins/pull/131) - Support updates for core jenkins modules
* [#135](https://github.com/jenkinsci/puppet-jenkins/issues/135) - cli option broken w/ jenkins 1.563 on ubuntu precise
* [#137](https://github.com/jenkinsci/puppet-jenkins/pull/137) - repos should be enabled if repo=true on RedHat
* [#140](https://github.com/jenkinsci/puppet-jenkins/issues/140) - Packaging Cruft in 1.1.0
* [#144](https://github.com/jenkinsci/puppet-jenkins/pull/144) - Update init.pp - correct plugins example syntax
* [#149](https://github.com/jenkinsci/puppet-jenkins/pull/149) - Do not ensure plugin_parent_dir to be a directory (#148)
* [#150](https://github.com/jenkinsci/puppet-jenkins/pull/150) - Add ensure parameter to jenkins::slave
* [#151](https://github.com/jenkinsci/puppet-jenkins/issues/151) - Unsupported OSFamily RedHat on node
* [#152](https://github.com/jenkinsci/puppet-jenkins/issues/152) - Jenkins-slave on Centos: killproc and checkpid commands not found
* [#153](https://github.com/jenkinsci/puppet-jenkins/pull/153) - Fixes to Jenkins slave init and class
* [#154](https://github.com/jenkinsci/puppet-jenkins/issues/154) - slave_mode doesn't apply on debian distros.
* [#155](https://github.com/jenkinsci/puppet-jenkins/pull/155) - Add defined check for plugin_parent_dir resource
* [#157](https://github.com/jenkinsci/puppet-jenkins/pull/157) - Add missing slave mode to Debian defaults file
* [#160](https://github.com/jenkinsci/puppet-jenkins/pull/160) - User and credentials creation, simple security management
* [#166](https://github.com/jenkinsci/puppet-jenkins/issues/166) - Error loading fact /var/lib/puppet/lib/facter/jenkins.rb no such file to load -- json
* [#171](https://github.com/jenkinsci/puppet-jenkins/pull/171) - A bit of RedHat and Debian slave initd script merging
* [#176](https://github.com/jenkinsci/puppet-jenkins/issues/176) - no such file to load -- json
* [#180](https://github.com/jenkinsci/puppet-jenkins/issues/180) - Replace use of unzip with `jar` for unpacking jenkins CLI
* [#182](https://github.com/jenkinsci/puppet-jenkins/pull/182) - Include the apt module when installing an apt repository
* [#183](https://github.com/jenkinsci/puppet-jenkins/pull/183) - Rely on the `jar` command instead of `unzip` to unpack the cli.jar
* [#185](https://github.com/jenkinsci/puppet-jenkins/pull/185) - Allow setting the slave name, default to the fqdn at runtime
* [#186](https://github.com/jenkinsci/puppet-jenkins/issues/186) - Puppet Forge module
* [#187](https://github.com/jenkinsci/puppet-jenkins/issues/187) - Jenkins slave on RedHat - jenkins-slave.erb


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
