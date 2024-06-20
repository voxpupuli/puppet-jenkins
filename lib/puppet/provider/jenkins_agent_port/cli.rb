# frozen_string_literal: true

require File.join(File.dirname(__FILE__), '../../..', 'puppet/x/jenkins/util')
require File.join(File.dirname(__FILE__), '../../..', 'puppet/x/jenkins/provider/cli')

Puppet::Type.type(:jenkins_agent_port).provide(:cli, parent: Puppet::X::Jenkins::Provider::Cli) do
  mk_resource_methods

  def self.instances(catalog = nil)
    n = get_agent_port(catalog)

    # there can be only one value
    Puppet.debug("#{sname} instances: #{n}")

    [new(name: n, ensure: :present)]
  end

  def flush
    case self.ensure
    when :present
      set_agent_port
    else
      raise Puppet::Error, "invalid :ensure value: #{self.ensure}"
    end
  end

  private

  def self.get_agent_port(catalog = nil)
    clihelper(['get_agent_port'], catalog: catalog).to_i
  end
  private_class_method :get_agent_port

  def set_agent_port
    clihelper(['set_agent_port', name])
  end
end
