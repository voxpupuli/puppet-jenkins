begin
  require 'puppet_x/jenkins/util'
  require 'puppet_x/jenkins/provider/cli'
rescue LoadError
  require 'pathname' # WORK_AROUND #14073 and #7788
  jenkins = Puppet::Module.find('jenkins', Puppet[:environment].to_s)
  raise(LoadError, "Unable to find jenkins module in modulepath #{Puppet[:basemodulepath] || Puppet[:modulepath]}") unless jenkins
  require File.join jenkins.path, 'lib/puppet_x/jenkins/util'
  require File.join jenkins.path, 'lib/puppet_x/jenkins/provider/cli'
end

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
