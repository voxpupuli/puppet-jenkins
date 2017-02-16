require 'spec_helper_acceptance'

describe 'jenkins class', :order => :defined do
  $pdir = '/var/lib/jenkins/plugins'
  let(:pdir) { $pdir }

  # files/directories to test plugin purging removal of unmanaged files
  $files = [
    "#{$pdir}/a.hpi",
    "#{$pdir}/b.jpi",
    "#{$pdir}/c.txt",
    "#{$pdir}/a/foo",
    "#{$pdir}/b/bar",
    "#{$pdir}/c/baz",
  ]
  $dirs = [
    "#{$pdir}/a",
    "#{$pdir}/b",
    "#{$pdir}/c",
  ]

  shared_examples 'has_git_plugin' do
    describe file("#{$pdir}/git.hpi") do
      it { should be_file }
    end
    describe file("#{$pdir}/git") do
      it { should be_directory }
    end
  end

  shared_context 'plugin_test_files' do
    before(:context) do
      shell("mkdir -p #{$dirs.join(' ')}")
      shell("touch #{$files.join(' ')}")
    end
    after(:context) do
      shell("rm -rf #{$dirs.join(' ')} #{$files.join(' ')}")
    end
  end

  context 'default parameters' do
    it 'should work with no errors' do
      pp = <<-EOS
      include jenkins

      jenkins::plugin {'git-plugin':
        name    => 'git',
        version => '2.3.4',
      }
      EOS

      apply2(pp)
    end

    it_behaves_like 'has_git_plugin'
  end

  describe 'plugin purging' do
    context 'true' do
      include_context 'plugin_test_files'

      it 'should work with no errors' do
        pp = <<-EOS
        class { 'jenkins': purge_plugins => true, }

        jenkins::plugin {'git-plugin':
          name    => 'git',
          version => '2.3.4',
        }
        EOS

        apply2(pp)
      end

      it_behaves_like 'has_git_plugin'

      ($dirs + $files).each do |f|
        describe file(f) do
          it { should_not exist }
        end
      end
    end # true

    context 'false' do
      include_context 'plugin_test_files'

      it 'should work with no errors' do
        pp = <<-EOS
        class { 'jenkins': purge_plugins => false, }

        jenkins::plugin {'git-plugin':
          name    => 'git',
          version => '2.3.4',
        }
        EOS

        apply2(pp)
      end

      it_behaves_like 'has_git_plugin'

      $dirs.each do |f|
        describe file(f) do
          it { should be_directory }
        end
      end

      $files.each do |f|
        describe file(f) do
          it { should be_file }
        end
      end
    end # false
  end # plugin purging
end
