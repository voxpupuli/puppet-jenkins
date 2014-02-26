# puppet-jenkins

This is intended to be a re-usable
[Puppet](http://www.puppetlabs.com/puppet/introduction/) module that you can
include in your own tree.

# Using puppet-jenkins

## Getting Started
```bash
puppet module install rtyler/jenkins
```

```puppet

    node 'hostname.example.com' {
        include jenkins

    }
```
Then the service should be running at [http://hostname.example.com:8080/](http://hostname.example.com:8080/).

### Installing Jenkins plugins


The Jenkins puppet module defines the `jenkins::plugin` resource which
will download and install the plugin "[by
hand](https://wiki.jenkins-ci.org/display/JENKINS/Plugins#Plugins-Byhand)"

The names of the plugins can be found on the [update
site](http://updates.jenkins-ci.org/download/plugins)

#### Latest

By default, the resource will install the latest plugin, i.e.:

    jenkins::plugin {
      "git" : ;
    }

If you specify `version => 'latest'` in current releases of the module, the
plugin will be downloaded and installed with *every* run of Puppet. This is a
known issue and will be addressed in future releases. For now it is recommended
that you pin plugin versions when using the `jenkins::plugin` type.

#### By version
If you need to peg a specific version, simply specify that as a string, i.e.:

    jenkins::plugin {
      "git" :
        version => "1.1.11";
    }

#### Plugin dependencies
Dependencies are not automatically installed. You need to manually determine the plugin dependencies and include those as well. The Jenkins wiki is a good place to do this. For example: The Git plugin page is at https://wiki.jenkins-ci.org/display/JENKINS/Git+Plugin.

### Slaves
You can automatically add slaves to jenkins, and have them auto register themselves.  Most options are actually optional, as nodes will autodiscover the master, and connect.

Full documention for the slave code is in jenkins::slave.

It requires the swarm plugin on the master & the class jenkins::slave on the slaves, as below:

```puppet
    node /jenkins-slave.*/ {
      class { 'jenkins::slave':
        masterurl => 'http://jenkins-master1.domain.com:8080',
        ui_user => 'adminuser',
        ui_pass => 'adminpass',
      }
    }

    node /jenkins-master.*/ {
        include jenkins
        include jenkins::master
    }
```

### Dependencies

The dependencies for this module currently are:

* [stdlib module](http://forge.puppetlabs.com/puppetlabs/stdlib)
* [apt module](http://forge.puppetlabs.com/puppetlabs/apt) (for Debian/Ubuntu users)
* [java module](http://github.com/puppetlabs/puppetlabs-java)
* [zypprepo](https://forge.puppetlabs.com/darin/zypprepo) (for Suse users)


### Depending on Jenkins

If you have any resource in Puppet that *depends* on Jenkins being present, add
the following `require` statement:

    exec {
        "some-exec" :
            require => Class["jenkins::package"],
            # ... etc
    }


### Advanced features
1. Plugin Hash - jenkins::plugins
2. Config Hash - jennkins::config
3. Configure Firewall - jenkins (init.pp)
4. Outbound Jenkins Proxy Config - jenkins (init.pp)


## Using from Github / source

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

    % git submodule add git://github.com/jenkinsci/puppet-jenkins.git modules/jenkins
    % git submodule update --init

### With the "puppet module" tool

This module is compatible with the puppet module tool.  To build a package file
of this module, please use the `rake build` task.  The resulting package file
may be uploaded to the [Puppet Forge](http://forge.puppetlabs.com/).



To quickly try this module with the puppet module tool:

    % rake build
    % cd /etc/puppet/modules
    % sudo puppet module install /tmp/rtyler-jenkins-0.0.1.tar.gz
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

----


# Developing/Contributing

## Testing

This module has behavior tests written using [RSpec 2](https://www.relishapp.com/rspec),
is syntax checked with [puppet-syntax](https://github.com/gds-operations/puppet-syntax), and style checked with [puppet-lint](http://puppet-lint.com/).
The goal of these tests are to validate the expected behavior of the module.
As more features and platform support are added to this module the tests
provide an automated way to validate the expectations previous contributors
have specified.

In order to validate behavior setup fixtures with `rake spec_prep` and then
execute code with `rake spec_standalone`.

    % rake spec_standalone
    (in /Users/jeff/vms/puppet/modules/jenkins)
    .
    Finished in 0.31279 seconds
    1 example, 0 failures

Lint, spec, and syntax checks can be run by using the default rake task by
simply running 'rake'.

### Lint checking

The lint checks require the `puppet-lint` gem to be installed.  Running
'rake lint' will lint check all of the *.pp files to ensure they conform to the
puppet style guide.

### RSpec Testing Requirements

The spec tests require the `rspec-puppet` gem to be installed.  Running 'rake spec'
will automatically check out all of the modules in the .fixtures.yml needed to run
the tests.

### Syntax checking

The syntax checks require the `puppet-syntax` gem to be installed.  Running
'rake syntax' will sytanx check the manifests and templates.

### Installing Testing Requirements

To install the testing requirements:

    % gem install rspec-puppet puppet-lint puppet-syntax --no-ri --no-rdoc
    Successfully installed rspec-core-2.14.5
    Successfully installed diff-lcs-1.2.4
    Successfully installed rspec-expectations-2.14.3
    Successfully installed rspec-mocks-2.14.3
    Successfully installed rspec-2.14.1
    Successfully installed rspec-puppet-0.1.6
    Successfully installed puppet-lint-0.3.2
    Successfully installed rake-10.1.0
    Successfully installed puppet-syntax-1.1.0
    10 gems installed

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

