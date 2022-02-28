require 'puppet/provider'
require 'facter'

require 'json'

require_relative '../../jenkins/config'
require_relative '../../jenkins/provider'

class Puppet::X::Jenkins::Provider::Cli < Puppet::Provider
  # stdout/stderr indicates an authentication failure
  class AuthError < Puppet::ExecutionFailure; end
  # network / jenkins not ready for connections
  class NetError < Puppet::ExecutionFailure; end
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
  initvars

  commands java: 'java'
  confine feature: :retries

  # subclasses should inherit this value once it has been determined that
  # jenkins requires authorization, it shortens the run time be elemating the
  # need for each subclass to retest for an authenication failure.
  #
  # XXX this needs some consideration for how to handle the transistion from
  # security being enabled to disabled
  class_variable_set(:@@cli_auth_required, false)

  # shorter class name
  def self.sname
    to_s[%r{.+::(Jenkins.+)}, 1]
  end

  def self.prefetch(resources)
    Puppet.debug("#{sname} prefetch: #{resources.each_key.collect.to_a}")

    catalog = resources.first[1].catalog

    instances(catalog).each do |prov|
      if (resource = resources[prov.name])
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
    if resource && resource.catalog
      options ||= {}
      options[:catalog] ||= resource.catalog
    end

    args = []
    args << command
    args << options unless options.nil?
    self.class.clihelper(*args)
  end

  def cli(command, options = nil)
    if resource && resource.catalog
      options ||= {}
      options[:catalog] ||= resource.catalog
    end

    args = []
    args << command
    args << options unless options.nil?
    self.class.cli(*args)
  end

  def self.clihelper(command, options = {})
    catalog = options.key?(:catalog) ? options[:catalog] : nil
    config = Puppet::X::Jenkins::Config.new(catalog)

    puppet_helper = config[:puppet_helper]

    cli_pre_cmd = ['/bin/cat', puppet_helper, '|']
    cli_cmd = ['groovy', '='] + [command]
    options[:tmpfile_as_param] = true

    cli_pre_cmd.flatten!
    cli_cmd.flatten!

    cli(cli_cmd, options, cli_pre_cmd)
  end

  def self.cli(command, options = {}, cli_pre_cmd = [])
    if options.nil? || !options.key?(:stdinjson) && !options.key?(:stdin)
      return execute_with_retry(command, options, cli_pre_cmd)
    end

    if options.key?(:stdinjson)
      data = options.delete(:stdinjson)
      input = JSON.pretty_generate(data)
    end

    input = options.delete(:stdin) if options.key?(:stdin)

    tmpfile_as_param = if options.key?(:tmpfile_as_param)
                         options[:tmpfile_as_param]
                       else
                         false
                       end

    # This Puppet.debug shows the JSON with changed credentials in plain text.
    # ToDo: Remove this debug output OR mask the credentials
    Puppet.debug("#{sname} stdin:\n#{input}")

    # a tempfile block arg is not used to simplify mock testing :/
    tmp = Tempfile.open(sname)
    tmp.write input
    tmp.flush
    options[:stdinfile] = tmp.path
    begin
      Etc.getpwnam('jenkins')
      FileUtils.chown 'jenkins', 'jenkins', tmp.path if tmpfile_as_param && File.exist?(tmp.path)
    rescue
      FileUtils.chmod 0o644, tmp.path if tmpfile_as_param && File.exist?(tmp.path)
    end
    result = execute_with_retry(command, options, cli_pre_cmd)
    tmp.close
    tmp.unlink

    result
  end

  def self.execute_with_retry(command, options = {}, cli_pre_cmd = [])
    options ||= {}
    cli_pre_cmd ||= []

    catalog = options.delete(:catalog)

    options[:failonfail] = true
    # without combine, an execution exception message will not include the
    # stderr
    options[:combine] = true

    config = Puppet::X::Jenkins::Config.new(catalog)
    cli_jar                  = config[:cli_jar]
    url                      = config[:url]
    ssh_private_key          = config[:ssh_private_key]
    cli_tries                = config[:cli_tries]
    cli_try_sleep            = config[:cli_try_sleep]
    cli_username             = config[:cli_username]
    cli_password             = config[:cli_password]
    cli_password_file        = config[:cli_password_file]
    cli_password_file_exists = config[:cli_password_file_exists]

    base_cmd = cli_pre_cmd + [
      command(:java),
      '-jar', cli_jar,
      '-s', url,
      '-logger', 'WARNING'
    ]

    cli_cmd = base_cmd + [command]
    cli_cmd.flatten!

    auth_cmd = nil
    # If we have a ssh cli key file, we use that
    if !ssh_private_key.nil?
      raise 'cli_username must be set' if cli_username.nil? || cli_username.empty?
      auth_cmd = base_cmd + ['-i', ssh_private_key] + ['-ssh', '-user', cli_username] + [command]
    # we have a prepared username:password file, just use it
    elsif cli_password_file_exists
      auth_cmd = base_cmd + ['-auth', "@#{cli_password_file}"] + [command]
    # we have username and password, then we create the password file and use it
    elsif !cli_username.nil? && !cli_password.nil?
      auth_cmd = base_cmd + ['-auth', "@#{cli_password_file}"] + [command]
    end
    auth_cmd.flatten! unless auth_cmd.nil?

    # retry on "unknown" execution errors but don't catch AuthErrors.  If an
    # AuthError has bubbled up to this level it means either an ssh_private_key
    # is required and we don't have one or that one we have was rejected.
    handler = proc do |exception, attempt_number, total_delay|
      Puppet.debug("#{sname} caught #{exception.class.to_s.match(%r{::([^:]+)$})[1]}; retry attempt #{attempt_number}; #{total_delay.round(3)} seconds have passed")
    end
    with_retries(
      max_tries: cli_tries,
      base_sleep_seconds: 1,
      max_sleep_seconds: cli_try_sleep,
      rescue: [UnknownError, NetError],
      handler: handler
    ) do
      result = execute_with_auth(cli_cmd, auth_cmd, options)
      # This Puppet.debug shows the JSON wit all credentials in plain text.
      # ToDo: Remove this debug output OR mask the credentials
      Puppet.debug("#{sname} command stdout:\n#{result}") unless result == ''
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
    return execute_exceptionify(cli_cmd, options) if auth_cmd.nil?

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
  def self.execute_exceptionify(cmd, options)
    cli_auth_errors = [
      'You must authenticate to access this Jenkins.',
      'anonymous is missing the Overall/Read permission',
      'anonymous is missing the Overall/RunScripts permission',
      'anonymous is missing the Overall/Administer permission'
    ]
    # network errors / jenkins not ready for connections not related to
    # authenication failures
    net_errors = [
      'SEVERE: I/O error in channel CLI connection',
      'java.net.SocketException: Connection reset',
      'java.net.ConnectException: Connection refused',
      'java.io.IOException: Failed to connect'
    ]

    if options.key?(:tmpfile_as_param)
      tmpfile_as_param = options[:tmpfile_as_param]
    end

    begin
      if tmpfile_as_param && options.key?(:stdinfile)
        return superclass.execute([cmd, options[:stdinfile]].flatten.join(' '), options)
      end
      return superclass.execute([cmd].flatten.join(' '), options)
    rescue Puppet::ExecutionFailure => e
      cli_auth_errors.each do |error|
        raise AuthError, e.message, e.backtrace if e.message.match(error)
      end

      net_errors.each do |error|
        raise NetError, e.message, e.backtrace if e.message.match(error)
      end

      raise UnknownError, e.message, e.backtrace
    end
  end
  private_class_method :execute_exceptionify
end
