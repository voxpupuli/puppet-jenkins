# frozen_string_literal: true

require 'spec_helper'

shared_examples 'generic namevar' do |name|
  it { expect(described_class.attrtype(name)).to eq :param }

  it 'is the namevar' do
    expect(described_class.key_attributes).to eq [name]
  end
end

shared_examples 'generic ensurable' do |*allowed|
  allowed ||= %i[present absent]

  context 'attrtype' do
    it { expect(described_class.attrtype(:ensure)).to eq :property }
  end

  context 'class' do
    it do
      expect(described_class.propertybyname(:ensure).ancestors).
        to include(Puppet::Property::Ensure)
    end
  end

  it 'has no default value' do
    user = described_class.new(name: 'nobody')
    expect(user.should(:ensure)).to be_nil
  end

  allowed.each do |value|
    it "supports #{value} as a value to :ensure" do
      expect { described_class.new(name: 'nobody', ensure: value) }.not_to raise_error
    end
  end

  it 'rejects unknown values' do
    expect { described_class.new(name: 'nobody', ensure: :foo) }.to raise_error(Puppet::Error)
  end
end

shared_examples 'validated property' do |param, default, allowed|
  context 'attrtype' do
    it { expect(described_class.attrtype(param)).to eq :property }
  end

  allowed.each do |value|
    it "supports #{value} as a value" do
      expect { described_class.new(:name => 'nobody', param => value) }.
        not_to raise_error
    end
  end

  if default.nil?
    it 'has no default value' do
      resource = described_class.new(name: 'nobody')
      expect(resource.should(param)).to be_nil
    end
  else
    it "defaults to #{default}" do
      resource = described_class.new(name: 'nobody')
      expect(resource.should(param)).to eq default
    end
  end

  it 'rejects unknown values' do
    expect { described_class.new(:name => 'nobody', param => :foo) }.
      to raise_error(Puppet::Error)
  end
end

shared_examples 'boolean parameter' do |param, _default|
  it 'does not allow non-boolean values' do
    expect do
      described_class.new(:name => 'foo', param => 'unknown')
    end.to raise_error Puppet::ResourceError, %r{Valid values are true, false}
  end
end

shared_examples 'boolean property' do |param, default|
  it 'does not allow non-boolean values' do
    expect do
      described_class.new(:name => 'foo', param => 'unknown')
    end.to raise_error Puppet::ResourceError, %r{expected a boolean value}
  end

  it_behaves_like 'validated property', param, default, [true, false]
end

shared_examples 'array_matching property' do |_param|
  context 'attrtype' do
    it { expect(described_class.attrtype(:arguments)).to eq :property }
  end

  context 'array_matching' do
    it do
      expect(described_class.attrclass(:arguments).array_matching).to eq :all
    end
  end

  it 'supports an array of mixed types' do
    value = [true, 'foo']
    resource = described_class.new(name: 'test', arguments: value)
    expect(resource[:arguments]).to eq value
  end
end

