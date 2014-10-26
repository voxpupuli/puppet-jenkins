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

group :development do
  gem 'simplecov'
  gem 'parallel_tests'
  gem 'ci_reporter'
  gem 'debugger', :platform => :mri
  gem 'debugger-pry', :platform => :mri

  gem 'serverspec'
  gem 'vagrant', :github => 'mitchellh/vagrant',
                 :ref => 'v1.6.5',
                 :platform => [:mri_19, :mri_21]
end

# Vagrant plugins
group :plugins do
  gem 'vagrant-aws', :github => 'mitchellh/vagrant-aws',
                 :platform => [:mri_19, :mri_21]
  gem 'vagrant-serverspec', :github => 'jvoorhis/vagrant-serverspec',
                 :platform => [:mri_19, :mri_21]
end
