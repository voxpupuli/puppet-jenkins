require_relative '../../puppet/x/jenkins/type/cli'

Puppet::X::Jenkins::Type::Cli.newtype(:jenkins_credentials) do
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
              :ConduitCredentialsImpl,
              :StringCredentialsImpl,
              :FileCredentialsImpl,
              :AWSCredentialsImpl,
              :GitLabApiTokenImpl,
              :BrowserStackCredentials)
  end

  newproperty(:description) do
    desc 'description of credentials'
    defaultto 'Managed by Puppet'
  end

  newproperty(:username) do
    desc 'username for credentials - UsernamePasswordCredentialsImpl, CertificateCredentialsImpl, BrowserStackCredentials'
  end

  newproperty(:password) do
    desc 'password - UsernamePasswordCredentialsImpl, CertificateCredentialsImpl'
    def is_to_s(_current_value)
      '[old password]'
    end

    def should_to_s(_new_value)
      '[new password]'
    end

    def change_to_s(_current_value, _new_value)
      if _current_value == :absent
        return "Added '#{name}' as #{should_to_s(_new_value)}"
      elsif _new_value == :absent or _new_value == [:absent]
        return "Removed '#{name}' from #{is_to_s(_current_value)}"
      else
        return "Changed '#{name}' from #{is_to_s(_current_value)} to #{should_to_s(_new_value)}"
      end
    end
  end

  newproperty(:private_key) do
    desc 'ssh private key string - BasicSSHUserPrivateKey'
    def is_to_s(_current_value)
      '[old ssh private key string]'
    end

    def should_to_s(_new_value)
      '[new ssh private key string]'
    end

    def change_to_s(_current_value, _new_value)
      if _current_value == :absent
        return "Added '#{name}' as #{should_to_s(_new_value)}"
      elsif _new_value == :absent or _new_value == [:absent]
        return "Removed '#{name}' from #{is_to_s(_current_value)}"
      else
        return "Changed '#{name}' from #{is_to_s(_current_value)} to #{should_to_s(_new_value)}"
      end
    end
  end

  newproperty(:access_key) do
    desc 'AWS access key - AWSCredentialsImpl, BrowserStackCredentials'
    def is_to_s(_current_value)
      '[old AWS access key]'
    end

    def should_to_s(_new_value)
      '[new AWS access key]'
    end

    def change_to_s(_current_value, _new_value)
      if _current_value == :absent
        return "Added '#{name}' as #{should_to_s(_new_value)}"
      elsif _new_value == :absent or _new_value == [:absent]
        return "Removed '#{name}' from #{is_to_s(_current_value)}"
      else
        return "Changed '#{name}' from #{is_to_s(_current_value)} to #{should_to_s(_new_value)}"
      end
    end
  end

  newproperty(:secret_key) do
    desc 'AWS secret key - AWSCredentialsImpl'
    def is_to_s(_current_value)
      '[old AWS secret key]'
    end

    def should_to_s(_new_value)
      '[new AWS secret key]'
    end

    def change_to_s(_current_value, _new_value)
      if _current_value == :absent
        return "Added '#{name}' as #{should_to_s(_new_value)}"
      elsif _new_value == :absent or _new_value == [:absent]
        return "Removed '#{name}' from #{is_to_s(_current_value)}"
      else
        return "Changed '#{name}' from #{is_to_s(_current_value)} to #{should_to_s(_new_value)}"
      end
    end
  end

  newproperty(:passphrase) do
    desc 'passphrase to unlock ssh private key - BasicSSHUserPrivateKey'
    def is_to_s(_current_value)
      '[old passphrase]'
    end

    def should_to_s(_new_value)
      '[new passphrase]'
    end

    def change_to_s(_current_value, _new_value)
      if _current_value == :absent
        return "Added '#{name}' as #{should_to_s(_new_value)}"
      elsif _new_value == :absent or _new_value == [:absent]
        return "Removed '#{name}' from #{is_to_s(_current_value)}"
      else
        return "Changed '#{name}' from #{is_to_s(_current_value)} to #{should_to_s(_new_value)}"
      end
    end
  end

  newproperty(:secret) do
    desc 'secret string - StringCredentialsImpl'
    def is_to_s(_current_value)
      '[old secret string]'
    end

    def should_to_s(_new_value)
      '[new secret string]'
    end

    def change_to_s(_current_value, _new_value)
      if _current_value == :absent
        return "Added '#{name}' as #{should_to_s(_new_value)}"
      elsif _new_value == :absent or _new_value == [:absent]
        return "Removed '#{name}' from #{is_to_s(_current_value)}"
      else
        return "Changed '#{name}' from #{is_to_s(_current_value)} to #{should_to_s(_new_value)}"
      end
    end
  end

  newproperty(:file_name) do
    desc 'name of file - FileCredentialsImpl'
  end

  newproperty(:content) do
    desc 'content of file - FileCredentialsImpl, CertificateCredentialsImpl'
    def is_to_s(_current_value)
      '[old content]'
    end

    def should_to_s(_new_value)
      '[new content]'
    end

    def change_to_s(_current_value, _new_value)
      if _current_value == :absent
        return "Added '#{name}' as #{should_to_s(_new_value)}"
      elsif _new_value == :absent or _new_value == [:absent]
        return "Removed '#{name}' from #{is_to_s(_current_value)}"
      else
        return "Changed '#{name}' from #{is_to_s(_current_value)} to #{should_to_s(_new_value)}"
      end
    end
  end

  newproperty(:source) do
    desc 'content of file - CertificateCredentialsImpl'
    def is_to_s(_current_value)
      '[old content]'
    end

    def should_to_s(_new_value)
      '[new content]'
    end

    def change_to_s(_current_value, _new_value)
      if _current_value == :absent
        return "Added '#{name}' as #{should_to_s(_new_value)}"
      elsif _new_value == :absent or _new_value == [:absent]
        return "Removed '#{name}' from #{is_to_s(_current_value)}"
      else
        return "Changed '#{name}' from #{is_to_s(_current_value)} to #{should_to_s(_new_value)}"
      end
    end
  end

  newproperty(:key_store_impl) do
    desc 'name of the java class implimenting the key store - CertificateCredentialsImpl'
  end

  newproperty(:token) do
    desc 'conduit token - ConduitCredentialsImpl'
  end

  newproperty(:api_token) do
    desc 'API token - GitLabApiTokenImpl'
  end

  newproperty(:url) do
    desc 'URL of phabriactor installation - ConduitCredentialsImpl'
  end

  # require all authentication & authorization related types
  [
    :jenkins_user,
    :jenkins_security_realm,
    :jenkins_authorization_strategy
  ].each do |type|
    autorequire(type) do
      catalog.resources.select do |r|
        r.is_a?(Puppet::Type.type(type))
      end
    end
  end
end # Puppet::X::Jenkins::Type::Cli.newtype
