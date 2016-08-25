require 'puppet_x/jenkins/util'
require 'puppet_x/jenkins/provider/cli'

Puppet::Type.type(:jenkins_authorization_strategy).provide(:cli, :parent => PuppetX::Jenkins::Provider::Cli) do

  mk_resource_methods

  def self.instances(catalog = nil)
    all = get_authorization_strategy(catalog)

    # we are assuming there is only one key hash
    Puppet.debug("#{sname} instances: #{all.keys}")

    [from_hash(all)]
  end

  def flush
    unless resource.nil?
      @property_hash = resource.to_hash
    end

    case self.ensure
    when :present
      set_jenkins_instance
    when :absent
      set_strategy_unsecured
    else
      fail("invalid :ensure value: #{self.ensure}")
    end
  end

  private

  def self.from_hash(info)
    method_name = 'setAuthorizationStrategy'
    class_name = info[method_name].keys.first
    ctor_args = info[method_name][class_name]

    args = {
      :name      => class_name,
      :ensure    => :present,
      :arguments => ctor_args,
    }

    # map nil -> :undef
    args = PuppetX::Jenkins::Util.undefize(args)
    new(args)
  end
  private_class_method :from_hash

  def to_hash
    ctor = {}

    if arguments == :absent
      ctor[name] = []
    else
      ctor[name] = arguments
    end
    Puppet.debug("to_hash arguments #{arguments}")

    info = { 'setAuthorizationStrategy' => ctor }
    # map :undef -> nil
    PuppetX::Jenkins::Util.unundef(info)
  end

  # jenkins only supports a single configured security realm at a time
  def self.get_authorization_strategy(catalog = nil)
    raw = clihelper(['get_authorization_strategy'], :catalog => catalog)

    begin
      JSON.parse(raw)
    rescue JSON::ParserError
      fail("unable to parse as JSON: #{raw}")
    end
  end
  private_class_method :get_authorization_strategy

  def set_jenkins_instance(input = nil)
    input ||= to_hash

    clihelper(['set_jenkins_instance'], :stdinjson => input)
  end

  def set_strategy_unsecured
    input = {
      'setAuthorizationStrategy' => {
        'hudson.security.AuthorizationStrategy$Unsecured' => [],
      },
    }
    set_jenkins_instance(input)
  end
end
