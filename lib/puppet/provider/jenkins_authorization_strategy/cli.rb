require File.join(File.dirname(__FILE__), '../../..', 'puppet/x/jenkins/util')
require File.join(File.dirname(__FILE__), '../../..', 'puppet/x/jenkins/provider/cli')

require 'json'

Puppet::Type.type(:jenkins_authorization_strategy).provide(:cli, parent: Puppet::X::Jenkins::Provider::Cli) do
  mk_resource_methods

  def self.instances(catalog = nil)
    all = get_authorization_strategy(catalog)

    # we are assuming there is only one key hash
    Puppet.debug("#{sname} instances: #{all.keys}")

    [from_hash(all)]
  end

  def flush
    @property_hash = resource.to_hash unless resource.nil?

    case self.ensure
    when :present
      set_jenkins_instance
    when :absent
      set_strategy_unsecured
    else
      raise Puppet::Error, "invalid :ensure value: #{self.ensure}"
    end
  end

  private

  def self.from_hash(info)
    method_name = 'setAuthorizationStrategy'
    class_name = info[method_name].keys.first
    ctor_args = info[method_name][class_name]

    args = {
      name: class_name,
      ensure: :present,
      arguments: ctor_args
    }

    # map nil -> :undef
    args = Puppet::X::Jenkins::Util.undefize(args)
    new(args)
  end
  private_class_method :from_hash

  def to_hash
    ctor = {}

    ctor[name] = if arguments == :absent
                   []
                 else
                   arguments
                 end
    Puppet.debug("to_hash arguments #{arguments}")

    info = { 'setAuthorizationStrategy' => ctor }
    # map :undef -> nil
    Puppet::X::Jenkins::Util.unundef(info)
  end

  # jenkins only supports a single configured security realm at a time
  def self.get_authorization_strategy(catalog = nil)
    raw = clihelper(['get_authorization_strategy'], catalog: catalog)

    begin
      JSON.parse(raw)
    rescue JSON::ParserError
      raise Puppet::Error, "unable to parse as JSON: #{raw}"
    end
  end
  private_class_method :get_authorization_strategy

  def set_jenkins_instance(input = nil)
    input ||= to_hash

    clihelper(['set_jenkins_instance'], stdinjson: input)
  end

  def set_strategy_unsecured
    input = {
      'setAuthorizationStrategy' => {
        'hudson.security.AuthorizationStrategy$Unsecured' => []
      }
    }
    set_jenkins_instance(input)
  end
end
