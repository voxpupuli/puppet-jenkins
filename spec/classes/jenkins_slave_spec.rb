require 'spec_helper'

describe 'jenkins::slave' do
  let(:upstart_file) { '/etc/init/jenkins-slave.conf' }

  describe 'no params, defaults' do
    it { should contain_file(upstart_file) }

    it { should_not contain_file(upstart_file).with_content(/-username/) }
    it { should_not contain_file(upstart_file).with_content(/-password/) }
  end

  describe 'ui_user and ui_pass' do
    let(:params) {{
      :ui_user => 'jenkins.slave',
      :ui_pass => 'mekmitasdigoat',
    }}

    it { should contain_file(upstart_file).with_content(/ -username jenkins.slave /) }
    it { should contain_file(upstart_file).with_content(/ -password mekmitasdigoat /) }
  end
end
