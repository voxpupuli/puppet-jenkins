require 'facter'
require File.join(File.dirname(__FILE__), '..', 'jenkins.rb')
require File.join(File.dirname(__FILE__), '..', 'jenkins/plugins.rb')

module Puppet
  module Jenkins
    module Facts
      # Method to call the Facter DSL and dynamically add facts at runtime.
      #
      # This method is necessary to add reasonable RSpec coverage for the custom
      # fact
      #
      # @return [NilClass]
      def self.install
        Facter.add(:jenkins_plugins) do
          confine :kernel => 'Linux'
          setcode do
            Puppet::Jenkins::Facts.plugins_str
          end
        end
        return nil
      end

      # Return a list of plugins and their versions, e.g.:
      #   pam-auth 1.1, pmd 3.36, rake 1.7.8
      #
      # @return [String] Comma-separated version of "<plugin> <version>", empty
      #   string if there are no plugins
      def self.plugins_str
        plugins = Puppet::Jenkins::Plugins.available
        buffer = []
        plugins.keys.sort.each do |plugin|
          manifest = plugins[plugin]
          buffer << "#{plugin} #{manifest[:plugin_version]}"
        end
        return buffer.join(', ')
      end
    end
  end
end
