# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'jenkins_credentials' do
  context 'ensure =>' do
    context 'present' do
      context 'UsernamePasswordCredentialsImpl' do
        it 'works with no errors and idempotently' do
          pp = <<-EOS
            class {'jenkins':
              purge_plugins => true,
            }
            include jenkins::cli::config
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
          pp = <<-EOS
            class {'jenkins':
              purge_plugins => true,
            }
            include jenkins::cli::config

            jenkins::plugin { [
              'apache-httpcomponents-client-4-api',
              'caffeine-api',
              'command-launcher',
              'gson-api',
              'jaxb',
              'jdk-tool',
              'mina-sshd-api-common',
              'mina-sshd-api-core',
              'phabricator-plugin',
              'script-security',
              'sshd',
              'trilead-api',
            ]: }

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
          pp = <<-EOS
            class {'jenkins':
              purge_plugins => true,
            }
            include jenkins::cli::config

            jenkins::plugin { [
              'gson-api',
              'ssh-credentials',
              'variant',
              'trilead-api',
            ]: }

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
          pp = <<-EOS
            class {'jenkins':
              purge_plugins => true,
            }
            include jenkins::cli::config
            jenkins::plugin { 'plain-credentials':
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
          pp = <<-EOS
            class {'jenkins':
              purge_plugins => true,
            }
            include jenkins::cli::config
            jenkins::plugin { 'plain-credentials':
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
          pp = <<-EOS
            class {'jenkins':
              purge_plugins => true,
            }
            include jenkins::cli::config
            jenkins::plugin { [
              'apache-httpcomponents-client-4-api',
              'aws-credentials',
              'aws-java-sdk',
              'aws-java-sdk-cloudformation',
              'aws-java-sdk-codebuild',
              'aws-java-sdk-ec2',
              'aws-java-sdk-ecr',
              'aws-java-sdk-ecs',
              'aws-java-sdk-efs',
              'aws-java-sdk-elasticbeanstalk',
              'aws-java-sdk-iam',
              'aws-java-sdk-logs',
              'aws-java-sdk-minimal',
              'aws-java-sdk-sns',
              'aws-java-sdk-sqs',
              'aws-java-sdk-ssm',
              'caffeine-api',
              'credentials-binding',
              'gson-api',
              'jackson2-api',
              'jaxb',
              'joda-time-api',
              'json-api',
              'plain-credentials',
              'script-security',
              'snakeyaml-api',
              'ssh-credentials',
              'trilead-api',
              'variant',
              'workflow-step-api',
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
          it { is_expected.to contain '<id>34d75c64-61ff-4a28-bd40-cac3aafc7e3a</id>' }
        end
      end

      context 'GitLabApiTokenImpl' do
        it 'works with no errors and idempotently' do
          pp = <<-EOS
            class {'jenkins':
              purge_plugins => true,
            }
            include jenkins::cli::config
            package { 'git': }
            jenkins::plugin { [
              'asm-api',
              'apache-httpcomponents-client-4-api',
              'bootstrap5-api',
              'caffeine-api',
              'checks-api',
              'commons-lang3-api',
              'commons-text-api',
              'credentials-binding',
              'display-url-api',
              'echarts-api',
              'font-awesome-api',
              'git',
              'git-client',
              'gitlab-plugin',
              'gson-api',
              'ionicons-api',
              'jackson2-api',
              'jakarta-activation-api',
              'jakarta-mail-api',
              'jaxb',
              'jersey2-api',
              'joda-time-api',
              'jquery3-api',
              'jsch',
              'json-api',
              'junit',
              'mailer',
              'matrix-project',
              'mina-sshd-api-common',
              'mina-sshd-api-core',
              'plain-credentials',
              'plugin-util-api',
              'popper2-api',
              'scm-api',
              'script-security',
              'snakeyaml-api',
              'ssh-credentials',
              'sshd',
              'trilead-api',
              'variant',
              'workflow-api',
              'workflow-scm-step',
              'workflow-step-api',
              'workflow-support',
            ]: }
            jenkins::plugin { 'workflow-job':
              version => '1400.v7fd111b_ec82f'
            }

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
          it { is_expected.to contain '<id>7e86e9fb-a8af-480f-b596-7191dc02bf38</id>' }
        end
      end

      context 'BrowserStackCredentials' do
        pp = <<-EOS
          class {'jenkins':
            purge_plugins => true,
          }
          include jenkins::cli::config
          jenkins::plugin { [
            'ace-editor',
            'asm-api',
            'apache-httpcomponents-client-4-api',
            'bootstrap5-api',
            'browserstack-integration',
            'caffeine-api',
            'checks-api',
            'commons-lang3-api',
            'commons-text-api',
            'credentials-binding',
            'display-url-api',
            'durable-task',
            'echarts-api',
            'font-awesome-api',
            'gson-api',
            'ionicons-api',
            'jackson2-api',
            'jakarta-activation-api',
            'jakarta-mail-api',
            'jaxb',
            'joda-time-api',
            'jquery3-api',
            'json-api',
            'junit',
            'mailer',
            'plain-credentials',
            'plugin-util-api',
            'popper2-api',
            'scm-api',
            'script-security',
            'snakeyaml-api',
            'ssh-credentials',
            'trilead-api',
            'variant',
            'workflow-api',
            'workflow-basic-steps',
            'workflow-cps',
            'workflow-durable-task-step',
            'workflow-scm-step',
            'workflow-step-api',
            'workflow-support',
          ]: }
          jenkins::plugin { 'workflow-job':
            version => '1400.v7fd111b_ec82f'
          }

          jenkins_credentials { '562fa23d-a441-4cab-997f-58df6e245813':
            ensure      => 'present',
            description => 'browserstack credentials',
            impl        => 'BrowserStackCredentials',
            username    => 'whats this?',
            secret_key  => 'you know I payed for this',
          }
        EOS

        it 'works with no errors' do
          apply(pp, catch_failures: true)
        end

        it 'works idempotently' do
          pending('secret key is not idempotent')
          apply(pp, catch_changes: true)
        end

        describe file('/var/lib/jenkins/credentials.xml') do
          # XXX need to properly compare the XML doc
          # trying to match anything other than the id this way might match other
          # credentails
          it { is_expected.to contain '<id>562fa23d-a441-4cab-997f-58df6e245813</id>' }
        end
      end
    end

    context 'absent' do
      context 'StringCredentialsImpl' do
        it 'works with no errors and idempotently' do
          pp = <<-EOS
            class {'jenkins':
              purge_plugins => true,
            }
            include jenkins::cli::config
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
          pp = <<-EOS
            class {'jenkins':
              purge_plugins => true,
            }
            include jenkins::cli::config
            jenkins::plugin { 'plain-credentials':
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
