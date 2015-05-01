source 'https://rubygems.org'

gem 'rake', '>= 10.1.1'
gem 'rspec', '~> 2.99.0'
gem 'rspec-its'
gem 'puppet-lint', '>= 0.3.2'
gem 'rspec-puppet', '>= 1.0.1'
gem 'puppetlabs_spec_helper', :github => 'jenkins-infra/puppetlabs_spec_helper'
gem 'puppet-syntax', '>= 1.1.0'
gem 'json'
gem 'puppet', ENV['PUPPET_VERSION'] || '~> 3.5'
gem 'metadata-json-lint'

group :development do
  gem 'simplecov'
  gem 'parallel_tests'
  gem 'ci_reporter'
  gem 'debugger', :platform => :mri_19
  gem 'debugger-pry', :platform => :mri_19
  gem 'byebug', :platform => [:mri_20, :mri_21]
end

group :system_tests do
  gem 'beaker-rspec',  :require => false
  gem 'serverspec',    :require => false
  gem 'vagrant-wrapper',:require => false
end
