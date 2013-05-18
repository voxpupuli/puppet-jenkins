require 'rake'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'puppetlabs_spec_helper/rake_tasks'

task :default => [:spec]

desc "Check puppet manifests with puppet-lint"
task :lint do
  sh 'puppet-lint manifests'
  sh 'puppet-lint tests'
end

desc "Build package"
task :build do
  sh 'puppet-module build'
end


namespace :test do
  desc "Run the full integration test suite (slow!)"
  task :integration => [:lint, :spec, :build, :cucumber] do
  end

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

  Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = ['--color', '--format pretty',
              '--format junit -o test_reports']
  end
end
