require 'spec_helper'

describe 'jenkins::credentials', type: :define do
  let(:title) { 'foo' }
  let(:facts) do
    {
      osfamily: 'RedHat',
      operatingsystem: 'RedHat',
      operatingsystemrelease: '6.7',
      operatingsystemmajrelease: '6'
    }
  end
  let(:helper_cmd) { '/usr/bin/java -jar cli.jar -s http://127.0.0.1:8080 groovy /var/lib/jenkins/puppet_helper.groovy' }
  let(:pre_condition) do
    "class jenkins::cli_helper { $helper_cmd = '#{helper_cmd}' }"
  end

  describe 'relationships' do
    let(:params) { { password: 'foo' } }

    it do
      is_expected.to contain_jenkins__credentials('foo').
        that_requires('Class[jenkins::cli_helper]')
    end
    it do
      is_expected.to contain_jenkins__credentials('foo').
        that_comes_before('Anchor[jenkins::end]')
    end
  end

  describe 'with ensure is present' do
    let(:params) do
      {
        ensure: 'present',
        password: 'mypass'
      }
    end

    it {
      is_expected.to contain_jenkins__cli__exec('create-jenkins-credentials-foo').with(command: ['create_or_update_credentials', title.to_s, "'mypass'",
                                                                                                 "''", "'Managed by Puppet'", "''"],
                                                                                       unless: "for i in \$(seq 1 10); do \$HELPER_CMD credential_info #{title} && break || sleep 10; done | grep #{title}")
    }
  end

  describe 'with ensure is absent' do
    let(:params) do
      {
        ensure: 'absent',
        password: 'mypass'
      }
    end

    it { is_expected.to contain_jenkins__cli__exec('delete-jenkins-credentials-foo').with(command: ['delete_credentials', title.to_s]) }
  end

  describe 'with uuid set' do
    let(:params) do
      {
        ensure: 'present',
        password: 'mypass',
        uuid: 'e94d3b98-5ba4-43b9-89ed-79a08ea97f6f'
      }
    end

    it {
      is_expected.to contain_jenkins__cli__exec('create-jenkins-credentials-foo').with(command: ['create_or_update_credentials', title.to_s, "'mypass'",
                                                                                                 "'e94d3b98-5ba4-43b9-89ed-79a08ea97f6f'", "'Managed by Puppet'", "''"],
                                                                                       unless: "for i in \$(seq 1 10); do \$HELPER_CMD credential_info #{title} && break || sleep 10; done | grep #{title}")
    }
  end
end
