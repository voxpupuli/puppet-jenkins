# frozen_string_literal: true

module Puppet::Parser::Functions
  newfunction(:jenkins_port, type: :rvalue, doc: <<-ENDHEREDOC) do |_args|
    Return the configured Jenkins port value
    (corresponds to /etc/defaults/jenkins -> JENKINS_PORT

    Example:

        $port = jenkins_port()
  ENDHEREDOC

    config_hash = lookupvar('jenkins::config_hash')
    config_port = lookupvar('jenkins::port')
    config_hash&.dig('JENKINS_PORT', 'value') || config_port
  end
end