shared_examples 'autorequires cli resources' do
  before { Facter.clear }

  it 'autorequires service' do
    service_resource = Puppet::Type.type(:service).new(
      name: 'jenkins'
    )
    resource = described_class.new(
      name: 'test'
    )

    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource service_resource
    catalog.add_resource resource
    req = resource.autorequire

    expect(req.size).to eq 1
    expect(req[0].source).to eq service_resource
    expect(req[0].target).to eq resource
  end

  it 'autorequires ssh_private_key file from catalog' do
    ssh_resource = Puppet::Type.type(:file).new(
      path: '/dne/id_rsa'
    )
    resource = described_class.new(
      name: 'test'
    )
    jenkins = Puppet::Type.type(:component).new(
      name: 'jenkins::cli::config',
      ssh_private_key: '/dne/id_rsa'
    )

    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource ssh_resource
    catalog.add_resource resource
    catalog.add_resource jenkins
    req = resource.autorequire

    expect(req.size).to eq 1
    expect(req[0].source).to eq ssh_resource
    expect(req[0].target).to eq resource
  end

  it 'autorequires ssh_private_key file from fact' do
    ssh_resource = Puppet::Type.type(:file).new(
      path: '/dne/id_rsa'
    )
    resource = described_class.new(
      name: 'test'
    )
    Facter.add(:jenkins_ssh_private_key) { setcode { '/dne/id_rsa' } }

    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource ssh_resource
    catalog.add_resource resource
    req = resource.autorequire

    expect(req.size).to eq 1
    expect(req[0].source).to eq ssh_resource
    expect(req[0].target).to eq resource
  end

  it 'autorequires ssh_private_key file from catalog instead of fact' do
    ssh_resource = Puppet::Type.type(:file).new(
      path: '/dne/catalog'
    )
    resource = described_class.new(
      name: 'test'
    )
    jenkins = Puppet::Type.type(:component).new(
      name: 'jenkins::cli::config',
      ssh_private_key: '/dne/catalog'
    )
    Facter.add(:jenkins_ssh_private_key) { setcode { '/dne/fact' } }

    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource ssh_resource
    catalog.add_resource resource
    catalog.add_resource jenkins
    req = resource.autorequire

    expect(req.size).to eq 1
    expect(req[0].source).to eq ssh_resource
    expect(req[0].target).to eq resource
  end

  it 'autorequires puppet_helper file from catalog' do
    helper_resource = Puppet::Type.type(:file).new(
      path: '/dne/foo.groovy'
    )
    resource = described_class.new(
      name: 'test'
    )
    jenkins = Puppet::Type.type(:component).new(
      name: 'jenkins::cli::config',
      puppet_helper: '/dne/foo.groovy'
    )

    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource helper_resource
    catalog.add_resource resource
    catalog.add_resource jenkins
    req = resource.autorequire

    expect(req.size).to eq 1
    expect(req[0].source).to eq helper_resource
    expect(req[0].target).to eq resource
  end

  it 'autorequires puppet_helper file from fact' do
    helper_resource = Puppet::Type.type(:file).new(
      path: '/dne/foo.groovy'
    )
    resource = described_class.new(
      name: 'test'
    )
    Facter.add(:jenkins_puppet_helper) { setcode { '/dne/foo.groovy' } }

    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource helper_resource
    catalog.add_resource resource
    req = resource.autorequire

    expect(req.size).to eq 1
    expect(req[0].source).to eq helper_resource
    expect(req[0].target).to eq resource
  end

  it 'autorequires puppet_helper file from catalog instead of fact' do
    helper_resource = Puppet::Type.type(:file).new(
      path: '/dne/catalog'
    )
    resource = described_class.new(
      name: 'test'
    )
    jenkins = Puppet::Type.type(:component).new(
      name: 'jenkins::cli::config',
      puppet_helper: '/dne/catalog'
    )
    Facter.add(:jenkins_puppet_helper) { setcode { '/dne/fact' } }

    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource helper_resource
    catalog.add_resource resource
    catalog.add_resource jenkins
    req = resource.autorequire

    expect(req.size).to eq 1
    expect(req[0].source).to eq helper_resource
    expect(req[0].target).to eq resource
  end

  it 'autorequires both ssh_private_key key and puppet_helper from catalog' do
    ssh_resource = Puppet::Type.type(:file).new(
      path: '/dne/id_rsa'
    )
    helper_resource = Puppet::Type.type(:file).new(
      path: '/dne/foo.groovy'
    )
    resource = described_class.new(
      name: 'test'
    )
    jenkins = Puppet::Type.type(:component).new(
      name: 'jenkins::cli::config',
      ssh_private_key: '/dne/id_rsa',
      puppet_helper: '/dne/foo.groovy'
    )

    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource ssh_resource
    catalog.add_resource helper_resource
    catalog.add_resource resource
    catalog.add_resource jenkins
    req = resource.autorequire

    expect(req.size).to eq 2
    expect(req[0].source).to eq ssh_resource
    expect(req[0].target).to eq resource

    expect(req[1].source).to eq helper_resource
    expect(req[1].target).to eq resource
  end

  it 'autorequires cli_jar file from catalog' do
    helper_resource = Puppet::Type.type(:file).new(
      path: '/dne/catalog'
    )
    resource = described_class.new(
      name: 'test'
    )
    jenkins = Puppet::Type.type(:component).new(
      name: 'jenkins::cli::config',
      cli_jar: '/dne/catalog'
    )

    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource helper_resource
    catalog.add_resource resource
    catalog.add_resource jenkins
    req = resource.autorequire

    expect(req.size).to eq 1
    expect(req[0].source).to eq helper_resource
    expect(req[0].target).to eq resource
  end

  it 'autorequires cli_jar file from fact' do
    helper_resource = Puppet::Type.type(:file).new(
      path: '/dne/fact'
    )
    resource = described_class.new(
      name: 'test'
    )
    Facter.add(:jenkins_cli_jar) { setcode { '/dne/fact' } }

    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource helper_resource
    catalog.add_resource resource
    req = resource.autorequire

    expect(req.size).to eq 1
    expect(req[0].source).to eq helper_resource
    expect(req[0].target).to eq resource
  end

  it 'autorequires cli_jar file from catalog instead of fact' do
    helper_resource = Puppet::Type.type(:file).new(
      path: '/dne/catalog'
    )
    resource = described_class.new(
      name: 'test'
    )
    jenkins = Puppet::Type.type(:component).new(
      name: 'jenkins::cli::config',
      cli_jar: '/dne/catalog'
    )
    Facter.add(:jenkins_cli_jar) { setcode { '/dne/fact' } }

    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource helper_resource
    catalog.add_resource resource
    catalog.add_resource jenkins
    req = resource.autorequire

    expect(req.size).to eq 1
    expect(req[0].source).to eq helper_resource
    expect(req[0].target).to eq resource
  end
