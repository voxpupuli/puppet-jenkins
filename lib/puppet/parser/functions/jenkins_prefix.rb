# frozen_string_literal: true

module Puppet::Parser::Functions
  newfunction(:jenkins_prefix, type: :rvalue, doc: <<-ENDHEREDOC) do |_args|
    Return the configured Jenkins prefix value
    (corresponds to /etc/defaults/jenkins -> PREFIX)

    Example:

        $prefix = jenkins_prefix()
  ENDHEREDOC

    config_hash = lookupvar('jenkins::config_hash')
    config_hash&.dig('PREFIX', 'value') || ''
  end
end
