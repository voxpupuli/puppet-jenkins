require 'puppet/provider/package'

################################################################################
# This comes from: <http://alcy.github.io/2012/11/21/handling-gem-dependencies-in-custom-puppet-providers/>
#
# This should help prevent us from attempting to operate in an environment
# where we don't have the `json` gem which we'll need to parse the update
# center JSON
require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.features.rubygems?
require 'json' if Puppet.features.json?
################################################################################

Puppet::Type.type(:package).provide :jenkins, :parent => Puppet::Provider::Package do
  confine :feature => :json
  desc "Provider for managing Jenkins plugins"

  has_feature :installable, :uninstallable, :upgradeable, :versionable
end
