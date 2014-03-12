# Add the 'json' feature to help confine our custom providers
#
# This comes from: <http://alcy.github.io/2012/11/21/handling-gem-dependencies-in-custom-puppet-providers/>

Puppet.features.add(:json, :libs => ["json"])
