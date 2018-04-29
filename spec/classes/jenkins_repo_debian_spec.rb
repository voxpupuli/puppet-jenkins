require 'spec_helper'

describe 'jenkins', type: :class do
  on_supported_os.each do |os, facts|

    next unless facts[:os]['family'] == 'Debian'

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


      context 'repo::debian' do
        shared_examples 'an apt catalog' do
          it { is_expected.to contain_class('apt') }
          it { is_expected.to contain_apt__source('jenkins').that_notifies('Exec[apt_update]') }
        end

        describe 'default' do
          it_behaves_like 'an apt catalog'
          it { is_expected.to contain_apt__source('jenkins').with_location('https://pkg.jenkins.io/debian-stable') }
        end

        describe 'lts = true' do
          let(:params) { { lts: true } }

          it_behaves_like 'an apt catalog'
          it { is_expected.to contain_apt__source('jenkins').with_location('https://pkg.jenkins.io/debian-stable') }
        end

        describe 'lts = false' do
          let(:params) { { lts: false } }

          it_behaves_like 'an apt catalog'
          it { is_expected.to contain_apt__source('jenkins').with_location('https://pkg.jenkins.io/debian') }
        end
      end
    end
  end
end
