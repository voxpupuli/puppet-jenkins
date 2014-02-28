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
mod "rtyler/jenkins"
```

### With the "puppet module" tool

This module is compatible with the puppet module tool. Appropriately this
module has been released to the [Puppet Forge](http://forge.puppetlabs.com/),
allowing you to easily install the released version of the module

To quickly try this module with the puppet module tool:

    % sudo puppet module install rtyler/jenkins
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

