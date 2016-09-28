require 'puppet_x/jenkins/type/cli'

PuppetX::Jenkins::Type::Cli.newtype(:jenkins_authorization_strategy) do
  @doc = "Manage Jenkins' authorization strategy"

  ensurable

  newparam(:name) do
    desc 'Name of the security realm class'
    isnamevar
  end

  newproperty(:arguments, :array_matching => :all) do
    desc 'List of arguments to security realm class constructor'
  end

  # require all instances of jenkins_user as the authorization strategy being
  # converged might require one of those accounts for administrative control
  autorequire(:jenkins_user) do
    catalog.resources.find_all do |r|
      r.is_a?(Puppet::Type.type(:jenkins_user))
    end
  end

  # the authorization strategy can potentially lockout all access if it is
  # configured but the security realm is none
  autorequire(:jenkins_security_realm) do
    if self[:ensure] == :present
      catalog.resources.find_all do |r|
        r.is_a?(Puppet::Type.type(:jenkins_security_realm))
      end
    end
  end
end # PuppetX::Jenkins::Type::Cli.newtype
