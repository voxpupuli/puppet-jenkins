require File.join(File.dirname(__FILE__), '../../..', 'puppet/x/jenkins/util')
require File.join(File.dirname(__FILE__), '../../..', 'puppet/x/jenkins/provider/cli')

require 'json'

Puppet::Type.type(:jenkins_user).provide(:cli, parent: Puppet::X::Jenkins::Provider::Cli) do
  mk_resource_methods

  def self.instances(catalog = nil)
    all = user_info_all(catalog)

    Puppet.debug("#{sname} instances: #{all.map { |i| i['id'] }}")

    all.map { |info| from_hash(info) }
  end

  def api_token_public=(_value)
    raise Puppet::Error, 'api_token_public is read-only'
  end

  def flush
    @property_hash = resource.to_hash unless resource.nil?

    case self.ensure
    when :present
      user_update
    when :absent
      delete_user
    else
      raise Puppet::Error, "invalid :ensure value: #{self.ensure}"
    end
  end

  private

  def self.from_hash(info)
    # map nil -> :undef
    info = Puppet::X::Jenkins::Util.undefize(info)

    new(name: info['id'],
        ensure: :present,
        full_name: info['full_name'],
        email_address: info['email_address'],
        api_token_plain: info['api_token_plain'],
        api_token_public: info['api_token_public'],
        public_keys: info['public_keys'],
        password: info['password'])
  end
  private_class_method :from_hash

  def to_hash
    info = { 'id' => name }

    properties = self.class.resource_type.validproperties
    properties.reject! { |x| x == :ensure }
    properties.reject! { |x| x == :api_token_public }

    properties.each do |prop|
      value = @property_hash[prop]
      info[prop.to_s] = value unless value.nil?
    end

    # map :undef -> nil
    Puppet::X::Jenkins::Util.unundef(info)
  end

  # array of hashes for multiple users
  def self.user_info_all(catalog = nil)
    raw = if catalog.nil?
            clihelper(['user_info_all'])
          else
            clihelper(['user_info_all'], catalog: catalog)
          end

    begin
      JSON.parse(raw)
    rescue JSON::ParserError
      raise Puppet::Error, "unable to parse as JSON: #{raw}"
    end
  end
  private_class_method :user_info_all

  def user_update
    input ||= to_hash

    clihelper(['user_update'], stdinjson: input)
  end

  def delete_user
    clihelper(['delete_user', name])
  end
end
