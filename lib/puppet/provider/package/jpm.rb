require 'puppet/provider/package'

################################################################################
# This comes from: <http://alcy.github.io/2012/11/21/handling-gem-dependencies-in-custom-puppet-providers/>
################################################################################
require 'jpm' if Puppet.features.jpm?
################################################################################

Puppet::Type.type(:package).provide :jpm, :parent => Puppet::Provider::Package do
  confine :feature => :jpm
  desc 'Provider for managing Jenkins plugins'

  has_feature :installable
  has_feature :uninstallable

  # These two features are pending the following issues being resolved for jpm:
  #   <https://github.com/rtyler/jpm/issues/8>
  #has_feature :upgradeable
  #   <https://github.com/rtyler/jpm/issues/7>
  #has_feature :versionable
end
