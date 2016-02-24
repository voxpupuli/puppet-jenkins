require 'spec_helper'

describe 'jenkins::cli::exec', :type => :define do
  let(:title) { 'foo' }

  let(:facts) do
    {
      :osfamily                  => 'RedHat',
      :operatingsystem           => 'RedHat', # require by puppetlabs/java
      :operatingsystemrelease    => '6.7',
      :operatingsystemmajrelease => '6',
    }
  end

  let(:helper_cmd) { '/usr/bin/java -jar /usr/lib/jenkins/jenkins-cli.jar -s http://127.0.0.1:8080 groovy /usr/lib/jenkins/puppet_helper.groovy' }

  describe 'relationships' do
    it do
      should contain_jenkins__cli__exec('foo').
        that_requires('Class[jenkins::cli_helper]')
    end
    it do
      should contain_jenkins__cli__exec('foo').
        that_comes_before('Anchor[jenkins::end]')
    end
  end

  describe 'title =>' do
    context 'foo' do
      # default title...

      it do
        should contain_exec('foo').with(
          :command   => "#{helper_cmd} foo",
          :tries     => 10,
          :try_sleep => 10,
          :unless    => nil,
        )
      end
      it { should contain_exec('foo').that_notifies('Class[jenkins::cli::reload]') }
    end

    context 'bar' do
      let(:title) { 'bar' }

      it do
        should contain_exec('bar').with(
          :command   => "#{helper_cmd} bar",
          :tries     => 10,
          :try_sleep => 10,
          :unless    => nil,
        )
      end
      it { should contain_exec('bar').that_notifies('Class[jenkins::cli::reload]') }
    end
  end # title =>

  describe 'command =>' do
    context 'bar' do
      let(:params) {{ :command => 'bar' }}

      it do
        should contain_exec('foo').with(
          :command   => "#{helper_cmd} bar",
          :tries     => 10,
          :try_sleep => 10,
          :unless    => nil,
        )
      end
    end

    context "['bar']" do
      let(:params) {{ :command => %w{ bar } }}

      it do
        should contain_exec('foo').with(
          :command   => "#{helper_cmd} bar",
          :tries     => 10,
          :try_sleep => 10,
          :unless    => nil,
        )
      end
    end

    context "['bar', 'baz']" do
      let(:params) {{ :command => %w{bar baz} }}

      it do
        should contain_exec('foo').with(
          :command   => "#{helper_cmd} bar baz",
          :tries     => 10,
          :try_sleep => 10,
          :unless    => nil,
        )
      end
    end

    context "['bar', undef, 'baz']" do
      let(:params) {{ :command => ['bar', Undef.new, 'baz'] }}

      it 'should remove the undef' do
        should contain_exec('foo').with(
          :command   => "#{helper_cmd} bar baz",
          :tries     => 10,
          :try_sleep => 10,
          :unless    => nil,
        )
      end
    end

    context '{}' do
      let(:params) {{ :command => {} }}

      it 'should fail' do
        should raise_error(Puppet::Error, /is not a string or an Array./)
      end
    end
  end # command =>

  describe 'unless =>' do
    context 'bar' do
      let(:params) {{ :unless => 'bar' }}

      it do
        should contain_exec('foo').with(
          :command     => "#{helper_cmd} foo",
          :environment => [ "HELPER_CMD=#{helper_cmd}" ],
          :unless      => 'bar',
          :tries       => 10,
          :try_sleep   => 10,
        )
      end
    end

    context '{}' do
      let(:params) {{ :unless => {} }}

      it 'should fail' do
        should raise_error(Puppet::Error, /is not a string./)
      end
    end
  end # unless_cli_helper =>
end
