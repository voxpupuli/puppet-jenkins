require 'puppet/util/warnings'

require 'json'

require File.join(File.dirname(__FILE__), '../../..', 'puppet/x/jenkins/util')
require File.join(File.dirname(__FILE__), '../../..', 'puppet/x/jenkins/provider/cli')

Puppet::Type.type(:jenkins_job).provide(:cli, parent: Puppet::X::Jenkins::Provider::Cli) do
  mk_resource_methods

  def self.instances(catalog = nil)
    jobs = job_list_json(catalog)

    Puppet.debug("#{sname} instances: #{jobs.map { |i| i['name'] }}")

    jobs.map do |job|
      new(
        name: job['name'],
        ensure: :present,
        config: job['config'],
        enable: job['enabled']
      )
    end
  end

  # ignore #create so we can differentiate in #flush between an update to an
  # existing job and creating a new one
  def create; end

  def flush
    update = false
    update = true if exists?

    @property_hash = resource.to_hash unless resource.nil?

    # XXX the enable property is being ignored on flush because this modifies
    # the configuration string and breaks idempotent.  Should the property be
    # removed?
    case self.ensure
    when :present
      if update
        update_job if replace
      else
        create_job
      end
    when :absent
      delete_job
    else
      raise Puppet::Error, "invalid :ensure value: #{self.ensure}"
    end
  end

  private

  # currently unused
  def self.list_jobs(catalog = nil)
    cli(['list-jobs'], catalog: catalog).split
  end
  private_class_method :list_jobs

  def self.job_list_json(catalog = nil)
    raw = clihelper(['job_list_json'], catalog: catalog)

    begin
      JSON.parse(raw)
    rescue JSON::ParserError
      raise Puppet::Error, "unable to parse as JSON: #{raw}"
    end
  end
  private_class_method :job_list_json

  # currently unused
  def self.get_job(job, catalog = nil)
    cli(['get-job', job], catalog: catalog)
  end
  private_class_method :get_job

  # currently unused
  def self.job_enabled(job, catalog = nil)
    raw = clihelper(['job_enabled', job], catalog: catalog)
    raw =~ %r{true} ? true : false
  end
  private_class_method :job_enabled

  def create_job
    cli(['create-job', name], stdin: config)
  end

  def update_job
    cli(['update-job', name], stdin: config)
  end

  def delete_job
    cli(['delete-job', name])
  end
end
