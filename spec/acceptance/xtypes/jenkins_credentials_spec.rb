require 'spec_helper_acceptance'

describe 'jenkins_credentials' do
  include_context 'jenkins'

  context 'ensure =>' do
    context 'present' do
      context 'UsernamePasswordCredentialsImpl' do
        it 'should work with no errors' do
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

          # Run it twice and test for idempotency
          apply_manifest(pp, :catch_failures => true)
          apply_manifest(pp, :catch_failures => true)
        end

        describe file('/var/lib/jenkins/credentials.xml') do
          # XXX need to properly compare the XML doc
          # trying to match anything other than the id this way might match other
          # credentails
          it { should contain '<id>9b07d668-a87e-4877-9407-ae05056e32ac</id>' }
        end
      end

      context 'BasicSSHUserPrivateKey' do
        it 'should work with no errors' do
          pp = base_manifest + <<-EOS
            jenkins_credentials { 'a0469025-1202-4007-983d-0c62f230f1a7':
              ensure      => 'present',
              description => 'bar',
              domain      => undef,
              impl        => 'BasicSSHUserPrivateKey',
              passphrase  => '',
              private_key => '-----BEGIN RSA PRIVATE KEY----- ...',
              scope       => 'SYSTEM',
              username    => 'robin',
            }
          EOS

          # Run it twice and test for idempotency
          apply_manifest(pp, :catch_failures => true)
          apply_manifest(pp, :catch_failures => true)
        end

        describe file('/var/lib/jenkins/credentials.xml') do
          # XXX need to properly compare the XML doc
          # trying to match anything other than the id this way might match other
          # credentails
          it { should contain '<id>a0469025-1202-4007-983d-0c62f230f1a7</id>' }
        end
      end

      context 'StringCredentialsImpl' do
        it 'should work with no errors' do
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

          # Run it twice and test for idempotency
          apply_manifest(pp, :catch_failures => true)
          apply_manifest(pp, :catch_failures => true)
        end

        describe file('/var/lib/jenkins/credentials.xml') do
          # XXX need to properly compare the XML doc
          # trying to match anything other than the id this way might match other
          # credentails
          it { should contain '<id>150b2895-b0eb-4813-b8a5-3779690c063c</id>' }
        end
      end
    end # 'present' do

    context 'absent' do
      context 'StringCredentialsImpl' do
        it 'should work with no errors' do
          pp = base_manifest + <<-EOS
            jenkins::plugin { 'plain-credentials':
              pin => true,
            }

            jenkins_credentials { '150b2895-b0eb-4813-b8a5-3779690c063c':
              ensure      => 'absent',
              description => 'baz',
              domain      => undef,
              impl        => 'StringCredentialsImpl',
              scope       => 'SYSTEM',
              secret      => 'fluffy bunny',
            }
          EOS

          # Run it twice and test for idempotency
          apply_manifest(pp, :catch_failures => true)
          apply_manifest(pp, :catch_failures => true)
        end

        describe file('/var/lib/jenkins/credentials.xml') do
          # XXX need to properly compare the XML doc
          # trying to match anything other than the id this way might match other
          # credentails
          it { should_not contain '<id>150b2895-b0eb-4813-b8a5-3779690c063c</id>' }
        end
      end
    end # 'absent' do
  end # 'ensure =>' do
end
