Feature: Support adding Jenkins via Puppet on Debian machines
  In order to install Jenkins on a Debian or Ubuntu host
  As a sysadmin
  I want to include Jenkins in my manifests and have it installed and running


  Background:
    Given I have a running Ubuntu VM
    And I have Puppet installed
    And the Jenkins module is on the machine

  Scenario: Install Jenkins via Puppet
    Given the manifest:
      """
        node default {
          # This sucks
          group { 'puppet' : ensure => present ; }
          include jenkins
        }
      """
    When I provision the machine
    Then I should have Jenkins installed
