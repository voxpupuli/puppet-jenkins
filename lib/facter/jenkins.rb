# jenkins.rb
#
# Creates a fact 'jenkins_plugins' containing a comma-delimited string of all
# jenkins plugins + versions.
#
#
#require 'puppet/jenkins/facts'
require 'facter'

if Facter.value(:kernel) == 'windows'
require File.join(File.dirname(__FILE__), '..', 'puppet/jenkins/facts.rb')
else
require 'puppet/jenkins/facts'
end

# If we're being loaded inside the module, we'll need to go ahead and add our
# facts then won't we?
Puppet::Jenkins::Facts.install
