require 'puppet/property/boolean'

begin
  require 'puppet_x/jenkins/type/cli'
rescue LoadError
  require 'pathname' # WORK_AROUND #14073 and #7788
  jenkins = Puppet::Module.find('jenkins', Puppet[:environment].to_s)
  raise(LoadError, "Unable to find jenkins module in modulepath #{Puppet[:basemodulepath] || Puppet[:modulepath]}") unless jenkins
  require File.join jenkins.path, 'lib/puppet_x/jenkins/type/cli'
end

PuppetX::Jenkins::Type::Cli.newtype(:jenkins_job) do
  @doc = "Manage Jenkins' jobs"

  ensurable

  newparam(:name) do
    desc 'job name'
    isnamevar
  end

  newproperty(:config) do
    desc 'XML job configuration string'
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
