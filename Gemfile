source 'https://rubygems.org'

gem 'rake', '>= 10.1.1'
gem 'rspec-its'
gem 'puppet-lint', '~> 1.0'
gem 'rspec-puppet', '~> 2.1.0'
gem 'puppetlabs_spec_helper',   :require => false
gem 'puppet-syntax', '~> 2.0'
gem 'json'
gem 'puppet', ENV['PUPPET_VERSION'] || '~> 4.7'
gem 'metadata-json-lint'
gem 'retries', '~> 0.0.5'
gem 'travis', '~> 1.8'
gem 'parallel_tests'
gem 'rubocop', '< 0.42.0'

gem 'puppet-strings'

group :development do
  gem 'simplecov'
  gem 'ci_reporter'
  gem 'byebug'
  gem 'pry'
  gem 'pry-byebug'
end

group :system_tests do
  gem 'beaker-rspec', '~> 6.0.0', :require => false
  gem 'serverspec',    :require => false
  gem 'vagrant-wrapper',:require => false
  gem 'beaker-puppet_install_helper', :require => false
end
