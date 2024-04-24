# frozen_string_literal: true

require 'facter'

require_relative '../jenkins'

require 'puppet/util/warnings'

# This class is used to lookup common configuration values by first looking for
# the desired key as parameter to the config class in the catalog, then
# checking for a prefixed fact, and falling back to hard coded defaults.
class Puppet::X::Jenkins::Config
  class UnknownConfig < ArgumentError; end

  DEFAULTS = {
    cli_jar: '/usr/share/java/jenkins-cli.jar',
    url: 'http://localhost:8080',
    ssh_private_key: nil,
    puppet_helper: '/usr/share/java/puppet_helper.groovy',
    cli_tries: 30,
    cli_username: nil,
    cli_password: nil,
    cli_password_file: '/tmp/jenkins_credentials_for_puppet',
    cli_password_file_exists: false
  }.freeze
  CONFIG_CLASS = 'jenkins::cli::config'
  FACT_PREFIX = 'jenkins_'

  def initialize(catalog = nil)
    @catalog = catalog
  end

  def [](key)
    key = key.to_sym
    raise UnknownConfig unless DEFAULTS.key?(key)

    value = catalog_lookup(key) || fact_lookup(key) || default_lookup(key)
    return if value.nil?

    Puppet::Util::Warnings.debug_once "config: #{key} = #{value}"

    # handle puppet 3.x passing in all values as strings and convert back to
    # Integer/Fixnum
    if Puppet.version =~ %r{^3}
      default_type_integer?(key) ? value.to_i : value
    else
      value
    end
  end

  def catalog_lookup(key)
    return nil if @catalog.nil?

    config = @catalog.resource(:class, CONFIG_CLASS)
    return nil if config.nil?

    config[key.to_sym]
  end

  def fact_lookup(key)
    fact = FACT_PREFIX + key.to_s
    Facter.value(fact.to_sym)
  end

  def default_lookup(key)
    DEFAULTS[key]
  end

  def default_type_integer?(key)
    DEFAULTS[key].is_a?(Integer)
  end
end
