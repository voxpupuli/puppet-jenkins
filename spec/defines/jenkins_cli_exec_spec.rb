# frozen_string_literal: true

require 'spec_helper'

describe 'jenkins::cli::exec' do
  let(:title) { 'foo' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:helper_cmd) { '/bin/cat /usr/share/java/puppet_helper.groovy | /usr/bin/java -jar /usr/share/java/jenkins-cli.jar -s http://127.0.0.1:8080 groovy =' }

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
      end

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
      end

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
      end
    end
  end
end
