require 'puppet_x/jenkins/type/cli'

PuppetX::Jenkins::Type::Cli.newtype(:jenkins_user) do
  @doc = "Manage Jenkins' user account information"

  ensurable

  newparam(:name) do
    desc "Account login name.  Jenkins calls this 'id'"
    isnamevar
  end

  newproperty(:full_name) do
    desc 'Optional longer account name.'
  end

  newproperty(:email_address) do
    desc 'email address'
  end

  newproperty(:api_token_plain) do
    desc "Unhashed or 'plain_text' API token that is digested to produce the public API token"
    validate do |value|
      # 32 char hex string
      unless (value =~ /^\h{32}$/)
        raise ArgumentError, "#{value} is not a 32char hex string"
      end
    end
  end

  newproperty(:api_token_public) do
    # XXX validate
    desc 'Literal public API token.  read-only property.'
  end

  newproperty(:public_keys, :array_matching => :all) do
    desc 'Array of ssh public key strings'
  end

  newproperty(:password) do
    desc 'Password for HudsonPrivateSecurityRealm'
  end
end # PuppetX::Jenkins::Type::Cli.newtype
