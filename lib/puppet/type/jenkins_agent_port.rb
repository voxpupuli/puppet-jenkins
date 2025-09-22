# frozen_string_literal: true

require_relative '../../puppet/x/jenkins/type/cli'

Puppet::X::Jenkins::Type::Cli.newtype(:jenkins_agent_port) do
  @doc = "Manage Jenkins' agent listening port"

  # the cli jar does not have an interface for plugin removal so the only
  # allowed ensure value is :present
  ensurable do
    newvalue(:present) { provider.create }
  end

  newparam(:name) do
    desc 'port number'
    isnamevar

    munge do |value|
      if value.is_a?(String) && value =~ %r{^[0-9]+$}
        Integer(value)
      else
        value
      end
    end
  end

  # require all authentication & authorization related types
  %i[
    jenkins_user
    jenkins_security_realm
    jenkins_authorization_strategy
  ].each do |type|
    autorequire(type) do
      catalog.resources.select do |r|
        r.is_a?(Puppet::Type.type(type))
      end
    end
  end
end
