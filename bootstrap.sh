#!/bin/sh -x

# This script is for bootstrapping puppet on a Blimpy machine

export PATH=/var/lib/gems/1.8/bin:$PATH

function provision_ubuntu() {
    which puppet

    if [ $? -ne 0 ]; then
        deb="puppetlabs-release-precise.deb"
        wget "http://apt.puppetlabs.com/${deb}"
        dpkg -i ./${deb}
        apt-get update
        apt-get install -y puppet
    fi
}

function provision_rhel() {
    which puppet

    if [ $? -ne 0 ]; then
        rpm -ivh https://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-7.noarch.rpm
        yum install -y puppet
    fi

}

grep -i "ubuntu" /etc/issue
if [ $? -eq 0 ]; then
    provision_ubuntu;
fi;

grep -i "red hat" /etc/issue
if [ $? -eq 0 ]; then
    provision_rhel
fi;

# Install all our stupid dependencies
for module in "stdlib" "apt" "java"; do
    ls /etc/puppet/modules | grep $module

    if [ $? -ne 0 ]; then
        # Didn't find the module, install it!
        puppet module install puppetlabs/${module}
    else
        echo ">> ${module} already installed"
    fi;
done;

platform=`facter lsbdistid`

# Set up a symbolic link to make sure we can include our $PWD as the "jenkins"
# module for `puppet apply`
ln -s $PWD /etc/puppet/modules/jenkins

echo ">> Provision for ${platform}"
puppet apply --verbose --modulepath=/etc/puppet/modules tests/${platform}.pp
