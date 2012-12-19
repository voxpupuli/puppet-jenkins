#!/bin/sh -x

# This script is for bootstrapping puppet on a Blimpy machine

export PATH=/var/lib/gems/1.8/bin:$PATH

which puppet

if [ $? -ne 0 ]; then
    apt-get update

    apt-get install -y ruby1.8 \
                    ruby1.8-dev \
                    libopenssl-ruby1.8 \
                    rubygems

    gem install puppet --version "~> 2.7" --no-ri --no-rdoc
fi


if [ ! -d "../stdlib" ]; then
    (cd .. && \
        wget "http://forge.puppetlabs.com/system/releases/p/puppetlabs/puppetlabs-stdlib-2.3.2.tar.gz" && \
        mkdir stdlib && \
        tar -zxf "puppetlabs-stdlib-2.3.2.tar.gz" -C stdlib --strip-components=1)
fi;

if [ ! -d "../apt" ]; then
    (cd .. && \
        wget "http://forge.puppetlabs.com/system/releases/p/puppetlabs/puppetlabs-apt-0.0.3.tar.gz" && \
        mkdir apt && \
        tar -zxf "puppetlabs-apt-0.0.3.tar.gz" -C apt --strip-components=1)
fi;

puppet apply --verbose --modulepath=.. tests/site.pp
