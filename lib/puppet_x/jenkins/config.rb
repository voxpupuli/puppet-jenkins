require 'facter'

require 'puppet_x/jenkins'
require 'puppet/util/warnings'

# This class is used to lookup common configuration values by first looking for
# the desired key as parameter to the config class in the catalog, then
# checking for a prefixed fact, and falling back to hard coded defaults.
class PuppetX::Jenkins::Config
  class UnknownConfig < ArgumentError; end

  DEFAULTS = {
    :cli_jar         => '/usr/lib/jenkins/jenkins-cli.jar',
    :url             => 'http://localhost:8080',
    :ssh_private_key => nil,
    :puppet_helper   => '/usr/lib/jenkins/puppet_helper.groovy',
    :cli_tries       => 30,
    :cli_try_sleep   => 2,
  }
  CONFIG_CLASS = 'jenkins::cli::config'
  FACT_PREFIX = 'jenkins_'

  def initialize(catalog = nil)
    @catalog = catalog
  end

  def [](key)
    key = key.to_sym
    raise UnknownConfig unless DEFAULTS.has_key?(key)

    value = catalog_lookup(key) || fact_lookup(key) || default_lookup(key)
    return if value.nil?

    Puppet::Util::Warnings.debug_once "config: #{key} = #{value}"

    # handle puppet 3.x passing in all values as strings and convert back to
    # Integer/Fixnum
    if Puppet.version =~ /^3/
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
