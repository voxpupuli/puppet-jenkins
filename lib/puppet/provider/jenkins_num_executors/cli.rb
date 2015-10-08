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

Puppet::Type.type(:jenkins_num_executors).provide(:cli, :parent => PuppetX::Jenkins::Provider::Cli) do

  mk_resource_methods

  def self.instances(catalog = nil)
    n = get_num_executors(catalog)

    # there can be only one value
    Puppet.debug("#{sname} instances: #{n}")

    [new(:name => n, :ensure => :prsent)]
  end

  def flush
    case self.ensure
    when :present
      set_num_executors
    else
      fail("invalid :ensure value: #{self.ensure}")
    end
  end

  private

  def self.get_num_executors(catalog = nil)
    clihelper(['get_num_executors'], :catalog => catalog).to_i
  end
  private_class_method :get_num_executors

  def set_num_executors
    clihelper(['set_num_executors', name])
  end
end
