require 'spec_helper_acceptance'

describe 'jenkins class' do

  context 'default parameters' do
    it 'should work with no errors' do
      pp = <<-EOS
      include jenkins

      jenkins::plugin {'git-plugin':
        name    => 'git',
        version => '2.3.4',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_failures => true)
    end

    # Check Git Plugin Installed
    describe file('/var/lib/jenkins/plugins/git.hpi') do
      it { should be_file }
    end

  end

end
