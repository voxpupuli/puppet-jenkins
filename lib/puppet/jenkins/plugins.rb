require 'json'
require 'puppet/jenkins'

module Puppet
  module Jenkins
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

      # @return [Hash] a +Hash+ containing a mapping of a plugin name to its
      #   manifest data
      def self.available
        return {} unless exists?
        plugins = {}
        Dir.entries(Puppet::Jenkins.plugins_dir).each do |plugin|
          # Skip useless directories
          next if (plugin == '..')
          next if (plugin == '.')

          plugin_dir = File.join(Puppet::Jenkins.plugins_dir, plugin)
          # Without an unpacked plugin directory, we can't find a version
          next unless File.directory?(plugin_dir)

          manifest = File.join(plugin_dir, 'META-INF', 'MANIFEST.MF')
          begin
            manifest = manifest_data(File.read(manifest))
            if manifest
              plugins[plugin] = manifest
            end
          rescue StandardError => ex
            # Nothing really to do about it, failing means no version which will
            # result in a new plugin if needed
          end
        end
        return plugins
      end

      # Determine whether or not the jenkins plugin directory exists
      #
      # @return [Boolean] T
      def self.exists?
        home = Puppet::Jenkins.home_dir
        return false if home.nil?
        return false unless File.directory? Puppet::Jenkins.plugins_dir
        return true
      end


      # Parse the update-center.json file which Jenkins uses to maintain it's
      # internal dependency graph for plugins
      #
      # This document is technically JSONP formatted so we must munge the file
      # a bit to load the JSON bits properly
      #
      # @return [Hash] Parsed version of the update center JSON
      def self.plugins_from_updatecenter(filename)
        File.open(filename, 'rb') do |fd|
          buffer = fd.read
          return {} if (buffer.nil? || buffer.empty?)
          buffer = buffer.split("\n")
          # Trim off the first and last lines, which are the JSONP gunk
          buffer = buffer[1 ... -1]

          data = JSON.parse(buffer.join("\n"))
          return data['plugins'] || {}
        end
        return {}
      end
    end
  end
end
