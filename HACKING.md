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

