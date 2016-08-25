# The 'jpm' feature will help confine our custom jpm provider to only exist if
# we have the `jpm` rubygem installed
#
# Based on: <http://alcy.github.io/2012/11/21/handling-gem-dependencies-in-custom-puppet-providers/>

Puppet.features.add(:jpm, :libs => ['jpm'])
