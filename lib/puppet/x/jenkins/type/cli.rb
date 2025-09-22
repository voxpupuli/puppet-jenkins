# frozen_string_literal: true

require_relative '../../jenkins/type'
require_relative '../../jenkins/config'

module Puppet::X::Jenkins::Type::Cli
  def self.newtype(*args, &block)
    type = Puppet::Type.newtype(*args, &block)

    # The jenkins controller needs to be avaiable in order to interact with it via
    # the cli jar.
    type.autorequire(:service) do
      ['jenkins']
    end

    # If a file resource is declared for file path params, make sure that it's
    # converged so we can read it off disk.
    type.autorequire(:file) do
      config = Puppet::X::Jenkins::Config.new(catalog)

      autos = []
      %w[ssh_private_key puppet_helper cli_jar].each do |param|
        value = config[param.to_sym]
        autos << value unless value.nil?
      end

      autos
    end
  end
end
