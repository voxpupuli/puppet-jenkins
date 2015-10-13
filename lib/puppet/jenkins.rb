
module Puppet
  module Jenkins
    # @return [String] Full path to the Jenkins user's home directory
    def self.home_dir
      begin
        if Facter.value(:osfamily) == 'OpenBSD'
          return File.expand_path('~_jenkins')
        else
          return File.expand_path('~jenkins')
        end
      rescue ArgumentError
        # The Jenkins user doesn't exist!
        return nil
      end
    end

    # @return [String] Full path to the Jenkins user's plugin directory
    def self.plugins_dir
      if Facter.value(:osfamily) == 'OpenBSD'
        return File.join(self.home_dir, '.jenkins', 'plugins')
      else
        return File.join(self.home_dir, 'plugins')
      end
    end
  end
end
