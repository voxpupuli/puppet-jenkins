# frozen_string_literal: true

module Puppet
  module Jenkins
    # @return [String] Full path to the Jenkins user's home directory
    def self.home_dir
      File.expand_path('~jenkins')
    rescue ArgumentError
      # The Jenkins user doesn't exist!
      nil
    end

    # @return [String] Full path to the Jenkins user's plugin directory
    def self.plugins_dir
      File.join(home_dir, 'plugins')
    end
  end
end
