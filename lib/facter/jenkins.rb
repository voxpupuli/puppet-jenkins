# jenkins.rb
#
# Creates a fact 'jenkins_plugins' containing a comma-delimited string of all
# jenkins plugins + versions.
#
#
require 'facter'

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
          Jenkins::Facts::Plugins.plugins
        end
      end

      return nil
    end


    # Return the shell-evaluated home of the Jenkins user
    #
    # @return [String] Full path to the Jenkins user's home directory
    def self.jenkins_home
      Facter::Util::Resolution.exec('echo ~jenkins')
    end

    module Plugins
      # Return structured data for the given plugin manifest string
      #
      # @return [Hash] A hash containing symbolized manifest keys and their
      #   string values
      # @return [NilClass] A nil if +manifest_str+ nil or an empty string
      def self.manifest_data(manifest_str)
        return {} if (manifest_str.nil? || manifest_str.empty?)

        data = {}
        manifest_str.split("\n").each do |line|
          next if line.empty?
          # Parse out "Plugin-Version: 1.2" for example
          parts = line.split(': ')

          # If the line starts with a space or we can't get at least two parts
          # (key and value), that means it's really just a word-wrap from the
          # previous line, and not a key, skip!
          next if parts.size < 2
          next if parts.first[0] == ' '

          key = parts.first.downcase.gsub('-', '_').chomp
          # Skip garbage keys
          next if (key.nil? || key.empty?)

          # Re-join any colon delimited strings in the value back together,
          # e.g.: "http://wiki.jenkins-ci.org/display/JENKINS/Ant+Plugin"
          value = parts[1..-1].join(':').chomp

          data[key.to_sym] = value
        end

        return data
      end

      # Return the full path to the Jenkins plugin directory
      #
      # @return [String] Full path to the Jenkins plugins directory
      def self.directory
        File.join(Jenkins::Facts.jenkins_home, 'plugins')
      end

      # Return a list of plugins and their versions, e.g.:
      #   pam-auth 1.1, pmd 3.36, rake 1.7.8
      #
      # @return [String] Comma-separated version of "<plugin> <version>", empty
      #   string if there are no plugins
      def self.plugins
        return '' unless exists?
        plugins = []
        Dir.entries(directory).each do |plugin|
          # Skip useless directories
          next if (plugin == '..')
          next if (plugin == '.')

          plugin_dir = File.join(directory, plugin)
          # Without an unpacked plugin directory, we can't find a version
          next unless File.directory?(plugin_dir)

          manifest = File.join(plugin_dir, 'META-INF', 'MANIFEST.MF')
          begin
            manifest = manifest_data(File.read(manifest))
            if manifest
              version = manifest[:plugin_version]
              plugins << "#{plugin} #{version}"
            end
          rescue StandardError => ex
            # Nothing really to do about it, failing means no version which will
            # result in a new plugin if needed
          end
        end

        return plugins.join(', ')
      end

      # Determine whether or not the jenkins plugin directory exists
      #
      # @return [Boolean] T
      def self.exists?
        home = Jenkins::Facts.jenkins_home
        return false if home.nil?
        return false unless File.directory? Jenkins::Facts::Plugins.directory
        return true
      end
    end
  end
end


# If we're being loaded inside the module, we'll need to go ahead and add our
# facts then won't we?
Jenkins::Facts.add_facts
