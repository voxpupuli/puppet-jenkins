require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'
require 'cucumber/rake/task'

exclude_paths = [
  "pkg/**/*",
  "vendor/**/*",
  "spec/**/*",
]

PuppetLint.configuration.log_format = "%{path}:%{linenumber}:%{check}:%{KIND}:%{message}"
PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.send("disable_80chars")
PuppetLint.configuration.send("disable_autoloader_layout")
PuppetLint.configuration.send("disable_quoted_booleans")
PuppetLint.configuration.send('disable_class_parameter_defaults')
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
PuppetLint.configuration.ignore_paths = exclude_paths
PuppetSyntax.exclude_paths = exclude_paths


task :default => [:spec]


desc "Build package"
task :build do
  sh 'puppet-module build'
end


Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = ['--color', '--format pretty', '--format junit -o test_reports']
end


desc "Run the full integration test suite (slow!)"
task :integration => [:lint, :spec, :build, :cucumber]

namespace :spec do
  desc "Make sure some of the rspec-puppet directories/files are in place"
  task :check do
    dot_puppet = File.expand_path('~/.puppet')
    unless File.exists?(dot_puppet) and File.directory?(dot_puppet)
      puts 'rspec-puppet needs a ~/.puppet directory to run properly'
      puts
      puts 'I\'ll go ahead and make one for you'
      Dir.mkdir(dot_puppet)
      puts
    end

    unless File.exists?(File.join(dot_puppet, '/manifests/site.pp'))
      puts 'rspec puppet needs (dummy) ~/.puppet/manifests/site.pp file to run properly'
      puts
      puts 'I\'ll go ahead and make one for you'
      Dir.mkdir(File.join(dot_puppet, '/manifests'))
      File.open(File.join(dot_puppet, '/manifests/site.pp'), 'w') do |fd|
        fd.write('')
      end
    end
  end
end
