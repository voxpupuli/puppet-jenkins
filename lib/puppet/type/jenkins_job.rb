require 'digest/md5'
require 'puppet/property/boolean'
require 'puppet/util/diff'

require 'puppet_x/jenkins/type/cli'

PuppetX::Jenkins::Type::Cli.newtype(:jenkins_job) do
  @doc = "Manage Jenkins' jobs"

  ensurable

  newparam(:name) do
    desc 'job name'
    isnamevar
  end

  newproperty(:checksum) do
    desc 'The checksum of the XML job configuration'
  end

  newproperty(:config) do
    include Puppet::Util::Diff
    include Puppet::Util::Checksums

#    attr_reader :actual_content

    desc 'XML job configuration string'

#    munge do |value|
#      if value == :absent
#        value
#      elsif checksum?(value)
#        value
#      else
#        @actual_content = value
#        resource.parameter(:checksum).sum(value)
#      end
#    end

    # TODO: see if it's possible to log a diff of the change before
    def change_to_s(currentvalue, newvalue)
      if currentvalue == :absent
        return "created"
      elsif newvalue == :absent
        return "removed"
      else
        current_md5 = Digest::MD5.hexdigest(currentvalue)
        new_md5 = Digest::MD5.hexdigest(newvalue)

        Puppet.notice(lcs_diff(currentvalue, newvalue))

        return "content changed '{md5}#{current_md5}' to '{md5}#{new_md5}'"
      end
    end

    def content
      self.should
    end

    def insync?(is)
      result = super
      if ! result and Puppet[:show_diff] and resource.show_diff?
    end
  end

  newproperty(:show_diff, :boolean => true, :parent => Puppet::Property::Boolean) do
    desc 'display a diff of the changes to job configuration'
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
end # PuppetX::Jenkins::Type::Cli.newtype
