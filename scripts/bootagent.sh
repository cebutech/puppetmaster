#!/usr/bin/env bash


# bootstraps Puppet on Ubuntu 12.04 LTS.
#
set -e

# Load up the release information
. /etc/lsb-release

REPO_DEB_URL="http://apt.puppetlabs.com/puppetlabs-release-${DISTRIB_CODENAME}.deb"

#--------------------------------------------------------------------
# NO TUNABLES BELOW THIS POINT
#--------------------------------------------------------------------
if [ "$EUID" -ne "0" ]; then
echo "This script must be run as root." >&2
  exit 1
fi

# Do the initial apt-get update
echo "Initial apt-get update..."
sudo apt-get update >/dev/null

# Install wget if we have to (some older Ubuntu versions)
echo "Installing wget..."
sudo apt-get install -y wget >/dev/null

# Install the PuppetLabs repo
echo "Configuring PuppetLabs repo..."
repo_deb_path=$(mktemp)
sudo wget --output-document=${repo_deb_path} ${REPO_DEB_URL} 2>/dev/null
sudo dpkg -i ${repo_deb_path} >/dev/null
sudo apt-get update >/dev/null

# Install Puppet
echo "Installing Puppet client agent!..."
sudo apt-get install -y puppet >/dev/null
#echo "192.168.1.141    puppet.example.net puppet" >> /etc/hosts
echo "puppet.agent.net puppetagent">> /etc/hosts
#echo "192.168.1.136	puppet.master.net	puppetmaster" >> /etc/hosts
echo "runinterval=30" >> /etc/puppet/puppet.conf
sed -i 's/START=no/START=yes/' /etc/default/puppet
sudo sed -i '8i\runinterval=30' /etc/puppet/puppet.conf 
puppet agent --server puppet.agent.net --pluginsync
sudo service puppet restart
echo "Puppet installed!"

