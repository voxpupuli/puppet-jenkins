# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'jenkins class', order: :defined do
  PDIR = '/var/lib/jenkins/plugins'

  # files/directories to test plugin purging removal of unmanaged files
  FILES = [
    "#{PDIR}/a.hpi",
    "#{PDIR}/b.jpi",
    "#{PDIR}/c.txt",
    "#{PDIR}/a/foo",
    "#{PDIR}/b/bar",
    "#{PDIR}/c/baz"
  ].freeze
  DIRS = [
    "#{PDIR}/a",
    "#{PDIR}/b",
    "#{PDIR}/c"
  ].freeze

  shared_examples 'has_plugin' do |plugin|
    describe file("#{PDIR}/#{plugin}.hpi") do
      it { is_expected.to be_file }
    end

    describe file("#{PDIR}/#{plugin}") do
      it { is_expected.to be_directory }
    end
  end

  shared_context 'plugin_test_files' do
    before(:context) do
      shell("mkdir -p #{DIRS.join(' ')}")
      shell("touch #{FILES.join(' ')}")
    end

    after(:context) do
      shell("rm -rf #{DIRS.join(' ')} #{FILES.join(' ')}")
    end
  end

  context 'default parameters' do
    include_examples 'an idempotent resource' do
      let(:manifest) do
        <<~PUPPET
          include jenkins
          jenkins::plugin {'git-plugin':
            name    => 'git',
            version => '2.3.4',
          }
        PUPPET
      end
    end

    it_behaves_like 'has_plugin', 'git'
  end

  describe 'plugin downgrade' do
    describe 'jquery3-api plugin' do
      describe 'installs version 3.6.0-r3' do
        include_examples 'an idempotent resource' do
          let(:manifest) do
            <<~PUPPET
              class {'jenkins':
                purge_plugins => true,
              }

              # actual plugin
              jenkins::plugin { 'jquery3-api':
                version => '3.6.0-4',
              }
            PUPPET
          end
        end
      end

      describe 'downgrades to 3.6.0-3' do
        include_examples 'an idempotent resource' do
          let(:manifest) do
            <<~PUPPET
              package{'unzip':
                ensure => present
              }
              class {'jenkins':
                purge_plugins => true,
              }

              # actual plugin
              jenkins::plugin { 'jquery3-api':
                version => '3.6.0-3',
              }
            PUPPET
          end
        end
      end

      describe command("unzip -p #{PDIR}/jquery3-api.hpi META-INF/MANIFEST.MF | sed 's/Plugin-Version: \\(.*\\)/\\1/;tx;d;:x'") do
        its(:stdout) { is_expected.to eq("3.6.0-3\n") }
      end

      it_behaves_like 'has_plugin', 'jquery3-api'
    end
  end

  describe 'plugin purging' do
    context 'true' do
      include_context 'plugin_test_files'

      it 'works with no errors' do
        pp = <<-EOS
        class {'jenkins':
          purge_plugins => true,
        }

        # Actual plugin
        jenkins::plugin { 'jquery3-api':
          version => '3.6.0-4',
        }
        EOS

        apply(pp, catch_failures: true)
        apply(pp, catch_changes: true)
      end

      it_behaves_like 'has_plugin', 'jquery3-api'

      (DIRS + FILES).each do |f|
        describe file(f) do
          it { is_expected.not_to exist }
        end
      end
    end

    context 'false' do
      include_context 'plugin_test_files'

      it 'works with no errors' do
        pp = <<-EOS
        class {'jenkins':
          purge_plugins => false,
        }

        # Actual plugin
        jenkins::plugin { 'jquery3-api':
          version => '3.6.0-4',
        }
        EOS

        apply(pp, catch_failures: true)
        apply(pp, catch_changes: true)
      end

      it_behaves_like 'has_plugin', 'jquery3-api'

      DIRS.each do |f|
        describe file(f) do
          it { is_expected.to be_directory }
        end
      end

      FILES.each do |f|
        describe file(f) do
          it { is_expected.to be_file }
        end
      end
    end
  end
end
