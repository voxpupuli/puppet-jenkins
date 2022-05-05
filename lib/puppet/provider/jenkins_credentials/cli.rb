# frozen_string_literal: true

require 'puppet/util/warnings'

require 'json'

require_relative '../../../puppet/x/jenkins/util'
require File.join(File.dirname(__FILE__), '../../..', 'puppet/x/jenkins/provider/cli')

Puppet::Type.type(:jenkins_credentials).provide(:cli, parent: Puppet::X::Jenkins::Provider::Cli) do
  mk_resource_methods

  def self.instances(catalog = nil)
    all = credentials_list_json(catalog)

    Puppet.debug("#{sname} instances: #{all.map { |i| i['id'] }}")

    all.map { |info| from_hash(info) }
  end

  def flush
    @property_hash = resource.to_hash unless resource.nil?

    case self.ensure
    when :present
      credentials_update_json
    when :absent
      credentials_delete_id
    else
      raise Puppet::Error, "invalid :ensure value: #{self.ensure}"
    end
  end

  private

  def self.copy_key(dst, src, key)
    dst[key.to_sym] = src[key.to_s]
  end
  private_class_method :copy_key

  def self.from_hash(info)
    # map nil -> :undef
    info = Puppet::X::Jenkins::Util.undefize(info)

    params = {
      name: info['id'],
      ensure: :present
    }

    %i[impl domain scope].each { |k| copy_key(params, info, k) }

    case info['impl']
    when 'UsernamePasswordCredentialsImpl'
      %i[description username password].each { |k| copy_key(params, info, k) }
    when 'BasicSSHUserPrivateKey'
      %i[description username private_key passphrase].each { |k| copy_key(params, info, k) }
    when 'StringCredentialsImpl'
      %i[description secret].each { |k| copy_key(params, info, k) }
    when 'FileCredentialsImpl'
      %i[description file_name content].each { |k| copy_key(params, info, k) }
    when 'CertificateCredentialsImpl'
      %i[description password key_store_implementation].each { |k| copy_key(params, info, k) }
    when 'AWSCredentialsImpl'
      %i[description secret_key access_key].each { |k| copy_key(params, info, k) }
    when 'BrowserStackCredentials'
      %i[description username access_key].each { |k| copy_key(params, info, k) }
    when 'GitLabApiTokenImpl'
      %i[description api_token].each { |k| copy_key(params, info, k) }
    when 'ConduitCredentialsImpl'
      %i[description token url].each { |k| copy_key(params, info, k) }

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
    properties.reject! { |x| x == :ensure }

    properties.each do |prop|
      value = @property_hash[prop]
      info[prop.to_s] = value unless value.nil?
    end

    # map :undef -> nil
    Puppet::X::Jenkins::Util.unundef(info)
  end

  # array of hashes for multiple "credentials" entries
  def self.credentials_list_json(catalog = nil)
    raw = clihelper(['credentials_list_json'], catalog: catalog)

    begin
      JSON.parse(raw)
    rescue JSON::ParserError
      raise Puppet::Error, 'Unable to parse Jenkins credentials list as JSON'
    end
  end
  private_class_method :credentials_list_json

  def credentials_update_json
    clihelper(['credentials_update_json'], stdinjson: to_hash)
  end

  def credentials_delete_id
    # name == "id"
    clihelper(['credentials_delete_id', name])
  end
end
