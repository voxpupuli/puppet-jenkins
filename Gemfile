source 'https://rubygems.org'

gem 'rake', '>= 10.1.1',                         :require => false
gem 'rspec-its',                                 :require => false
gem 'puppet-lint', '~> 2.0',                     :require => false
gem 'rspec-puppet', '~> 2.5.0',                  :require => false
gem 'puppetlabs_spec_helper', '~> 1.2.2',        :require => false
gem 'puppet-syntax', '~> 2.0',                   :require => false
gem 'json',                                      :require => false
gem 'puppet', ENV['PUPPET_VERSION'] || '~> 4.7', :require => false
gem 'metadata-json-lint',                        :require => false
gem 'retries', '~> 0.0.5',                       :require => false
gem 'travis', '~> 1.8',                          :require => false
gem 'parallel_tests',                            :require => false
gem 'rubocop', '< 0.42.0',                       :require => false
gem 'puppet-strings',                            :require => false

group :development do
  gem 'simplecov'
  gem 'ci_reporter'
  gem 'byebug'
  gem 'pry'
  gem 'pry-byebug'
end

group :system_tests do
  gem 'beaker-rspec', '~> 6.0.0',     :require => false
  gem 'serverspec',                   :require => false
  gem 'vagrant-wrapper',              :require => false
  gem 'beaker-puppet_install_helper', :require => false
end
