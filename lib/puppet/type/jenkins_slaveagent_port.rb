require 'puppet_x/jenkins/type/cli'

PuppetX::Jenkins::Type::Cli.newtype(:jenkins_slaveagent_port) do
  @doc = "Manage Jenkins' slave agent listening port"

  # the cli jar does not have an interface for plugin removal so the only
  # allowed ensure value is :present
  ensurable do
    newvalue(:present) { provider.create }
  end

  newparam(:name) do
    desc 'port number'
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
