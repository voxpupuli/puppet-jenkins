# frozen_string_literal: true

# jenkins.rb
#
# Creates a fact 'jenkins_plugins' containing a comma-delimited string of all
# jenkins plugins + versions.
require 'facter'
require_relative '../puppet/jenkins/plugins'

Facter.add(:jenkins_plugins) do
  confine kernel: 'Linux'
  setcode do
    Puppet::Jenkins::Plugins.available
  end
end