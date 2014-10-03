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

### Managing Jenkins jobs


Build jobs can be managed using the `jenkins::job` define

#### Creating or updating a build job
```puppet
  jenkins::job { 'test-build-job':
    config => template("${templates}/test-build-job.xml.erb"),
  }
```

#### Disabling a build job
```puppet
  jenkins::job { 'test-build-job':
    enabled => 0,
    config  => template("${templates}/test-build-job.xml.erb"),
  }
```

#### Removing an existing build job
```puppet
  jenkins::job { 'test-build-job':
    ensure => 'absent',
  }
```

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
5. Jenkins Users
6. Credentials
7. Simple security model configuration

### API-based Resources and Settings (Users, Credentials, security)

This module includes a groovy-based helper script that uses the
[Jenkins CLI](https://wiki.jenkins-ci.org/display/JENKINS/Jenkins+CLI) to
interact with the Jenkins API. Users, Credentials, and security model
configuration are all driven through this script.

When an API-based resource is defined, the Jenkins CLI is installed and run
against the local system (127.0.0.1). Jenkins is assumed to be listening on
port 8080, but the module is smart enough to notice if you've configured an
alternate port using jenkins::config_hash['HTTP_PORT'].

Users and credentials are Puppet-managed, meaning that changes made to them
from outside Puppet will be reset at the next puppet run. In this way, you can
ensure that certain accounts are present and have the appropriate login
credentials.

### CLI Helper

The CLI helper assumes unauthenticated access unless configured otherwise.
You can configure jenkins::cli_helper to use an SSH key on the managed system:

    class {'jenkins::cli_helper':
      ssh_keyfile => '/path/to/id_rsa',
    }

There's an open bug in Jenkins (JENKINS-22346) that causes authentication to
fail when a key is used but authentication is disabled. Until the bug is fixed,
you may need to bootstrap jenkins out-of-band to ensure that resources and
security policy are configured in the correct order. For example:

    # In puppet:
      anchor {'jenkins-bootstrap-start': } ->
        Class['jenkins::cli_helper'] ->
          Exec[$bootstrap_script] ->
            anchor {'jenkins-bootstrap-complete': }

    # Code for $bootstrap_script
    #!/bin/bash -e
    # Generate an SSH key for the admin user
    ADMIN_USER='<%= admin_user_name %>'
    ADMIN_EMAIL='<%= admin_user_email %>'
    ADMIN_PASSWORD='<%= admin_user_password %>'
    ADMIN_FULLNAME='<%= admin_user_full_name %>'
    ADMIN_SSH_KEY='<%= admin_ssh_keyfile %>'
    JENKINS_CLI='<%= jenkins_libdir %>/jenkins-cli.jar'
    PUPPET_HELPER='<%= jenkins_libdir %>/puppet_helper.groovy'
    HELPER="java -jar $JENKINS_CLI -s http://127.0.0.1:8080 groovy $PUPPET_HELPER"
    DONEFILE='<%= jenkins_libdir %>/jenkins-bootstrap.done'
    
    ADMIN_PUBKEY="$(cat ${ADMIN_SSH_KEY}.pub)"
    
    # Create the admin user, passing no credentials
    $HELPER create_or_update_user "$ADMIN_USER" "$ADMIN_EMAIL" "$ADMIN_PASSWORD" "$ADMIN_FULLNAME" "$ADMIN_PUBKEY"
    # Enable security. After this, credentials will be required.
    $HELPER set_security full_control
    
    touch $DONEFILE

#### Users

Email and password are required.

Create a `johndoe` user account whose full name is "Managed by Puppet": 

    jenkins::user {'johndoe':
      email    => 'jdoe@example.com',
      password => 'changeme',
    }

### Credentials

Password is required. For ssh credentials, `password` is the key passphrase (or
'' if there is none). `private_key_or_path` is the text of key itself or an
absolute path to a key file on the managed system.

Create ssh credentials named 'github-deploy-key', providing an unencrypted
private key:

    jenkins::credentials {'github-deploy-key':
      password            => '',
      private_key_or_path => hiera('::github_deploy_key'),
    }

### Configuring Security

The Jenkins security model can be set to one of two modes:

* `full_control` - Users have full control after login. Authentication uses
  Jenkins' built-in user database.
* `unsecured` - Authentication is not required.

Jenkins security is not managed by puppet unless jenkins::security is defined.

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

