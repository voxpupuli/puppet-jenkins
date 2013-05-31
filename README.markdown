# puppet-jenkins

This is intended to be a re-usable
[Puppet](http://www.puppetlabs.com/puppet/introduction/) module that you can
include in your own tree.


## Using puppet-jenkins


### With librarian

If you use [librarian-puppet](https://github.com/rodjek/librarian-puppet), add
the following to your `Puppetfile`:

```ruby
mod "jenkins",
  :git => "git://github.com/jenkinsci/puppet-jenkins.git"

mod "apt",
  :git => "git://github.com/puppetlabs/puppetlabs-apt.git"

mod "stdlib",
  :git => "git://github.com/puppetlabs/puppetlabs-stdlib.git"
```

### With git-submodule(1)

In order to add this module, run the following commands in your own, presumably
Git, puppet tree:

    % git submodule add git://github.com/rtyler/puppet-jenkins.git modules/jenkins
    % git submodule update --init

### With the "puppet module" tool

This module is compatible with the puppet module tool.  To build a package file
of this module, please use the `rake build` task.  The resulting package file
may be uploaded to the [Puppet Forge](http://forge.puppetlabs.com/).


To quickly try this module with the puppet module tool:

    % rake build
    % cd /etc/puppet/modules
    % sudo puppet-module install /tmp/rtyler-jenkins-0.0.1.tar.gz
    Installed "rtyler-jenkins-0.0.1" into directory: jenkins
    % sudo puppet apply -v -e 'include jenkins'
    info: Loading facts in facter_dot_d
    info: Loading facts in facter_dot_d
    info: Applying configuration version '1323459431'
    notice: /Stage[main]/Jenkins::Repo::El/Yumrepo[jenkins]/descr: descr changed '' to 'Jenkins'
    notice: /Stage[main]/Jenkins::Repo::El/Yumrepo[jenkins]/baseurl: baseurl changed '' to 'http://pkg.jenkins-ci.org/redhat/'
    notice: /Stage[main]/Jenkins::Repo::El/Yumrepo[jenkins]/gpgcheck: gpgcheck changed '' to '1'
    notice: /Stage[main]/Jenkins::Repo::El/File[/etc/yum/jenkins-ci.org.key]/ensure: defined content as '{md5}9fa06089848262c5a6383ec27fdd2575'
    notice: /Stage[main]/Jenkins::Repo::El/Exec[rpm --import /etc/yum/jenkins-ci.org.key]/returns: executed successfully
    notice: /Stage[main]/Jenkins::Package/Package[jenkins]/ensure: created
    notice: /Stage[main]/Jenkins::Service/Service[jenkins]/ensure: ensure changed 'stopped' to 'running'
    notice: Finished catalog run in 27.46 seconds

Then the service should be running at [http://my.host.name:8080/](http://my.host.name:8080/).

----

### Dependencies

The dependencies for this module currently are:

* [stdlib module](http://forge.puppetlabs.com/puppetlabs/stdlib)
* [apt module](http://forge.puppetlabs.com/puppetlabs/apt) (for Debian/Ubuntu users)



### Depending on Jenkins

If you have any resource in Puppet that *depends* on Jenkins being present, add
the following `require` statement:

    exec {
        "some-exec" :
            require => Class["jenkins::package"],
            # ... etc
    }



## Installing Jenkins plugins


The Jenkins puppet module defines the `install-jenkins-plugin` resource which
will download and install the plugin "[by
hand](https://wiki.jenkins-ci.org/display/JENKINS/Plugins#Plugins-Byhand)"

The names of the plugins can be found on the [update
site](http://updates.jenkins-ci.org/download/plugins)


### Latest

By default, the resource will install the latest plugin, i.e.:


    jenkins::plugin {
      "git" : ;
    }


### By version

If you need to peg a specific version, simply specify that as a string, i.e.:

    jenkins::plugin {
      "git" :
        version => "1.1.11";
    }


## Slaves

An example:

```puppet

    node /jenkins-slave.*/ {
      class { 'jenkins::slave':
        ensure => 'enabled',
        masterurl => 'http://jenkins-master1.domain.com:8080',
        ui_user => 'adminuser',
        ui_pass => 'adminpass',
      }
    }

    node /jenkins-master.*/ {
        include jenkins
        jenkins::plugin {'swarm':}

    }
```


# Developing/Contributing

## RSpec Testing

This module has behavior tests written using [RSpec 2](https://www.relishapp.com/rspec).
The goal of these tests are to validate the expected behavior of the module.
As more features and platform support are added to this module the tests
provide an automated way to validate the expectations previous contributors
have specified.

In order to validate the behavior, please run the `rake spec` task.

    % rake spec
    (in /Users/jeff/vms/puppet/modules/jenkins)
    .
    Finished in 0.31279 seconds
    1 example, 0 failures

### RSpec Testing Requirements

The spec tests require the `rspec-puppet` gem to be installed.  These tests
have initially be tested with the following integration of components in
addition to this module.  Modules such as
[stdlib](https://github.com/puppetlabs/puppetlabs-stdlib) may be checked out
into the same parent directory as this module.  The spec tests will
automatically add this parent directory to the Puppet module search path.

 * rspec 2.6
 * rspec-puppet 0.1.0
 * puppet 2.7.6
 * facter 1.6.3
 * stdlib 2.2.0

### Installing RSpec Testing Requirements

To install the testing requirements:

    % gem install rspec-puppet --no-ri --no-rdoc
    Successfully installed rspec-core-2.7.1
    Successfully installed diff-lcs-1.1.3
    Successfully installed rspec-expectations-2.7.0
    Successfully installed rspec-mocks-2.7.0
    Successfully installed rspec-2.7.0
    Successfully installed rspec-puppet-0.1.0
    6 gems installed

### Adding Tests

Please see the [rspec-puppet](https://github.com/rodjek/rspec-puppet) project
for information on writing tests.  A basic test that validates the class is
declared in the catalog is provided in the file
`spec/classes/jenkins_spec.rb`.  `rspec-puppet` automatically uses the top
level description as the name of a module to include in the catalog.
Resources may be validated in the catalog using:

 * `contain_class('myclass')`
 * `contain_service('sshd')`
 * `contain_file('/etc/puppet')`
 * `contain_package('puppet')`
 * And so forth for other Puppet resources.

