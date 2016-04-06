
module Puppet::Parser::Functions
  newfunction(:jenkins_port, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|
    Return the configurad Jenkins port value
    (corresponds to /etc/defaults/jenkins -> JENKINS_PORT

    Example:

        $port = jenkins_port()
    ENDHEREDOC

    config_hash = lookupvar('::jenkins::config_hash')
    if config_hash && \
       config_hash['HTTP_PORT'] && \
       config_hash['HTTP_PORT']['value']
      return config_hash['HTTP_PORT']['value']
    else
      return lookupvar('::jenkins::params::port')
    end
  end
end
