require 'fileutils'
require 'vagrant'


Given /^I have a running Ubuntu VM$/ do
  puts "Bringing up VM, this may take a while"
  @vagrant_root = File.join(@project_root, 'features', 'support', 'boxes', 'deb')
  File.exists?(File.join(@vagrant_root, '/Vagrantfile')).should == true
  @vagrant = Vagrant::Environment.new(:cwd => @vagrant_root)
  @vagrant.cli('up', '--no-provision')
end

Given /^I have Puppet installed$/ do
  run_command('which puppet', :silent => true)
end

Given /^the Jenkins module is on the machine$/ do
  tarball = Dir['pkg/rtyler-jenkins*.tar.gz'].last
  package_path = File.join(@project_root, tarball)
  FileUtils.cp(package_path, @vagrant_root)

  puts 'Installing module pre-requisites'
  run_sudo_command('/vagrant/install-puppet-module.sh', :silent => true)
  run_sudo_command('puppet-module install puppetlabs/stdlib --force')
  run_sudo_command('puppet-module install puppetlabs/apt --force')
  run_sudo_command("puppet-module install /vagrant/#{tarball} --force")
end

Given /^the manifest:$/ do |manifest|
  @manifest_path = File.join(@vagrant_root, 'cucumber.pp')

  if File.exists? @manifest_path
    File.unlink(@manifest_path)
  end

  File.open(@manifest_path, 'w') do |f|
    f.write(manifest)
  end
end

When /^I provision the machine$/ do
  run_sudo_command('puppet apply --modulepath=/home/vagrant /vagrant/cucumber.pp')
end

Then /^I should have Jenkins installed$/ do
  run_command('/vagrant/verify-jenkins-install')
end
