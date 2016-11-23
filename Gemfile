source 'https://rubygems.org'

gem 'rake', '>= 10.1.1'
gem 'rspec-its'
gem 'puppet-lint', '~> 1.0'
gem 'rspec-puppet', '~> 2.1.0'
gem 'puppetlabs_spec_helper',   :require => false
gem 'puppet-syntax', '>= 1.1.0'
gem 'json'
gem 'puppet', ENV['PUPPET_VERSION'] || '~> 4.7'
gem 'metadata-json-lint'
gem 'retries', '~> 0.0.5'
gem 'travis', '~> 1.8'
gem 'parallel_tests', :platform => [:mri_20, :mri_21]
gem 'rubocop', '< 0.42.0'
gem 'public_suffix', '1.4.6', :require => false if RUBY_VERSION <= '1.9.3'
gem 'public_suffix',          :require => false if RUBY_VERSION > '1.9.3'

gem 'json_pure', '< 2.0.2'
gem 'net-http-persistent', '<= 2.9.4', :require => false if RUBY_VERSION < '2.0.0'

group :development do
  gem 'simplecov'
  gem 'ci_reporter'
  gem 'debugger', :platform => :mri_19
  gem 'debugger-pry', :platform => :mri_19
  gem 'byebug', :platform => [:mri_20, :mri_21]
  gem 'pry'
  gem 'pry-byebug', :platform => [:mri_20, :mri_21]
end

group :system_tests do
  gem 'beaker-rspec', '~> 5.6.0', :require => false
  gem 'serverspec',    :require => false
  gem 'vagrant-wrapper',:require => false
  gem 'beaker-puppet_install_helper', :require => false
end
