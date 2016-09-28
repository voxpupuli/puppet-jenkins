require 'puppet_x/jenkins/type/cli'

PuppetX::Jenkins::Type::Cli.newtype(:jenkins_credentials) do
  @doc = <<-EOS
    Manage Jenkins' credentials

    XXX The properties specified are not validated against the specified
        jenkins class (`impl`)
  EOS

  ensurable

  newparam(:name) do
    desc 'Id for credentials entry'
    isnamevar
  end

  newproperty(:domain) do
    desc 'credentials domain within jenkins - :undef indicates the "global" domain'
    defaultto :undef
    newvalues(:undef)
  end

  newproperty(:scope) do
    desc 'credentials scope within jenkins'
    defaultto :GLOBAL
    newvalues(:GLOBAL, :SYSTEM)
  end

  newproperty(:impl) do
    desc 'name of the java class implimenting the credential'
    defaultto :UsernamePasswordCredentialsImpl
    newvalues(:UsernamePasswordCredentialsImpl,
              :BasicSSHUserPrivateKey,
              :StringCredentialsImpl)
  end

  newproperty(:description) do
    desc 'description of credentials'
    defaultto 'Managed by Puppet'
  end

  newproperty(:username) do
    desc 'username for credentials - UsernamePasswordCredentialsImpl, CertificateCredentialsImpl'
  end

  newproperty(:password) do
    desc 'password - UsernamePasswordCredentialsImpl, CertificateCredentialsImpl'
  end

  newproperty(:private_key) do
    desc 'ssh private key string - BasicSSHUserPrivateKey'
  end

  newproperty(:passphrase) do
    desc 'passphrase to unlock ssh private key - BasicSSHUserPrivateKey'
  end

  newproperty(:secret) do
    desc 'secret string - StringCredentialsImpl'
  end

  newproperty(:file_name) do
    desc 'name of file - FileCredentialsImpl'
  end

  newproperty(:content) do
    desc 'content of file - FileCredentialsImpl, CertificateCredentialsImpl'
  end

  newproperty(:source) do
    desc 'content of file - CertificateCredentialsImpl'
  end

  newproperty(:key_store_impl) do
    desc 'name of the java class implimenting the key store - CertificateCredentialsImpl'
  end

  # require all authentication & authorization related types
  [
    :jenkins_user,
    :jenkins_security_realm,
    :jenkins_authorization_strategy,
  ].each do |type|
    autorequire(type) do
      catalog.resources.find_all do |r|
        r.is_a?(Puppet::Type.type(type))
      end
    end
  end
end # PuppetX::Jenkins::Type::Cli.newtype
