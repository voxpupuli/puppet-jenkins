source 'https://rubygems.org'

gem 'rake'
gem 'puppet-lint'
gem 'rspec-puppet'
gem 'puppetlabs_spec_helper'
gem 'puppet-syntax'
gem 'puppet', ENV['PUPPET_VERSION'] || '~> 3.5.1'

group :development do
  gem 'rcov'
  gem 'parallel_tests'
  gem 'ci_reporter'
  gem 'debugger', :platform => :mri
  gem 'debugger-pry', :platform => :mri
end
