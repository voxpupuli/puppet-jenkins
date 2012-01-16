require 'rake'
require 'rspec/core/rake_task'

task :default => [:spec]

desc "Run all module spec tests (Requires rspec-puppet gem)"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.fail_on_error = false
end

desc "Build package"
task :build do
  sh 'puppet-module build'
end

