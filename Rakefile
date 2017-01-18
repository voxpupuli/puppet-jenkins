require 'puppetlabs_spec_helper/rake_tasks'
require 'rubocop/rake_task'
require 'puppet-strings/tasks'

RuboCop::RakeTask.new

exclude_paths = [
  'pkg/**/*',
  'vendor/**/*',
  'spec/**/*',
  'examples/**/*'
]

# Make sure we don't have the default rake task floating around
Rake::Task['lint'].clear

PuppetLint.configuration.relative = true
PuppetLint::RakeTask.new(:lint) do |l|
  l.disable_checks = %w(80chars class_inherits_from_params_class)
  l.ignore_paths = exclude_paths
  l.fail_on_warnings = true
  l.log_format = '%{path}:%{line}:%{check}:%{KIND}:%{message}'
end

PuppetSyntax.exclude_paths = exclude_paths

namespace :travis do
  desc 'Syntax check travis.yml'
  task :lint do
    # warnings are currently non-fatal due to suspected problems with
    # validation of matrix::include
    #sh "travis lint --exit-code" do |ok, res|
    sh 'travis lint --skip-completion-check' do |ok, res|
      unless ok
        # exit without verbose rake error message
        exit res.exitstatus
      end
    end
  end
end

default_tasks = [
  :lint,
  :validate,
  :parallel_spec,
]

# rubocop 0.47.0 blows up with puppet 3.8, mostly likely due to monkey patching
# shenanigans:
#   Running RuboCop...
#   wrong number of arguments (5 for 1..3)
#  ../puppet-jenkins/.bundle/ruby/2.0.0/gems/puppet-3.8.7/lib/puppet/vendor/safe_yaml/lib/safe_yaml.rb:162:in `safe_load'

require 'puppet'
if not Puppet.version =~ /^3/
  default_tasks.unshift :rubocop
end

task :default => default_tasks
