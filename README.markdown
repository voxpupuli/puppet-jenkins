# puppet-jenkins

This is intended to be a re-usable
[Puppet](http://www.puppetlabs.com/puppet/introduction/) module that you can
include in your own tree.


In order to add this module, run the following commands in your own, presumably
Git, puppet tree:

    % git submodule add git://github.com/rtyler/puppet-jenkins.git modules/jenkins
    % git submodule update --init

That should be all you need

### Depending on Jenkins

If you have any resource in Puppet that *depends* on Jenkins being present, add
the following `require` statement:

    exec {
        "some-exec" :
            require => Class["jenkins::package"],
            # ... etc
    }



### Installing Jenkins plugins


The Jenkins puppet module defines the `install-jenkins-plugin` resource which
will download and install the plugin "[by
hand](https://wiki.jenkins-ci.org/display/JENKINS/Plugins#Plugins-Byhand)"

The names of the plugins can be found on the [update
site](http://updates.jenkins-ci.org/download/plugins)


#### Latest

By default, the resource will install the latest plugin, i.e.:


    install-jenkins-plugin {
        "git-plugin" :
            name => "git";
    }



#### By version

If you need to peg a specific version, simply specify that as a string, i.e.:

    install-jenkins-plugin {
        "git-plugin" :
            name    => "git,
            version => "1.1.11";
    }

# Puppet Module Tool

This module is compatible with the puppet module tool.  To build a package file
of this module, please use the `rake build` task.  The resulting package file
may be uploaded to the [Puppet Forge](http://forge.puppetlabs.com/).

