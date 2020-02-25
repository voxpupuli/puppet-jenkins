require 'spec_helper_acceptance'

describe 'jenkins class', order: :defined do
  PDIR = '/var/lib/jenkins/plugins'.freeze

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

  shared_examples 'has_git_plugin' do
    describe file("#{PDIR}/git.jpi") do
      it { is_expected.to be_file }
    end
    describe file("#{PDIR}/git") do
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
    pp = <<-EOS
    class {'jenkins':
      cli_remoting_free => true,
    }

    jenkins::plugin {'git-plugin':
      name    => 'git',
      version => '2.3.4',
    }
    EOS

    apply2(pp)

    it_behaves_like 'has_git_plugin'
  end

  describe 'plugin downgrade' do
    before(:all) do
      pp = <<-EOS
      class {'jenkins':
        cli_remoting_free => true,
        purge_plugins     => true,
      }

      jenkins::plugin {'git-plugin':
        name    => 'git',
        version => '2.3.4',
      }
      EOS

      apply(pp, catch_failures: true)
      apply(pp, catch_changes: true)
    end

    context 'downgrade' do
      git_version =
        it 'downgrades git version' do
          pp = <<-EOS
          package{'unzip':
            ensure => present
          }
          class {'jenkins':
            cli_remoting_free => true,
            purge_plugins     => true,
          }

          jenkins::plugin {'git-plugin':
            name    => 'git',
            version => '1.0',
          }
          EOS

          apply(pp, catch_failures: true)
          apply(pp, catch_changes: true)

          # Find the version of the installed git plugin
          git_version = shell("unzip -p #{PDIR}/git.jpi META-INF/MANIFEST.MF | sed 's/Plugin-Version: \\\(.*\\\)/\\1/;tx;d;:x'").stdout.strip
          git_version.should eq('1.0')
        end
      it_behaves_like 'has_git_plugin'
    end
  end

  describe 'plugin purging' do
    context 'true' do
      include_context 'plugin_test_files'

      it 'works with no errors' do
        pp = <<-EOS
        class {'jenkins':
          cli_remoting_free => true,
          purge_plugins     => true,
        }

        jenkins::plugin {'git-plugin':
          name    => 'git',
          version => '2.3.4',
        }
        EOS

        apply(pp, catch_failures: true)
        apply(pp, catch_changes: true)
      end

      it_behaves_like 'has_git_plugin'

      (DIRS + FILES).each do |f|
        describe file(f) do
          it { is_expected.not_to exist }
        end
      end
    end # true

    context 'false' do
      include_context 'plugin_test_files'

      it 'works with no errors' do
        pp = <<-EOS
        class {'jenkins':
          cli_remoting_free => true,
          purge_plugins     => false,
        }

        jenkins::plugin {'git-plugin':
          name    => 'git',
          version => '2.3.4',
        }
        EOS

        apply(pp, catch_failures: true)
        apply(pp, catch_changes: true)
      end

      it_behaves_like 'has_git_plugin'

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
    end # false
  end # plugin purging
end
