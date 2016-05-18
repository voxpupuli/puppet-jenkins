require 'puppet/provider'
require 'facter'

require 'puppet_x/jenkins/config'
require 'puppet_x/jenkins/provider'

class PuppetX::Jenkins::Provider::Cli < Puppet::Provider
  # stdout/stderr indicates an authentication failure
  class AuthError < Puppet::ExecutionFailure; end
  # any other execution error
  class UnknownError < Puppet::ExecutionFailure; end

  # push a shallow copy of the class confines into the subclass
  # this includes the confine(s) needed for commands
  #
  # The subclass seems to function with an empty @commands and any value we try
  # to push in will get reselt by ::initvars.
  def self.inherited(subclass)
    subclass.instance_variable_set(:@confine_collection, @confine_collection.dup)
  end

  # we must invoke ::initvars to setup variables needed by ::commands
  self.initvars

  commands :java => 'java'
  confine :feature => :retries

  # subclasses should inherit this value once it has been determined that
  # jenkins requires authorization, it shortens the run time be elemating the
  # need for each subclass to retest for an authenication failure.
  #
  # XXX this needs some consideration for how to handle the transistion from
  # security being enabled to disabled
  class_variable_set(:@@cli_auth_required, false)

  # shorter class name
  def self.sname
    self.to_s[/.+::(Jenkins.+)/, 1]
  end

  def self.prefetch(resources)
    Puppet.debug("#{sname} prefetch: #{resources.each_key.collect.to_a}")

    catalog = resources.first[1].catalog

    instances(catalog).each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def create
    @property_hash[:ensure] = :present
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def destroy
    @property_hash[:ensure] = :absent
  end

  def flush
    @property_hash.clear
  end

  # if the provider instance has a resource (which it should outside of
  # testing), add :catalog to the options hash so the caller doesn't have to
  def clihelper(command, options = nil)
    if resource and resource.catalog
      options ||= {}
      options[:catalog] ||= resource.catalog
    end

    args = []
    args << command
    args << options unless options.nil?
    self.class.clihelper(*args)
  end

  def cli(command, options = nil)
    if resource and resource.catalog
      options ||= {}
      options[:catalog] ||= resource.catalog
    end

    args = []
    args << command
    args << options unless options.nil?
    self.class.cli(*args)
  end

  def self.clihelper(command, options = nil)
    catalog = options.nil? ? nil : options[:catalog]
    config = PuppetX::Jenkins::Config.new(catalog)

    puppet_helper = config[:puppet_helper]

    cli_cmd = ['groovy', puppet_helper] + [command]
    cli_cmd.flatten!

    cli(cli_cmd, options)
  end

  def self.cli(command, options = {})
    if options.nil? || !options.key?(:stdinjson) && !options.key?(:stdin)
      return execute_with_retry(command, options)
    end

    if options.key?(:stdinjson)
      data = options.delete(:stdinjson)
      input = JSON.pretty_generate(data)
    end

    if options.key?(:stdin)
      input = options.delete(:stdin)
    end

    Puppet.debug("#{sname} stdin:\n#{input}")

    # a tempfile block arg is not used to simplify mock testing :/
    tmp = Tempfile.open(sname)
    tmp.write input
    tmp.flush
    options[:stdinfile] = tmp.path
    result = execute_with_retry(command, options)
    tmp.close
    tmp.unlink

    result
  end

  def self.execute_with_retry(command, options = {})
    options ||= {}
    catalog = options.delete(:catalog)

    options.merge!({ :failonfail => true })
    # without combine, an execution exception message will not include the
    # stderr
    options.merge!({ :combine => true })

    config = PuppetX::Jenkins::Config.new(catalog)
    cli_jar         = config[:cli_jar]
    url             = config[:url]
    ssh_private_key = config[:ssh_private_key]
    cli_tries       = config[:cli_tries]
    cli_try_sleep   = config[:cli_try_sleep]

    base_cmd = [
      command(:java),
      '-jar', cli_jar,
      '-s', url,
    ]

    cli_cmd = base_cmd + [command]
    cli_cmd.flatten!

    auth_cmd = nil
    unless ssh_private_key.nil?
      auth_cmd = base_cmd + ['-i', ssh_private_key] + [command]
      auth_cmd.flatten!
    end

    # retry on "unknown" execution errors but don't catch AuthErrors.  If an
    # AuthError has bubbled up to this level it means either an ssh_private_key
    # is required and we don't have one or that one we have was rejected.
    handler = Proc.new do |exception, attempt_number, total_delay|
      Puppet.debug("#{sname} caught #{exception.class.to_s.match(/::([^:]+)$/)[1]}; retry attempt #{attempt_number}; #{total_delay.round(3)} seconds have passed")
    end
    with_retries(
      :max_tries          => cli_tries,
      :base_sleep_seconds => 1,
      :max_sleep_seconds  => cli_try_sleep,
      :rescue             => UnknownError,
      :handler            => handler,
    ) do
      result = execute_with_auth(cli_cmd, auth_cmd, options)
      unless result == ''
        Puppet.debug("#{sname} command stdout:\n#{result}")
      end
      return result
    end
  end
  private_class_method :execute_with_retry

  def self.execute_with_auth(cli_cmd, auth_cmd, options = {})
    # auth will fail if if it is attempted with an ssh_private_key that
    # hasn't yet been configured for a user.
    Puppet.debug("#{sname} cli_auth_required: #{class_variable_get(:@@cli_auth_required)}")

    # if no ssh_private_key is defined, the only option is to invoke the cli
    # without auth
    if auth_cmd.nil?
      return execute_exceptionify(cli_cmd, options)
    end

    # we already know that auth is required
    if class_variable_get(:@@cli_auth_required)
      return execute_exceptionify(auth_cmd, options)
    end

    begin
      # try first with no auth
      return execute_exceptionify(cli_cmd, options)
    rescue AuthError
      # retry with auth
      Puppet.debug("#{sname} cli auth failure -- retrying with ssh_private_key")
      result = execute_exceptionify(auth_cmd, options)
      class_variable_set(:@@cli_auth_required, true)
      Puppet.debug("#{sname} cli_auth_required: #{class_variable_get(:@@cli_auth_required)}")
      return result
    end
  end
  private_class_method :execute_with_auth

  # convert Puppet::ExecutionFailure into a ::AuthError exception if it appears
  # that the command failure was due to an authication problem
  def self.execute_exceptionify(*args)
    cli_auth_errors = ['You must authenticate to access this Jenkins.',
                       'anonymous is missing the Overall/Read permission',
                       'anonymous is missing the Overall/RunScripts permission',
                      ]
    begin
      #return Puppet::Provider.execute(*args)
      return superclass.execute(*args)
    rescue Puppet::ExecutionFailure => e
      cli_auth_errors.each do |error|
        if e.message.match(error)
          raise AuthError, e.message, e.backtrace
        end
      end

      raise UnknownError, e.message, e.backtrace
    end
  end
  private_class_method :execute_exceptionify
end
