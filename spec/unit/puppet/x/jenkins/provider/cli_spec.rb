# frozen_string_literal: true

require 'spec_helper'
require 'unit/puppet/x/spec_jenkins_providers'

# we need to make sure retries is always loaded or random test ordering can
# cause failures when a side effect hasn't yet caused the lib to be loaded
require 'retries'
require 'puppet/x/jenkins/provider/cli'

describe Puppet::X::Jenkins::Provider::Cli do
  # rubocop:todo RSpec/LeakyConstantDeclaration
  AuthError = Puppet::X::Jenkins::Provider::Cli::AuthError # rubocop:todo Lint/ConstantDefinitionInBlock, RSpec/LeakyConstantDeclaration
  # rubocop:enable RSpec/LeakyConstantDeclaration
  # rubocop:todo RSpec/LeakyConstantDeclaration
  NetError = Puppet::X::Jenkins::Provider::Cli::NetError # rubocop:todo Lint/ConstantDefinitionInBlock, RSpec/LeakyConstantDeclaration
  # rubocop:enable RSpec/LeakyConstantDeclaration
  # rubocop:todo RSpec/LeakyConstantDeclaration
  UnknownError = Puppet::X::Jenkins::Provider::Cli::UnknownError # rubocop:todo Lint/ConstantDefinitionInBlock, RSpec/LeakyConstantDeclaration
  # rubocop:enable RSpec/LeakyConstantDeclaration

  # rubocop:todo RSpec/LeakyConstantDeclaration
  CLI_AUTH_ERRORS = [<<-EOS, <<-EOS, <<-EOS, <<-EOS].freeze # rubocop:todo Lint/ConstantDefinitionInBlock, RSpec/LeakyConstantDeclaration
  # rubocop:enable RSpec/LeakyConstantDeclaration
    anonymous is missing the Overall/Read permission
  EOS
    You must authenticate to access this Jenkins.
    Use --username/--password/--password-file parameters or login command.
  EOS
    anonymous is missing the Overall/RunScripts permission
  EOS
    anonymous is missing the Overall/Administer permission
  EOS

  # rubocop:todo Lint/MissingCopEnableDirective
  # rubocop:todo RSpec/LeakyConstantDeclaration
  # rubocop:enable Lint/MissingCopEnableDirective
  CLI_NET_ERRORS = [<<-EOS, <<-EOS].freeze # rubocop:todo Lint/ConstantDefinitionInBlock, RSpec/LeakyConstantDeclaration
  # rubocop:enable RSpec/LeakyConstantDeclaration
    SEVERE: I/O error in channel CLI connection
  EOS
    java.net.SocketException: Connection reset
  EOS

  shared_context 'facts' do
    before do
      Facter.add(:jenkins_cli_jar) { setcode { 'fact.jar' } }
      Facter.add(:jenkins_url) { setcode { 'http://localhost:11' } }
      Facter.add(:jenkins_ssh_private_key) { setcode { 'fact.id_rsa' } }
      Facter.add(:jenkins_puppet_helper) { setcode { 'fact.groovy' } }
      Facter.add(:jenkins_cli_username) { setcode { 'myuser' } }
      Facter.add(:jenkins_cli_tries) { setcode { 22 } }
      Facter.add(:jenkins_cli_try_sleep) { setcode { 33 } }
    end
  end

  before do
    Facter.clear
    # clear class level state
    # rubocop:todo Style/ClassVars
    described_class.class_variable_set(:@@cli_auth_required, false) if described_class.class_variable_defined?(:@@cli_auth_required)
    # rubocop:enable Style/ClassVars
    allow(described_class).to receive(:command).with(:java).and_return('java')
  end

  describe '::suitable?' do
    it { expect(described_class.suitable?).to eq true }
  end

  include_examples 'confines to cli dependencies'

  describe '::sname' do
    it 'returns a short class name' do
      expect(described_class.sname).to eq 'Jenkins::Provider::Cli'
    end
  end

  describe '::instances' do
    it 'is not implemented' do
      expect { described_class.instances }.to raise_error(Puppet::DevError)
    end
  end

  describe '::prefetch' do
    let(:catalog) { Puppet::Resource::Catalog.new }

    it 'associates a provider with an instance' do
      resource = Puppet::Type.type(:notify).new(name: 'test')
      catalog.add_resource resource

      provider = described_class.new(name: 'test')

      allow(described_class).to receive(:instances).
        with(catalog).and_return([provider])

      described_class.prefetch(resource.name => resource)

      expect(resource.provider).to eq provider
      expect(described_class).to have_received(:instances).
        with(catalog)
    end

    it 'does not break an existing resource/provider association' do
      resource = Puppet::Type.type(:notify).new(name: 'test')
      catalog.add_resource resource

      provider = described_class.new(name: 'test')
      resource.provider = provider

      allow(described_class).to receive(:instances).
        with(catalog).and_return([provider])

      described_class.prefetch(resource.name => resource)

      expect(resource.provider).to eq provider
      expect(described_class).to have_received(:instances).
        with(catalog)
    end
  end

  describe '#create' do
    context ':ensure' do
      it do
        provider = described_class.new

        expect(provider.instance_variable_get(:@property_hash)[:ensure]).to eq nil
        provider.create
        expect(provider.instance_variable_get(:@property_hash)[:ensure]).to eq :present
      end
    end
  end

  describe '#exists?' do
    context 'when :ensure is unset' do
      it do
        provider = described_class.new
        expect(provider.exists?).to eq false
      end
    end

    context 'when :ensure is :absent' do
      it 'returns true' do
        provider = described_class.new(ensure: :absent)
        expect(provider.exists?).to eq false
      end
    end

    context 'when :ensure is :present' do
      it 'returns true' do
        provider = described_class.new(ensure: :present)
        expect(provider.exists?).to eq true
      end
    end
  end

  describe '#destroy' do
    context ':ensure' do
      it do
        provider = described_class.new

        expect(provider.instance_variable_get(:@property_hash)[:ensure]).to eq nil
        provider.destroy
        expect(provider.instance_variable_get(:@property_hash)[:ensure]).to eq :absent
      end
    end
  end

  describe '#flush' do
    it 'clears @property_hash' do
      provider = described_class.new
      provider.create
      provider.flush

      expect(provider.instance_variable_get(:@property_hash)).to eq({})
    end
  end

  describe '#cli' do
    let(:provider) { described_class.new }

    it 'is an instance method' do
      expect(provider).to respond_to(:cli)
    end

    it 'has the same method signature as ::cli' do
      expect(described_class.new).to respond_to(:cli).with(2).arguments
    end

    it 'wraps ::cli class method' do
      allow(described_class).to receive(:cli)
      provider.cli('foo', {})
      expect(described_class).to have_received(:cli).with('foo', {})
    end

    it 'extracts the catalog from the resource' do
      resource = Puppet::Type.type(:notify).new(name: 'test')
      catalog = Puppet::Resource::Catalog.new
      resource.provider = provider
      catalog.add_resource resource

      allow(described_class).to receive(:cli)

      provider.cli('foo', {})

      expect(described_class).to have_received(:cli).with(
        'foo', catalog: catalog
      )
    end
  end

  describe '#clihelper' do
    let(:provider) { described_class.new }

    it 'is an instance method' do
      expect(provider).to respond_to(:clihelper)
    end

    it 'has the same method signature as ::clihelper' do
      expect(described_class.new).to respond_to(:clihelper).with(2).arguments
    end

    it 'wraps ::clihelper class method' do
      allow(described_class).to receive(:clihelper)
      provider.clihelper('foo', {})
      expect(described_class).to have_received(:clihelper).with('foo', {})
    end

    it 'extracts the catalog from the resource' do
      resource = Puppet::Type.type(:notify).new(name: 'test')
      catalog = Puppet::Resource::Catalog.new
      resource.provider = provider
      catalog.add_resource resource

      allow(described_class).to receive(:clihelper)

      provider.clihelper('foo', {})

      expect(described_class).to have_received(:clihelper).with(
        'foo', catalog: catalog
      )
    end
  end

  describe '::clihelper' do
    shared_examples 'uses default values' do
      it 'uses default values' do
        allow(described_class).to receive(:cli)

        described_class.clihelper('foo')

        expect(described_class).to have_received(:cli).with(
          ['groovy', '=', 'foo'],
          { tmpfile_as_param: true },
          ['/bin/cat', '/usr/lib/jenkins/puppet_helper.groovy', '|']
        )
      end
    end

    shared_examples 'uses fact values' do
      it 'uses fact values' do
        allow(described_class).to receive(:cli)

        described_class.clihelper('foo')

        expect(described_class).to have_received(:cli).with(
          ['groovy', '=', 'foo'],
          { tmpfile_as_param: true },
          ['/bin/cat', 'fact.groovy', '|']
        )
      end
    end

    shared_examples 'uses catalog values' do
      it 'uses catalog values' do
        allow(described_class).to receive(:cli)

        described_class.clihelper('foo', catalog: catalog)

        expect(described_class).to have_received(:cli).with(
          ['groovy', '=', 'foo'],
          { catalog: catalog, tmpfile_as_param: true },
          ['/bin/cat', 'cat.groovy', '|']
        )
      end
    end

    it 'is a class method' do
      expect(described_class).to respond_to(:clihelper)
    end

    it 'wraps ::cli class method' do
      allow(described_class).to receive(:cli)
      described_class.clihelper('foo')
      expect(described_class).to have_received(:cli)
    end

    context 'no catalog' do
      context 'no facts' do
        include_examples 'uses default values'
      end

      context 'with facts' do
        include_context 'facts'

        include_examples 'uses fact values'
      end
    end

    context 'with catalog' do
      let(:catalog) { Puppet::Resource::Catalog.new }

      context 'no jenkins::cli::config class' do
        context 'no facts' do
          include_examples 'uses default values'
        end

        context 'with facts' do
          include_context 'facts'

          include_examples 'uses fact values'
        end
      end

      context 'with jenkins::cli::config class' do
        before do
          jenkins = Puppet::Type.type(:component).new(
            name: 'jenkins::cli::config',
            puppet_helper: 'cat.groovy'
          )

          catalog.add_resource jenkins
        end

        context 'no facts' do
          include_examples 'uses catalog values'
        end

        context 'with facts' do
          include_context 'facts'

          include_examples 'uses catalog values'
        end
      end
    end
  end

  describe '::cli' do
    before do
      # disable with_retries sleeping to [vastly] speed up testing
      #
      # we are relying the side effects of ::suitable? from a previous example
      Retries.sleep_enabled = false
    end

    shared_examples 'uses default values' do
      it 'uses default values' do
        allow(described_class.superclass).to receive(:execute)

        described_class.cli('foo')

        expect(described_class.superclass).to have_received(:execute).with(
          'java -jar /usr/lib/jenkins/jenkins-cli.jar -s http://localhost:8080 -logger WARNING foo',
          failonfail: true, combine: true
        )
      end
    end

    shared_examples 'uses fact values' do
      it 'uses fact values' do
        allow(described_class.superclass).to receive(:execute)

        described_class.cli('foo')

        expect(described_class.superclass).to have_received(:execute).with(
          'java -jar fact.jar -s http://localhost:11 -logger WARNING foo',
          failonfail: true, combine: true
        )
      end
    end

    shared_examples 'uses catalog values' do
      it 'uses catalog values' do
        allow(described_class.superclass).to receive(:execute)

        described_class.cli('foo', catalog: catalog)

        expect(described_class.superclass).to have_received(:execute).with(
          'java -jar cat.jar -s http://localhost:111 -logger WARNING foo',
          failonfail: true, combine: true
        )
      end
    end

    it 'is a class method' do
      expect(described_class).to respond_to(:cli)
    end

    it 'wraps the superclasses ::execute method' do
      allow(described_class.superclass).to receive(:execute)
      described_class.cli('foo')
      expect(described_class.superclass).to have_received(:execute)
    end

    context 'no catalog' do
      context 'no facts' do
        include_examples 'uses default values'
      end

      context 'with facts' do
        include_context 'facts'

        include_examples 'uses fact values'
      end
    end

    context 'with catalog' do
      let(:catalog) { Puppet::Resource::Catalog.new }

      context 'no jenkins::cli::config class' do
        context 'no facts' do
          include_examples 'uses default values'
        end

        context 'with facts' do
          include_context 'facts'

          include_examples 'uses fact values'
        end
      end

      context 'with jenkins::cli::config class' do
        before do
          jenkins = Puppet::Type.type(:component).new(
            name: 'jenkins::cli::config',
            cli_jar: 'cat.jar',
            url: 'http://localhost:111',
            ssh_private_key: 'cat.id_rsa',
            cli_username: 'myuser',
            cli_tries: 222,
            cli_try_sleep: 333
          )

          catalog.add_resource jenkins
        end

        context 'no facts' do
          include_examples 'uses catalog values'
        end

        context 'with facts' do
          include_context 'facts'

          include_examples 'uses catalog values'
        end
      end
    end

    context 'auth failure' do
      context 'without ssh_private_key' do
        CLI_AUTH_ERRORS.each do |error|
          it 'does not retry cli on AuthError exception' do
            allow(described_class.superclass).to receive(:execute).with(
              'java -jar /usr/lib/jenkins/jenkins-cli.jar -s http://localhost:8080 -logger WARNING foo',
              failonfail: true, combine: true
            ).and_raise(AuthError, error)

            expect { described_class.cli('foo') }.
              to raise_error(AuthError)
          end
        end
      end
      # without ssh_private_key

      context 'with ssh_private_key' do
        let(:catalog) { Puppet::Resource::Catalog.new }

        before do
          jenkins = Puppet::Type.type(:component).new(
            name: 'jenkins::cli::config',
            cli_username: 'myuser',
            ssh_private_key: 'cat.id_rsa'
          )
          catalog.add_resource jenkins
        end

        it 'tries cli without auth first' do
          allow(described_class.superclass).to receive(:execute)

          described_class.cli('foo', catalog: catalog)

          expect(described_class.superclass).to have_received(:execute).with(
            'java -jar /usr/lib/jenkins/jenkins-cli.jar -s http://localhost:8080 -logger WARNING foo',
            failonfail: true, combine: true
          )
        end

        CLI_AUTH_ERRORS.each do |error|
          it 'retries cli on AuthError exception' do
            allow(described_class.superclass).to receive(:execute).with(
              'java -jar /usr/lib/jenkins/jenkins-cli.jar -s http://localhost:8080 -logger WARNING foo',
              failonfail: true, combine: true
            ).and_raise(AuthError, error)

            allow(described_class.superclass).to receive(:execute).with(
              'java -jar /usr/lib/jenkins/jenkins-cli.jar -s http://localhost:8080 -logger WARNING -i cat.id_rsa -ssh -user myuser foo',
              failonfail: true, combine: true
            )

            described_class.cli('foo', catalog: catalog)
            # and it should remember that auth is required
            described_class.cli('foo', catalog: catalog)

            expect(described_class.superclass).to have_received(:execute).with(
              'java -jar /usr/lib/jenkins/jenkins-cli.jar -s http://localhost:8080 -logger WARNING foo',
              failonfail: true, combine: true
            ).once

            expect(described_class.superclass).to have_received(:execute).with(
              'java -jar /usr/lib/jenkins/jenkins-cli.jar -s http://localhost:8080 -logger WARNING -i cat.id_rsa -ssh -user myuser foo',
              failonfail: true, combine: true
            ).twice
          end
        end
      end
    end

    context 'network failure' do
      context 'without ssh_private_key' do
        CLI_NET_ERRORS.each do |error|
          it 'does not retry cli on AuthError exception' do
            allow(described_class.superclass).to receive(:execute).with(
              'java -jar /usr/lib/jenkins/jenkins-cli.jar -s http://localhost:8080 -logger WARNING foo',
              failonfail: true, combine: true
            ).exactly(30).times.and_raise(NetError, error)

            expect { described_class.cli('foo') }.
              to raise_error(NetError)
          end
        end
      end
      # without ssh_private_key
    end

    context 'when UnknownError exception' do
      let(:catalog) { Puppet::Resource::Catalog.new }

      context 'retry n times' do
        it 'by default' do
          jenkins = Puppet::Type.type(:component).new(
            name: 'jenkins::cli::config'
          )
          catalog.add_resource jenkins

          allow(described_class.superclass).to receive(:execute).with(
            'java -jar /usr/lib/jenkins/jenkins-cli.jar -s http://localhost:8080 -logger WARNING foo',
            failonfail: true, combine: true
          ).exactly(30).times.and_raise(UnknownError, 'foo')

          expect { described_class.cli('foo', catalog: catalog) }.
            to raise_error(UnknownError, 'foo')
        end

        it 'from catalog value' do
          jenkins = Puppet::Type.type(:component).new(
            name: 'jenkins::cli::config',
            cli_tries: 2
          )
          catalog.add_resource jenkins

          allow(described_class.superclass).to receive(:execute).with(
            'java -jar /usr/lib/jenkins/jenkins-cli.jar -s http://localhost:8080 -logger WARNING foo',
            failonfail: true, combine: true
          ).twice.and_raise(UnknownError, 'foo')

          expect { described_class.cli('foo', catalog: catalog) }.
            to raise_error(UnknownError, 'foo')
        end

        it 'from fact' do
          Facter.add(:jenkins_cli_tries) { setcode { 3 } }

          jenkins = Puppet::Type.type(:component).new(
            name: 'jenkins::cli::config'
          )
          catalog.add_resource jenkins

          allow(described_class.superclass).to receive(:execute).with(
            'java -jar /usr/lib/jenkins/jenkins-cli.jar -s http://localhost:8080 -logger WARNING foo',
            failonfail: true, combine: true
          ).exactly(3).times.and_raise(UnknownError, 'foo')

          expect { described_class.cli('foo', catalog: catalog) }.
            to raise_error(UnknownError, 'foo')
        end

        it 'from catalog overriding fact' do
          Facter.add(:jenkins_cli_tries) { setcode { 3 } }

          jenkins = Puppet::Type.type(:component).new(
            name: 'jenkins::cli::config',
            cli_tries: 2
          )
          catalog.add_resource jenkins

          allow(described_class.superclass).to receive(:execute).with(
            'java -jar /usr/lib/jenkins/jenkins-cli.jar -s http://localhost:8080 -logger WARNING foo',
            failonfail: true, combine: true
          ).twice.and_raise(UnknownError, 'foo')

          expect { described_class.cli('foo', catalog: catalog) }.
            to raise_error(UnknownError, 'foo')
        end
      end

      context 'waiting up to n seconds' do
        # this isn't behavioral testing because we don't want to either wait
        # for the wallclock delay timeout or attempt to accurate time examples
        it 'by default' do
          jenkins = Puppet::Type.type(:component).new(
            name: 'jenkins::cli::config'
          )
          catalog.add_resource jenkins

          allow(described_class).to receive(:with_retries)

          described_class.cli('foo', catalog: catalog)

          expect(described_class).to have_received(:with_retries).with(hash_including(max_sleep_seconds: 2))
        end

        it 'from catalog value' do
          jenkins = Puppet::Type.type(:component).new(
            name: 'jenkins::cli::config',
            cli_try_sleep: 3
          )
          catalog.add_resource jenkins

          allow(described_class).to receive(:with_retries)

          described_class.cli('foo', catalog: catalog)

          expect(described_class).to have_received(:with_retries).with(hash_including(max_sleep_seconds: 3))
        end

        it 'from fact' do
          Facter.add(:jenkins_cli_try_sleep) { setcode { 4 } }

          jenkins = Puppet::Type.type(:component).new(
            name: 'jenkins::cli::config'
          )
          catalog.add_resource jenkins

          allow(described_class).to receive(:with_retries)

          described_class.cli('foo', catalog: catalog)

          expect(described_class).to have_received(:with_retries).with(hash_including(max_sleep_seconds: 4))
        end

        it 'from catalog overriding fact' do
          Facter.add(:jenkins_cli_try_sleep) { setcode { 4 } }

          jenkins = Puppet::Type.type(:component).new(
            name: 'jenkins::cli::config',
            cli_try_sleep: 3
          )
          catalog.add_resource jenkins

          allow(described_class).to receive(:with_retries)

          described_class.cli('foo', catalog: catalog)

          expect(described_class).to have_received(:with_retries).with(hash_including(max_sleep_seconds: 3))
        end
      end
    end

    context 'options with :stdinjson' do
      RSpec::Matchers.define :a_json_doc do |x|
        match { |actual| JSON.parse(actual) == x }
      end

      let(:realm_oauth_json) do
        <<-EOS
          {
              "setSecurityRealm": {
                  "org.jenkinsci.plugins.GithubSecurityRealm": [
                      "https://github.com",
                      "https://api.github.com",
                      "42",
                      "43",
                      "read:org"
                  ]
              }
          }
        EOS
      end
      let(:realm_oauth) { JSON.parse(realm_oauth_json) }

      it 'generates a temp file with json output' do
        tmp = instance_double('Template')

        allow(Tempfile).to receive(:open).and_return(tmp)
        allow(tmp).to receive(:write).with(a_json_doc(realm_oauth))
        allow(tmp).to receive(:flush)
        allow(tmp).to receive(:close)
        allow(tmp).to receive(:unlink)
        allow(tmp).to receive(:path).and_return('/dne.tmp')

        allow(described_class.superclass).to receive(:execute)

        described_class.cli('foo', stdinjson: realm_oauth)

        expect(described_class.superclass).to have_received(:execute).with(
          'java -jar /usr/lib/jenkins/jenkins-cli.jar -s http://localhost:8080 -logger WARNING foo',
          failonfail: true,
          combine: true,
          stdinfile: '/dne.tmp'
        )
      end
    end

    context 'options with :stdin' do
      it 'generates a temp file with stdin string' do
        tmp = instance_double('Template')

        allow(Tempfile).to receive(:open).and_return(tmp)
        allow(tmp).to receive(:write).with('bar')
        allow(tmp).to receive(:flush)
        allow(tmp).to receive(:close)
        allow(tmp).to receive(:unlink)
        allow(tmp).to receive(:path).and_return('/dne.tmp')

        allow(described_class.superclass).to receive(:execute)

        described_class.cli('foo', stdin: 'bar')

        expect(described_class.superclass).to have_received(:execute).with(
          'java -jar /usr/lib/jenkins/jenkins-cli.jar -s http://localhost:8080 -logger WARNING foo',
          failonfail: true,
          combine: true,
          stdinfile: '/dne.tmp'
        )
      end
    end
  end
end
