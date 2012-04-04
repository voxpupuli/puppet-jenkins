#!/bin/sh

which puppet-module

if [ $? -ne 0 ]; then
  gem install puppet-module --no-ri --no-rdoc
fi

exit 0
