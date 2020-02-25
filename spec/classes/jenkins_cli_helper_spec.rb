require 'spec_helper'

describe 'jenkins::cli_helper' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:libdir) { facts[:os]['family'] == 'Debian' ? '/usr/share/jenkins' : '/usr/lib/jenkins' }

      describe 'relationships' do
        it do
          is_expected.to contain_class('jenkins::cli')
          is_expected.to contain_class('jenkins::cli_helper').
            that_requires('Class[jenkins::cli]')
        end
        it do
          is_expected.to contain_class('jenkins::cli_helper').
            that_comes_before('Anchor[jenkins::end]')
        end
      end

      it do
        is_expected.to contain_file("#{libdir}/puppet_helper.groovy").with(
          source: 'puppet:///modules/jenkins/puppet_helper.groovy',
          owner: 'jenkins',
          group: 'jenkins',
          mode: '0444'
        )
      end
    end
  end
end