end

shared_examples 'autorequires all jenkins_user resources' do
  it 'autorequires single jenkins_user' do
    larry = Puppet::Type.type(:jenkins_user).new(
      name: 'larry'
    )
    resource = described_class.new(
      name: 'test'
    )

    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource larry
    catalog.add_resource resource
    req = resource.autorequire

    expect(req.size).to eq 1
    expect(req[0].source).to eq larry
    expect(req[0].target).to eq resource
  end

  it 'autorequires multiple jenkins_user(s)' do
    larry = Puppet::Type.type(:jenkins_user).new(
      name: 'larry'
    )
    moe = Puppet::Type.type(:jenkins_user).new(
      name: 'moe'
    )
    resource = described_class.new(
      name: 'test'
    )

    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource larry
    catalog.add_resource moe
    catalog.add_resource resource
    req = resource.autorequire

    expect(req.size).to eq 2
    expect(req[0].source).to eq larry
    expect(req[0].target).to eq resource

    expect(req[1].source).to eq moe
    expect(req[1].target).to eq resource
  end
end

shared_examples 'autorequires jenkins_security_realm resource' do
  it 'autorequires jenkins_security_realm resource' do
    required = Puppet::Type.type(:jenkins_security_realm).new(
      name: 'test'
    )
    resource = described_class.new(
      name: 'test'
    )
    resource[:ensure] = :present if described_class.validproperty?(:ensure)

    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource required
    catalog.add_resource resource
    req = resource.autorequire

    expect(req.size).to eq 1
    expect(req[0].source).to eq required
    expect(req[0].target).to eq resource
  end
end

shared_examples 'autorequires jenkins_authorization_strategy resource' do
  it 'autorequires jenkins_authorization_strategy resource' do
    required = Puppet::Type.type(:jenkins_authorization_strategy).new(
      name: 'test'
    )
    resource = described_class.new(
      name: 'test'
    )
    resource[:ensure] = :present if described_class.validproperty?(:ensure)

    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource required
    catalog.add_resource resource
    req = resource.autorequire

    expect(req.size).to eq 1
    expect(req[0].source).to eq required
    expect(req[0].target).to eq resource
  end
end
