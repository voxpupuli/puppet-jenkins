require 'puppet/util/warnings'

require 'puppet_x/jenkins/util'
require 'puppet_x/jenkins/provider/cli'

Puppet::Type.type(:jenkins_credentials).provide(:cli, :parent => PuppetX::Jenkins::Provider::Cli) do

  mk_resource_methods

  def self.instances(catalog = nil)
    all = credentials_list_json(catalog)

    Puppet.debug("#{sname} instances: #{all.collect {|i| i['id']}}")

    all.collect {|info| from_hash(info) }
  end

  def flush
    unless resource.nil?
      @property_hash = resource.to_hash
    end

    case self.ensure
    when :present
      credentials_update_json
    when :absent
      credentials_delete_id
    else
      fail("invalid :ensure value: #{self.ensure}")
    end
  end

  private
  def self.copy_key(dst, src, key)
    dst[key.to_sym] = src[key.to_s]
  end
  private_class_method :copy_key

  def self.from_hash(info)
    # map nil -> :undef
    info = PuppetX::Jenkins::Util.undefize(info)

    params = {
      :name   => info['id'],
      :ensure => :present,
    }

    [:impl, :domain, :scope].each {|k| copy_key(params, info, k)}

    case info['impl']
    when 'UsernamePasswordCredentialsImpl'
      [:description, :username, :password].each {|k| copy_key(params, info, k)}
    when 'BasicSSHUserPrivateKey'
      [:description, :username, :private_key, :passphrase].each {|k| copy_key(params, info, k)}
    when 'StringCredentialsImpl'
      [:description, :secret].each {|k| copy_key(params, info, k)}
    when 'FileCredentialsImpl'
      [:description, :file_name, :content].each {|k| copy_key(params, info, k)}
    when 'CertificateCredentialsImpl'
      [:description, :password, :key_store_implementation].each {|k| copy_key(params, info, k)}

      ksi = info['key_store_impl']
      params['key_store_impl'] = ksi

      case ksi
      when 'UploadedKeyStoreSource'
        params[:content] = info['content']
      when 'FileOnMasterKeyStoreSource'
        params[:source] = info['source']
      else
        Puppet::Util::Warnings.debug_once "#{sname}: unsupported key_store_implementation class #{ksi}"
      end
    else
      Puppet::Util::Warnings.debug_once "#{sname}: unsupported implementation class #{info['impl']}"
    end

    new(params)
  end
  private_class_method :from_hash

  def to_hash
    info = { 'id' => name }

    properties = self.class.resource_type.validproperties
    properties.reject! {|x| x == :ensure }

    properties.each do |prop|
      value = @property_hash[prop]
      unless value.nil?
        info[prop.to_s] = value
      end
    end

    # map :undef -> nil
    PuppetX::Jenkins::Util.unundef(info)
  end

  # array of hashes for multiple "credentials" entries
  def self.credentials_list_json(catalog = nil)
    raw = clihelper(['credentials_list_json'], :catalog => catalog)

    begin
      JSON.parse(raw)
    rescue JSON::ParserError
      fail("unable to parse as JSON: #{raw}")
    end
  end
  private_class_method :credentials_list_json

  def credentials_update_json
    clihelper(['credentials_update_json'], :stdinjson => to_hash)
  end

  def credentials_delete_id
    # name == "id"
    clihelper(['credentials_delete_id', name])
  end
end
