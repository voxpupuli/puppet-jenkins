require 'puppet/provider/package'

Puppet::Type.type(:package).provide :jenkinsplugin, :parent => Puppet::Provider::Package do
  desc "Provider for managing Jenkins plugins"

  has_feature :installable, :uninstallable, :upgradeable, :versionable
end
