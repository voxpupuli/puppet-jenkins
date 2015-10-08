begin
  require 'puppet_x/jenkins/type/cli'
rescue LoadError
  require 'pathname' # WORK_AROUND #14073 and #7788
  jenkins = Puppet::Module.find('jenkins', Puppet[:environment].to_s)
  raise(LoadError, "Unable to find jenkins module in modulepath #{Puppet[:basemodulepath] || Puppet[:modulepath]}") unless jenkins
  require File.join jenkins.path, 'lib/puppet_x/jenkins/type/cli'
end

PuppetX::Jenkins::Type::Cli.newtype(:jenkins_num_executors) do
  @doc = "Manage Jenkins' number of executor slots"

  # the cli jar does not have an interface for plugin removal so the only
  # allowed ensure value is :present
  ensurable do
    newvalue(:present) { provider.create }
  end

  newparam(:name) do
    desc 'Number of executors'
    isnamevar

    munge do |value|
      if value.is_a?(String) and value =~ /^[0-9]+$/
        Integer(value)
      else
        value
      end
    end
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
