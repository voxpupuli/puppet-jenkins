# jenkins.rb
#
# Creates a fact 'jenkins_plugins' containing a comma-delimited string of all
# jenkins plugins + versions.
#
#
require 'facter'
require 'puppet/jenkins'
require 'puppet/jenkins/plugins'

module Jenkins
  module Facts
    # Method to call the Facter DSL and dynamically add facts at runtime.
    #
    # This method is necessary to add reasonable RSpec coverage for the custom
    # fact
    #
    # @return [NilClass]
    def self.add_facts
      Facter.add(:jenkins_plugins) do
        confine :kernel => "Linux"
        setcode do
          Jenkins::Plugins.plugins
        end
      end

      return nil
    end
  end
end


# If we're being loaded inside the module, we'll need to go ahead and add our
# facts then won't we?
Jenkins::Facts.add_facts
