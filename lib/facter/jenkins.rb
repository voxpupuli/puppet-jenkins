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
    setcode do
        Facter::Util::Resolution.exec("rpm -qa|grep jenkins|cut -d'-' -f2")
    end
end
