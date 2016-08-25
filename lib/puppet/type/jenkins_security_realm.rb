require 'puppet_x/jenkins/type/cli'

PuppetX::Jenkins::Type::Cli.newtype(:jenkins_security_realm) do
  @doc = "Manage Jenkins' security realm"

  ensurable

  newparam(:name) do
    desc 'Name of the security realm class'
    isnamevar
  end

  newproperty(:arguments, :array_matching => :all) do
    desc 'List of arguments to security realm class constructor'
  end

  # require all instances of jenkins_user, as does
  # jenkins_authorization_strategy, to ensure that the state of jenkins_user
  # resources is not attempted to be modify between jenkins_security_realm and
  # jenkins_authorization_strategy state changes.
  autorequire(:jenkins_user) do
    catalog.resources.find_all do |r|
      r.is_a?(Puppet::Type.type(:jenkins_user))
    end
  end

  autorequire(:jenkins_authorization_strategy) do
    if self[:ensure] == :absent
      catalog.resources.find_all do |r|
        r.is_a?(Puppet::Type.type(:jenkins_authorization_strategy))
      end
    end
  end
end # PuppetX::Jenkins::Type::Cli.newtype
