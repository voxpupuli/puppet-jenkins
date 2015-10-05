require 'puppet_x/jenkins/util'
require 'puppet_x/jenkins/provider/cli'

Puppet::Type.type(:jenkins_slaveagent_port).provide(:cli, :parent => PuppetX::Jenkins::Provider::Cli) do

  mk_resource_methods

  def self.instances(catalog = nil)
    n = get_slaveagent_port(catalog)

    # there can be only one value
    Puppet.debug("#{sname} instances: #{n}")

    [new(:name => n, :ensure => :present)]
  end

  def flush
    case self.ensure
    when :present
      set_slaveagent_port
    else
      fail("invalid :ensure value: #{self.ensure}")
    end
  end

  private

  def self.get_slaveagent_port(catalog = nil)
    clihelper(['get_slaveagent_port'], :catalog => catalog).to_i
  end
  private_class_method :get_slaveagent_port

  def set_slaveagent_port
    clihelper(['set_slaveagent_port', name])
  end
end
