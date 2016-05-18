require 'spec_helper'

describe 'jenkins::plugin' do
  let(:title) { 'myplug' }
  let(:facts) do
    {
      :osfamily                  => 'RedHat',
      :operatingsystem           => 'CentOS',
      :operatingsystemrelease    => '6.7',
      :operatingsystemmajrelease => '6',
    }
  end
  let(:pdir) { '/var/lib/jenkins/plugins' }

  describe 'without version' do
    it do
      should contain_archive("#{title}.hpi").with(
        :source  =>  'https://updates.jenkins-ci.org/latest/myplug.hpi',
        :path    => "#{pdir}/#{title}.hpi",
        :cleanup => false,
        :extract => false,
      ).that_requires("File[#{pdir}]")
        .that_notifies('Service[jenkins]')
    end
    it do
      should contain_file("#{pdir}/#{title}.hpi").with(
        :owner => 'jenkins',
        :group => 'jenkins',
        :mode  => '0644',
      ).that_requires("Archive[#{title}.hpi]")
        .that_comes_before('Service[jenkins]')
    end
  end

  describe 'with version' do
    let(:params) { { :version => '1.2.3' } }

    it do
      should contain_archive('myplug.hpi').with(
        :source  =>  'https://updates.jenkins-ci.org/download/plugins/myplug/1.2.3/myplug.hpi',
      )
    end
    it { should contain_file("#{pdir}/myplug.hpi")}
  end

  describe 'with version and in middle of jenkins_plugins fact' do
    let(:params) { { :version => '1.2.3' } }
    before { facts[:jenkins_plugins] = 'myplug 1.2.3, fooplug 1.4.5' }

    it { should_not contain_archive('myplug.hpi') }
    it { should_not contain_file("#{pdir}/myplug.hpi")}
  end

  describe 'with version and at end of jenkins_plugins fact' do
    let(:params) { { :version => '1.2.3' } }
    before { facts[:jenkins_plugins] = 'fooplug 1.4.5, myplug 1.2.3' }

    it { should_not contain_archive('myplug.hpi') }
    it { should_not contain_file("#{pdir}/myplug.hpi")}
  end

  describe 'with name and version' do
    describe 'where name & version are a substring of another plugin' do
      let(:params) { { :version => '1.2.3' } }
      before { facts[:jenkins_plugins] = 'fooplug 1.4.5, bar-myplug 1.2.3' }

      it { should contain_archive('myplug.hpi') }
      it { should contain_file('/var/lib/jenkins/plugins/myplug.hpi')}
    end

    describe 'where name & version are a substring of another plugin' do
      let(:params) { { :version => '1.2.3' } }
      before { facts[:jenkins_plugins] = 'fooplug 1.4.5, bar-myplug 1.2.3.4' }

      it { should contain_archive('myplug.hpi') }
      it { should contain_file('/var/lib/jenkins/plugins/myplug.hpi')}
    end

    describe 'where version is a substring of the already installed plugin' do
      let(:params) { { :version => '1.2.3' } }
      before { facts[:jenkins_plugins] = 'fooplug 1.4.5, myplug 1.2.3.4' }

      it { should contain_archive('myplug.hpi') }
      it { should contain_file('/var/lib/jenkins/plugins/myplug.hpi')}
    end

    describe 'and no plugins are installed (should not actually happen)' do
      let(:params) { { :version => '1.2.3' } }
      before { facts[:jenkins_plugins] = '' }

      it { should contain_archive('myplug.hpi') }
      it { should contain_file('/var/lib/jenkins/plugins/myplug.hpi')}
    end
  end # 'with name and version'

  describe 'with enabled is false' do
    let(:params) { { :enabled => false } }

    it { should contain_archive('myplug.hpi') }
    it { should contain_file("#{pdir}/myplug.hpi")}
    it do
      should contain_file("#{pdir}/myplug.hpi.disabled").with(
        :ensure => 'present',
        :owner  => 'jenkins',
        :group  => 'jenkins',
        :mode   => '0644',
      ).that_requires("Archive[#{title}.hpi]")
        .that_notifies('Service[jenkins]')
    end
  end

  describe 'with enabled is true' do
    let(:params) { { :enabled => true } }

    it { should contain_archive('myplug.hpi') }
    it { should contain_file("#{pdir}/myplug.hpi")}
    it do
      should contain_file("#{pdir}/myplug.hpi.disabled").with(
        :ensure => 'absent',
      )
    end
  end

  describe 'with proxy' do
    let(:pre_condition) do
      <<-EOS
        class { jenkins:
          proxy_host => "proxy.company.com",
          proxy_port => 8080,
        }
      EOS
    end

    it do
      should contain_archive('myplug.hpi').with(
        :proxy_server => 'http://proxy.company.com:8080',
      )
    end
  end

  describe 'with a custom update center' do
    shared_examples 'execute the right fetch command' do
      it 'should retrieve the plugin' do
        expect(subject).to contain_archive('git.hpi').with({
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
        should contain_archive('myplug.hpi').with(
          :source  => 'http://e.org/myplug.hpi',
        )
          .that_requires("File[#{pdir}]")
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
        before { params[:version] = '42' }

        include_examples 'should download from $source url'
      end
    end

    context 'validate_string' do
      context 'string' do
        let(:params) {{ :source => 'foo.hpi' }}

        it { should_not raise_error }
      end

      context 'array' do
        let(:params) {{ :source => [] }}

        it 'should fail' do
          should raise_error(Puppet::Error, /is not a string/)
        end
      end
    end # validate_string
  end # source

  context 'pinned file' do
    let(:title) { 'foo' }

    context 'default params' do
      it do
        should contain_file("#{pdir}/foo.hpi.pinned").with(
          :ensure => 'file',
          :owner  => 'jenkins',
          :group  => 'jenkins',
        )
          .that_requires('Archive[foo.hpi]')
          .that_notifies('Service[jenkins]')
      end
    end

    context 'with source param' do
      let(:params) {{ :source => 'foo.jpi' }}

      it { should contain_file("#{pdir}/foo.jpi.pinned").with_ensure('file') }
    end

    describe 'pin parameter' do
      context 'with pin => true' do
        let(:params) {{ :pin => true } }
        it { should contain_file("#{pdir}/foo.hpi.pinned").with_ensure('file') }
      end
      context 'with pin => false' do
        let(:params) {{ :pin => false } }
        it do
          should contain_file("#{pdir}/foo.hpi.pinned").without_ensure
        end
      end
      context 'with default pin param' do
        it { should contain_file("#{pdir}/foo.hpi.pinned").with_ensure('file') }
      end
    end
  end # pinned file extension name

  describe 'deprecated params' do
    [
      'plugin_dir',
      'username',
      'group',
      'create_user',
    ].each do |param|
      context param do
        pending('rspec-puppet support for testing warning()')
      end
    end
  end # deprecated params
end
