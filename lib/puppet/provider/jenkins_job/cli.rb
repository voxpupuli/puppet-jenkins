require 'puppet/util/warnings'

require 'puppet_x/jenkins/util'
require 'puppet_x/jenkins/provider/cli'

Puppet::Type.type(:jenkins_job).provide(:cli, :parent => PuppetX::Jenkins::Provider::Cli) do

  mk_resource_methods

  def self.instances(catalog = nil)
    job_names = list_jobs(catalog)

    Puppet.debug("#{sname} instances: #{job_names}")

    # XXX iterating over each job is slow because it requires 2 invocations of
    # the cli jar.  This should be replaced with a puppet_helper method to
    # return the configuration for all jobs at once.
    job_names.collect do |job|
      new(
        :name   => job,
        :ensure => :present,
        :config => get_job(job, catalog),
        :enable => job_enabled(job, catalog),
      )
    end
  end

  # ignore #create so we can differentiate in #flush between an update to an
  # existing job and creating a new one
  def create
  end

  def flush
    update = false
    if exists?
      update = true
    end

    unless resource.nil?
      @property_hash = resource.to_hash
    end

    # XXX the enable property is being ignored on flush because this modifies
    # the configuration string and breaks idempotent.  Should the property be
    # removed?
    case self.ensure
    when :present
      if update
        update_job
      else
        create_job
      end
    when :absent
      delete_job
    else
      fail("invalid :ensure value: #{self.ensure}")
    end
  end

  private

  def self.list_jobs(catalog = nil)
    cli(['list-jobs'], :catalog => catalog).split
  end
  private_class_method :list_jobs

  def self.get_job(job, catalog = nil)
    cli(['get-job', job], :catalog => catalog)
  end
  private_class_method :get_job

  def self.job_enabled(job, catalog = nil)
    raw = clihelper(['job_enabled', job], :catalog => catalog)
    !!(raw =~ /true/)
  end
  private_class_method :job_enabled

  def create_job
    cli(['create-job', name], :stdin => config)
  end

  def update_job
    cli(['update-job', name], :stdin => config)
  end

  def delete_job
    cli(['delete-job', name])
  end
end
