require 'spec_helper'

describe 'jenkins::windows::plugin' do
  let(:title) { 'myplug' }
  let(:facts) {{ :osfamily => 'Windows', :operatingsystem => 'windows' }}

  describe 'without version' do
    it do
      should contain_pget('myplug.hpi').with(
        :url  =>  'https://updates.jenkins-ci.org/latest/myplug.hpi',
        :user => 'jenkins',
      )
    end
    it { should contain_file('C:/Program Files (x86)/Jenkins/plugins/myplug.hpi')}
  end

  describe 'with version' do
    let(:params) { { :version => '1.2.3' } }

    it do
      should contain_pget('myplug.hpi')
    end
    it { should contain_file('C:/Program Files (x86)/Jenkins/plugins/myplug.hpi')}
  end

  describe 'with version and in middle of jenkins_plugins fact' do
    let(:params) { { :version => '1.2.3' } }
    let(:facts) { { :jenkins_plugins => 'myplug 1.2.3, fooplug 1.4.5' } }

    it { should_not contain_pget('myplug.hpi') }
    it { should_not contain_file('C:/Program Files (x86)/Jenkins/plugins/myplug.hpi')}
  end

  describe 'with version and at end of jenkins_plugins fact' do
    let(:params) { { :version => '1.2.3' } }
    let(:facts) { { :jenkins_plugins => 'fooplug 1.4.5, myplug 1.2.3' } }

    it { should_not contain_pget('myplug.hpi') }
    it { should_not contain_file('C:/Program Files (x86)/Jenkins/plugins/myplug.hpi')}
  end

  describe 'with enabled is false' do
    let(:params) { { :enabled => false } }

    it { should contain_pget('myplug.hpi') }
    it { should contain_file('C:/Program Files (x86)/Jenkins/plugins/myplug.hpi')}
    it { should contain_file('C:/Program Files (x86)/Jenkins/plugins/myplug.hpi.disabled').with({
      :ensure => 'present',
      :owner  => 'jenkins',
    })}
    it { should contain_file('C:/Program Files (x86)/Jenkins/plugins/myplug.jpi.disabled').with({
      :ensure => 'present',
      :owner  => 'jenkins',
    })}
  end

  describe 'with enabled is true' do
    let(:params) { { :enabled => true } }

    it { should contain_pget('myplug.hpi') }
    it { should contain_file('C:/Program Files (x86)/Jenkins/plugins/myplug.hpi')}
    it { should contain_file('C:/Program Files (x86)/Jenkins/plugins/myplug.hpi.disabled').with({
      :ensure => 'absent',
      :owner  => 'jenkins',
    })}
    it { should contain_file('C:/Program Files (x86)/Jenkins/plugins/myplug.jpi.disabled').with({
      :ensure => 'absent',
      :owner  => 'jenkins',
    })}
  end

  
  describe 'with a custom update center' do
    shared_examples 'execute the right fetch command' do
      it 'should retrieve the plugin' do
        expect(subject).to contain_pget('git.hpi').with({
          :source => "#{expected_url}",
        })
      end
    end

    let(:title) { 'git' }

    context 'by default' do
      context 'with a version' do
        let(:version) { '1.3.3.7' }
        let(:params) { {:version => version} }
        let(:expected_url) do
          "https://updates.jenkins-ci.org/download/plugins/#{title}/#{version}/#{title}.hpi"
        end

        include_examples 'execute the right fetch command'
      end

      context 'without a version' do
        let(:expected_url) do
          "https://updates.jenkins-ci.org/latest/#{title}.hpi"
        end

        include_examples 'execute the right fetch command'
      end
    end

    context 'with a custom update_url' do
      let(:update_url) { 'http://rspec' }

      context 'without a version' do
        let(:params) { {:update_url => update_url} }
        let(:expected_url) do
          "#{update_url}/latest/#{title}.hpi"
        end

        include_examples 'execute the right fetch command'
      end

      context 'with a version' do
        let(:version) { '1.2.3' }
        let(:params) { {:update_url => update_url, :version => version} }
        let(:expected_url) do
          "#{update_url}/download/plugins/#{title}/#{version}/#{title}.hpi"
        end

        include_examples 'execute the right fetch command'
      end
    end
  end
 
  describe 'source' do
    shared_examples 'should download from $source url' do
      it 'should download from $source url' do
         should contain_pget('myplug.hpi').with(
          :source  => 'http://e.org/myplug.hpi',
        )
      end
    end

    let(:params) {{ :source => 'http://e.org/myplug.hpi' }}

    context 'other params at defaults' do
      include_examples 'should download from $source url'
    end

    context '$update_url is set' do
      before { params[:update_url] = 'http://dne.org/' }

      include_examples 'should download from $source url'

      context 'and $version is set' do
        before { params[:version] = 42 }

        include_examples 'should download from $source url'
      end
    end

    context 'validate_string' do
      context 'string' do
        let(:params) {{ :source => 'foo' }}

        it { should raise_error }
      end

      context 'array' do
        let(:params) {{ :source => [] }}

        it 'should fail' do
          should raise_error(Puppet::Error, /is not a string/)
        end
      end
    end # validate_string
  end # source
end
