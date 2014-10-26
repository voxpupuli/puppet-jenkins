require 'spec_helper'

describe 'jenkins', :type => :module do
  let(:facts) { { :osfamily => 'RedHat', :operatingsystem => 'RedHat' } }

  context 'cli' do
    context 'default' do
      it { should_not contain_class('jenkins::cli') }
    end

    context '$cli => true' do
      let(:params) {{ :cli => true,
                      :config_hash => { 'HTTP_PORT' => { 'value' => '9000' } }
      }}
      it { should create_class('jenkins::cli') }
      it { should contain_exec('jenkins-cli') }
      it { should contain_exec('reload-jenkins').with_command(/http:\/\/localhost:9000/) }
      it { should contain_exec('safe-restart-jenkins') }
      it { should contain_jenkins__sysconfig('HTTP_PORT').with_value('9000') }
    end
  end

end
