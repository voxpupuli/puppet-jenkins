# jenkins.rb
#
# Creates a fact 'jenkins_plugins' containing a comma-delimited string of all
# jenkins plugins + versions.
require 'facter'
require_relative '../puppet/jenkins/plugins'

Facter.add(:jenkins_plugins) do
  confine kernel: 'Linux'
  setcode do
    plugins = Puppet::Jenkins::Plugins.available
    plugins.keys.sort.map { |plugin| "#{plugin} #{plugins[plugin][:plugin_version]}" }.join(', ')
  end
end

Facter.add(:jenkins_version) do
  confine kernel: 'Linux'

  setcode do
    libdirs = [
      '/usr/share/java',
      '/usr/share/java/jenkins',
      '/usr/share/jenkins',
      '/usr/lib/jenkins'
    ]

    if Facter::Util::Resolution.which('java')
      version = nil

      libdirs.each do |libdir|
        war = format('%s/jenkins.war', libdir)
        next unless File.exist?(war)
        next if version

        version = Facter::Util::Resolution.exec(
          format('java -jar %s --version', war)
        )
      end
      version
    end
  end
end
