# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'jenkins_credentials' do
  include_context 'jenkins'

  context 'ensure =>' do
    context 'present' do
      context 'UsernamePasswordCredentialsImpl' do
        it 'works with no errors and idempotently' do
          pp = base_manifest + <<-EOS
            jenkins_credentials { '9b07d668-a87e-4877-9407-ae05056e32ac':
              ensure      => 'present',
              description => 'foo',
              domain      => undef,
              impl        => 'UsernamePasswordCredentialsImpl',
              password    => 'password',
              scope       => 'GLOBAL',
              username    => 'batman',
            }
          EOS

          apply(pp, catch_failures: true)
          apply(pp, catch_changes: true)
        end

        describe file('/var/lib/jenkins/credentials.xml') do
          # XXX need to properly compare the XML doc
          # trying to match anything other than the id this way might match other
          # credentails
          it { is_expected.to contain '<id>9b07d668-a87e-4877-9407-ae05056e32ac</id>' }
        end
      end

      context 'ConduitCredentialsImpl' do
        it 'works with no errors and idempotently' do
          pp = base_manifest + <<-EOS
            jenkins::plugin { 'phabricator-plugin':
            }

            jenkins_credentials { '002224bd-60cb-49f3-a314-d0f73f82233d':
              ensure      => 'present',
              description => 'phabricator-jenkins-conduit',
              domain      => undef,
              impl        => 'ConduitCredentialsImpl',
              token       => '{PRIVATE TOKEN}',
              url         => 'https://my-phabricator-repo.com',
            }
          EOS

          apply(pp, catch_failures: true)
          apply(pp, catch_changes: true)
        end

        # XXX need to properly compare the XML doc
        # trying to match anything other than the id this way might match other
        # credentials
        describe file('/var/lib/jenkins/credentials.xml') do
          it { is_expected.to contain '<id>002224bd-60cb-49f3-a314-d0f73f82233d</id>' }
        end
      end

      context 'BasicSSHUserPrivateKey' do
        it 'works with no errors and idempotently' do
          pp = base_manifest + <<-EOS
            # At least on EL7 version 1.0.4 is shipped and ssh-credentials
            # needs >= 1.0.5. 1.0.8 is the latests at the time of writing.
            jenkins::plugin { 'trilead-api':
              version => '1.0.8',
            }

            jenkins::plugin { 'ssh-credentials': }

            jenkins_credentials { 'a0469025-1202-4007-983d-0c62f230f1a7':
              ensure      => 'present',
              description => 'bar',
              domain      => undef,
              impl        => 'BasicSSHUserPrivateKey',
              passphrase  => undef,
              private_key => "-----BEGIN RSA PRIVATE KEY----- ...\n",
              scope       => 'SYSTEM',
              username    => 'robin',
            }
          EOS

          apply(pp, catch_failures: true)
          apply(pp, catch_changes: true)
        end

        describe file('/var/lib/jenkins/credentials.xml') do
          # XXX need to properly compare the XML doc
          # trying to match anything other than the id this way might match other
          # credentails
          it { is_expected.to contain '<id>a0469025-1202-4007-983d-0c62f230f1a7</id>' }
        end
      end

      context 'StringCredentialsImpl' do
        it 'works with no errors and idempotently' do
          pp = base_manifest + <<-EOS
            jenkins::plugin { 'plain-credentials':
              pin => true,
            }

            jenkins_credentials { '150b2895-b0eb-4813-b8a5-3779690c063c':
              ensure      => 'present',
              description => 'baz',
              domain      => undef,
              impl        => 'StringCredentialsImpl',
              scope       => 'SYSTEM',
              secret      => 'fluffy bunny',
            }
          EOS

          apply(pp, catch_failures: true)
          apply(pp, catch_changes: true)
        end

        describe file('/var/lib/jenkins/credentials.xml') do
          # XXX need to properly compare the XML doc
          # trying to match anything other than the id this way might match other
          # credentails
          it { is_expected.to contain '<id>150b2895-b0eb-4813-b8a5-3779690c063c</id>' }
        end
      end

      context 'FileCredentialsImpl' do
        it 'works with no errors and idempotently' do
          pp = base_manifest + <<-EOS
            jenkins::plugin { 'plain-credentials':
              pin => true,
            }

            jenkins_credentials { '95bfe159-8bf0-4605-be20-47e201220e7c':
              ensure      => 'present',
              description => 'secret file with very secret data',
              domain      => undef,
              impl        => 'FileCredentialsImpl',
              scope       => 'GLOBAL',
              file_name   => 'foo.bar',
              content     => 'secret data on 1st line\nsecret data on 2nd line'
            }
          EOS

          apply(pp, catch_failures: true)
          apply(pp, catch_changes: true)
        end

        describe file('/var/lib/jenkins/credentials.xml') do
          # XXX need to properly compare the XML doc
          # trying to match anything other than the id this way might match other
          # credentails
          it { is_expected.to contain '<id>95bfe159-8bf0-4605-be20-47e201220e7c</id>' }
        end
      end

      context 'AWSCredentialsImpl' do
        it 'works with no errors and idempotently' do
          pending('jenkins plugin tests are not consistently failing or succeeding: https://github.com/voxpupuli/puppet-jenkins/issues/839')
          pp = base_manifest + <<-EOS
            jenkins::plugin { [
              'jackson2-api',
              'aws-java-sdk',
              'credentials-binding',
              'workflow-step-api',
              'ssh-credentials',
              'aws-credentials',
              'plain-credentials',
            ]: }

            jenkins_credentials { '34d75c64-61ff-4a28-bd40-cac3aafc7e3a':
              ensure      => 'present',
              description => 'aws credential',
              impl        => 'AWSCredentialsImpl',
              access_key  => 'much access',
              secret_key  => 'many secret',
            }
          EOS

          apply(pp, catch_failures: true)
          apply(pp, catch_changes: true)
        end

        describe file('/var/lib/jenkins/credentials.xml') do
          # XXX need to properly compare the XML doc
          # trying to match anything other than the id this way might match other
          # credentails
          it {
            pending('jenkins plugin tests are not consistently failing or succeeding: https://github.com/voxpupuli/puppet-jenkins/issues/839')
            is_expected.to contain '<id>34d75c64-61ff-4a28-bd40-cac3aafc7e3a</id>'
          }
        end
      end

      context 'GitLabApiTokenImpl' do
        it 'works with no errors and idempotently' do
          pending('jenkins plugin tests are not consistently failing or succeeding: https://github.com/voxpupuli/puppet-jenkins/issues/839')
          pp = base_manifest + <<-EOS
            package { 'git': }
            jenkins::plugin { [
              'matrix-project',
              'junit',
              'script-security',
              'workflow-api',
              'workflow-step-api',
              'workflow-scm-step',
              'git',
              'git-client',
              'mailer',
              'display-url-api',
              'scm-api',
              'ssh-credentials',
              'apache-httpcomponents-client-4-api',
              'jsch',
              'gitlab-plugin',
            ]: }

            jenkins_credentials { '7e86e9fb-a8af-480f-b596-7191dc02bf38':
              ensure      => 'present',
              description => 'GitLab API token',
              impl        => 'GitLabApiTokenImpl',
              api_token   => 'tokens for days',
            }
          EOS

          apply(pp, catch_failures: true)
          apply(pp, catch_changes: true)
        end

        describe file('/var/lib/jenkins/credentials.xml') do
          # XXX need to properly compare the XML doc
          # trying to match anything other than the id this way might match other
          # credentails
          it {
            pending('jenkins plugin tests are not consistently failing or succeeding: https://github.com/voxpupuli/puppet-jenkins/issues/839')
            is_expected.to contain '<id>7e86e9fb-a8af-480f-b596-7191dc02bf38</id>'
          }
        end
      end

      context 'BrowserStackCredentials' do
        it 'works with no errors and idempotently' do
          pending('jenkins plugin tests are not consistently failing or succeeding: https://github.com/voxpupuli/puppet-jenkins/issues/839')
          pp = base_manifest + <<-EOS
            jenkins::plugin { [
              'jackson2-api',
              'credentials-binding',
              'workflow-step-api',
              'ssh-credentials',
              'plain-credentials',
              'browserstack-integration'
            ]: }

            jenkins_credentials { '562fa23d-a441-4cab-997f-58df6e245813':
              ensure      => 'present',
              description => 'browserstack credentials',
              impl        => 'BrowserStackCredentials',
              username    => 'whats this?',
              secret_key  => 'you know I payed for this',
            }
          EOS

          apply(pp, catch_failures: true)
          apply(pp, catch_changes: true)
        end

        describe file('/var/lib/jenkins/credentials.xml') do
          # XXX need to properly compare the XML doc
          # trying to match anything other than the id this way might match other
          # credentails
          it {
            pending('jenkins plugin tests are not consistently failing or succeeding: https://github.com/voxpupuli/puppet-jenkins/issues/839')
            is_expected.to contain '<id>562fa23d-a441-4cab-997f-58df6e245813</id>'
          }
        end
      end
    end

    context 'absent' do
      context 'StringCredentialsImpl' do
        it 'works with no errors and idempotently' do
          pp = base_manifest + <<-EOS
            jenkins::plugin { 'plain-credentials': }

            jenkins_credentials { '150b2895-b0eb-4813-b8a5-3779690c063c':
              ensure      => 'absent',
              description => 'baz',
              domain      => undef,
              impl        => 'StringCredentialsImpl',
              scope       => 'SYSTEM',
              secret      => 'fluffy bunny',
            }
          EOS

          apply(pp, catch_failures: true)
          apply(pp, catch_changes: true)
        end

        describe file('/var/lib/jenkins/credentials.xml') do
          # XXX need to properly compare the XML doc
          # trying to match anything other than the id this way might match other
          # credentails
          it { is_expected.not_to contain '<id>150b2895-b0eb-4813-b8a5-3779690c063c</id>' }
        end
      end

      context 'FileCredentialsImpl' do
        it 'works with no errors and idempotently' do
          pp = base_manifest + <<-EOS
            jenkins::plugin { 'plain-credentials':
              pin => true,
            }

            jenkins_credentials { '95bfe159-8bf0-4605-be20-47e201220e7c':
              ensure      => 'absent',
              description => 'secret file with very secret data',
              domain      => undef,
              impl        => 'FileCredentialsImpl',
              scope       => 'GLOBAL',
              file_name   => 'foo.bar',
              content     => 'secret data on 1st line\nsecret data on 2nd line'
            }
          EOS

          apply(pp, catch_failures: true)
          apply(pp, catch_changes: true)
        end

        describe file('/var/lib/jenkins/credentials.xml') do
          # XXX need to properly compare the XML doc
          # trying to match anything other than the id this way might match other
          # credentails
          it { is_expected.not_to contain '<id>95bfe159-8bf0-4605-be20-47e201220e7</id>' }
        end
      end
    end
  end
end
