require 'spec_helper'

describe 'jenkins', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os} " do
      systemd_fact = case facts[:operatingsystemmajrelease]
                     when '6'
                       { systemd: false }
                     else
                       { systemd: true }
                     end
      let :facts do
        facts.merge(systemd_fact)
      end

      describe 'repo' do
        describe 'default' do
          case facts[:os]['family']
          when 'RedHat'
            describe 'RedHat' do
              it { is_expected.to compile.with_all_deps }
              it { is_expected.to contain_class('jenkins::repo::el') }
              it { is_expected.not_to contain_class('jenkins::repo::suse') }
              it { is_expected.not_to contain_class('jenkins::repo::debian') }
              it { is_expected.to contain_package('jenkins').that_requires('Yumrepo[jenkins]') }
            end
            describe 'repo => false' do
              let(:params) { { repo: false } }

              it { is_expected.to compile.with_all_deps }
              it { is_expected.not_to contain_class('jenkins::repo') }
              it { is_expected.not_to contain_class('jenkins::repo::el') }
              it { is_expected.not_to contain_class('jenkins::repo::suse') }
              it { is_expected.not_to contain_class('jenkins::repo::debian') }
            end
          when 'Suse'
            describe 'Suse' do
              it { is_expected.to compile.with_all_deps }
              it { is_expected.to contain_class('jenkins::repo::suse') }
              it { is_expected.not_to contain_class('jenkins::repo::el') }
              it { is_expected.not_to contain_class('jenkins::repo::debian') }
              it { is_expected.to contain_package('jenkins').that_requires('Zypprepo[jenkins]') }
            end
          when 'Debian'
            describe 'Debian' do
              it { is_expected.to compile.with_all_deps }
              it { is_expected.to contain_class('jenkins::repo::debian') }
              it { is_expected.not_to contain_class('jenkins::repo::suse') }
              it { is_expected.not_to contain_class('jenkins::repo::el') }
              it { is_expected.to contain_package('jenkins').that_requires('Apt::Source[jenkins]') }
            end
          end
        end
      end
    end
  end
end
