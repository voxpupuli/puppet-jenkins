require 'spec_helper'

describe 'jenkins::credentials', :type => :define do
  let(:title) { 'foo' }
  let(:facts) do
    {
      :osfamily                  => 'RedHat',
      :operatingsystem           => 'RedHat',
      :operatingsystemrelease    => '6.7',
      :operatingsystemmajrelease => '6',
    }
  end
  let(:helper_cmd) { '/usr/bin/java -jar cli.jar -s http://127.0.0.1:8080 groovy /var/lib/jenkins/puppet_helper.groovy' }
  let(:pre_condition) {
    "class jenkins::cli_helper { $helper_cmd = '#{helper_cmd}' }"
  }

  describe 'relationships' do
    let(:params) {{ :password => 'foo' }}
    it do
      should contain_jenkins__credentials('foo').
        that_requires('Class[jenkins::cli_helper]')
    end
    it do
      should contain_jenkins__credentials('foo').
        that_comes_before('Anchor[jenkins::end]')
    end
  end

  describe 'with ensure is present' do
    let(:params) {{
      :ensure   => 'present',
      :password => 'mypass',
    }}
    it { should contain_jenkins__cli__exec('create-jenkins-credentials-foo').with({
      :command    => [ 'create_or_update_credentials' , "#{title}", "'mypass'",
                       "''", "'Managed by Puppet'", "''" ],
      :unless     => "\$HELPER_CMD credential_info #{title} | grep #{title}",
    })}
  end

  describe 'with ensure is absent' do
    let(:params) {{
      :ensure   => 'absent',
      :password => 'mypass',
    }}
    it { should contain_jenkins__cli__exec('delete-jenkins-credentials-foo').with({
      :command    => [ 'delete_credentials', "#{title}" ],
    })}
  end

  describe 'with uuid set' do
    let(:params) {{
      :ensure   => 'present',
      :password => 'mypass',
      :uuid     => 'e94d3b98-5ba4-43b9-89ed-79a08ea97f6f',
    }}
    it { should contain_jenkins__cli__exec('create-jenkins-credentials-foo').with({
      :command    => [ 'create_or_update_credentials' , "#{title}", "'mypass'",
                       "'e94d3b98-5ba4-43b9-89ed-79a08ea97f6f'", "'Managed by Puppet'", "''" ],
      :unless     => "\$HELPER_CMD credential_info #{title} | grep #{title}",
    })}
  end

end
