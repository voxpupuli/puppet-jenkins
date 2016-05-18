require 'rubygems'
require 'rake'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'
require 'parallel_tests'
require 'parallel_tests/cli'
require 'rubocop/rake_task'

RuboCop::RakeTask.new

exclude_paths = [
  'pkg/**/*',
  'vendor/**/*',
  'spec/**/*',
  'contrib/**/*'
]

# Make sure we don't have the default rake task floating around
Rake::Task['lint'].clear

PuppetLint.configuration.relative = true
PuppetLint::RakeTask.new(:lint) do |l|
  l.disable_checks = %w(80chars class_inherits_from_params_class)
  l.ignore_paths = exclude_paths
  l.fail_on_warnings = true
  l.log_format = '%{path}:%{linenumber}:%{check}:%{KIND}:%{message}'
end

desc 'Run acceptance tests'
RSpec::Core::RakeTask.new(:acceptance) do |t|
  t.pattern = 'spec/acceptance'
end

PuppetSyntax.exclude_paths = exclude_paths

namespace :travis do
  desc 'Syntax check travis.yml'
  task :lint do
    # warnings are currently non-fatal due to suspected problems with
    # validation of matrix::include
    #sh "travis lint --exit-code" do |ok, res|
    sh 'travis lint' do |ok, res|
      unless ok
        # exit without verbose rake error message
        exit res.exitstatus
      end
    end
  end
end

desc 'Parallel spec tests'
task :parallel_spec do
  Rake::Task[:spec_prep].invoke
  ParallelTests::CLI.new.run('--type test -t rspec spec/classes spec/defines spec/unit spec/functions'.split)
  Rake::Task[:spec_clean].invoke
end

task :default => [
  'travis:lint',
  :rubocop,
  :lint,
  :validate,
  :spec,
]
