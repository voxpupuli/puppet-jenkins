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
        include jenkins
      """
    When I provision the machine
    Then I should have Jenkins installed

  Scenario: Install the git plugin
    Given the manifest:
      """
        include jenkins
        jenkins::plugin {
          'git' :
            ensure  => present,
            require => Class['jenkins'];
        }
      """
    When I provision the machine
    Then I should have Jenkins installed
    And I should have the "git" plugin installed
