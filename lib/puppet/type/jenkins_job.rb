require 'puppet/property/boolean'
require 'pathname'
require 'puppet/util/diff'
require 'puppet/util/checksums'

require 'puppet_x/jenkins/type/cli'

PuppetX::Jenkins::Type::Cli.newtype(:jenkins_job) do
  @doc = "Manage Jenkins' jobs"

  ensurable

  newparam(:name) do
    desc 'job name'
    isnamevar
  end

  newproperty(:config) do
    include Puppet::Util::Diff
    include Puppet::Util::Checksums

    desc 'XML job configuration string'

    def change_to_s(currentvalue, newvalue)
      if currentvalue == :absent
        return "created"
      elsif newvalue == :absent
        return "removed"
      else
        if Puppet[:show_diff] and resource.parameter(:show_diff)
          send @resource[:loglevel], "\n" + lcs_diff(currentvalue, newvalue)
        end

        current_md5 = md5(currentvalue)
        new_md5 = md5(newvalue)
        return "content changed '{md5}#{current_md5}' to '{md5}#{new_md5}'"
      end
    end
  end

  newparam(:show_diff, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc 'enable/disable displaying configuration diff'
    defaultto true
  end

  newproperty(:enable, :boolean => true, :parent => Puppet::Property::Boolean) do
    desc 'enable/disable job'
    defaultto true
  end

  # require all authentication & authorization related types
  [
    :jenkins_user,
    :jenkins_security_realm,
    :jenkins_authorization_strategy,
  ].each do |type|
    autorequire(type) do
      catalog.resources.find_all do |r|
       r.is_a?(Puppet::Type.type(type))
      end
    end
  end

  # if the job is contained in a `cloudbees-folder`, autorequire any parent
  # folder jobs
  # XXX we can't inspect @resource[:name] or self[:name] here because of
  # meta-programming funkiness
  autorequire(:jenkins_job) do
    folders = []
    Pathname(self[:name]).dirname.descend { |d| folders << d.to_path }
    folders
  end

end # PuppetX::Jenkins::Type::Cli.newtype
