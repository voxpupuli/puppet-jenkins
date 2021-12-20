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
    libdir = case Facter.value('os.family')
             when 'Debian'
               '/usr/share/jenkins'
             when 'Archlinux'
               '/usr/share/java/jenkins'
             else
               '/usr/lib/jenkins'
             end
    war = libdir + '/jenkins.war'

    if Facter::Util::Resolution.which('java') and File.exist?(war)
      Facter::Util::Resolution.exec(
        'java -jar %s --version' % [war]
      )
    end
  end
end
