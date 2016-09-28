require 'puppet/property/boolean'
require 'puppet/parameter/boolean'
require 'puppet/util/diff'
require 'puppet/util/checksums'
require 'pathname'
require 'tempfile'

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
        return 'created'
      elsif newvalue == :absent
        return 'removed'
      else
        if Puppet[:show_diff] and resource[:show_diff]
          # XXX this really should be turned into a helper method and submitted
          # to # core puppet
          Tempfile.open('puppet-file') do |d1|
            d1.write(currentvalue)
            d1.flush
            Tempfile.open('puppet-file') do |d2|
              d2.write(newvalue)
              d2.flush

              send @resource[:loglevel], "\n" + diff(d1.path, d2.path)

              d2.close
              d2.unlink
            end
            d1.close
            d1.unlink
          end

        end
        return "content changed '{md5}#{md5(currentvalue)}' to '{md5}#{md5(newvalue)}'"
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
  # XXX we can't inspect @resource[:name] or self[:name] here outside of teh
  # autorequire block because of meta-programming funkiness
  autorequire(:jenkins_job) do
    if self[:ensure] == :present
      folders = []
      Pathname(self[:name]).dirname.descend { |d| folders << d.to_path }
      folders
    end
  end

  # XXX completely punting on handling delete ordering for puppet < 4
  unless Puppet.version.to_f < 4.0
    autobefore(:jenkins_job) do
      if self[:ensure] == :absent
        folders = []
        Pathname(self[:name]).dirname.descend { |d| folders << d.to_path }
        folders
      end
    end
  end
end # PuppetX::Jenkins::Type::Cli.newtype
