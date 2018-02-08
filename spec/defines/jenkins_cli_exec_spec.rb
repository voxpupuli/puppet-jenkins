require 'spec_helper'

describe 'jenkins::cli::exec', type: :define do
  let(:title) { 'foo' }

  let(:facts) do
    {
      osfamily: 'RedHat',
      operatingsystem: 'RedHat', # require by puppetlabs/java
      operatingsystemrelease: '6.7',
      operatingsystemmajrelease: '6'
    }
  end

  let(:helper_cmd) { '/bin/cat /usr/lib/jenkins/puppet_helper.groovy | /usr/bin/java -jar /usr/lib/jenkins/jenkins-cli.jar -s http://127.0.0.1:8080 groovy =' }

  describe 'relationships' do
    it do
      is_expected.to contain_jenkins__cli__exec('foo').
        that_requires('Class[jenkins::cli_helper]')
    end
    it do
      is_expected.to contain_jenkins__cli__exec('foo').
        that_comes_before('Anchor[jenkins::end]')
    end
  end

  describe 'title =>' do
    context 'foo' do
      # default title...

      it do
        is_expected.to contain_exec('foo').with(
          command: "#{helper_cmd} foo",
          tries: 10,
          try_sleep: 10,
          unless: nil
        )
      end
      it { is_expected.to contain_exec('foo').that_notifies('Class[jenkins::cli::reload]') }
    end

    context 'bar' do
      let(:title) { 'bar' }

      it do
        is_expected.to contain_exec('bar').with(
          command: "#{helper_cmd} bar",
          tries: 10,
          try_sleep: 10,
          unless: nil
        )
      end
      it { is_expected.to contain_exec('bar').that_notifies('Class[jenkins::cli::reload]') }
    end
  end # title =>

  describe 'command =>' do
    context 'bar' do
      let(:params) { { command: 'bar' } }

      it do
        is_expected.to contain_exec('foo').with(
          command: "#{helper_cmd} bar",
          tries: 10,
          try_sleep: 10,
          unless: nil
        )
      end
    end

    context "['bar']" do
      let(:params) { { command: %w[bar] } }

      it do
        is_expected.to contain_exec('foo').with(
          command: "#{helper_cmd} bar",
          tries: 10,
          try_sleep: 10,
          unless: nil
        )
      end
    end

    context "['bar', 'baz']" do
      let(:params) { { command: %w[bar baz] } }

      it do
        is_expected.to contain_exec('foo').with(
          command: "#{helper_cmd} bar baz",
          tries: 10,
          try_sleep: 10,
          unless: nil
        )
      end
    end
  end # command =>

  describe 'unless =>' do
    context 'bar' do
      let(:params) { { unless: 'bar' } }

      it do
        is_expected.to contain_exec('foo').with(
          command: "#{helper_cmd} foo",
          environment: ["HELPER_CMD=eval #{helper_cmd}"],
          unless: 'bar',
          tries: 10,
          try_sleep: 10
        )
      end
    end
  end # unless_cli_helper =>
end
