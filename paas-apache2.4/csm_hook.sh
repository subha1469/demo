#!/bin/bash

export PATH=/etc/ansible/openssh/bin:$PATH
PROJECT_DIR=/etc/ansible/projects/paas-apache2.4

# First arg (target hostname) required
if [ -z $1 ]; then
	echo "Missing required hostname to provision to"
	exit 1
fi

# Sleeping for a few mins to give DNS a chance to update (known issue - ben)
sleep 300

LOGGER_NAME="AIS.PaaS.Provisioner"
echo "Provisioning Apache to $1"


# Filename hosts.template is a template file to create hosts/* files.
# Replace the __SERVER__ field in hosts.template with the destination
# hostname, and create a hosts/hosts.FQDN file before running the playbook.
CURRENT_DIR=$(pwd)
#cd /opt/LinuxCOE/SCM && java -jar BuildClient.jar -log $1 $LOGGER_NAME  "Initiating Apache deployment" Info
cd $CURRENT_DIR
sed "s/__SERVER__/${1}/" $PROJECT_DIR/hosts.template > $PROJECT_DIR/hosts/hosts.${1}

# Second arg (interface) optional. This is needed for csa workaround.
# Bit ugly but eventually we'll rewrite.
if [ "$2" = "eth1" ]; then
	sed -i 's/public_interface=eth0/public_interface=eth1/' $PROJECT_DIR/hosts/hosts.${1}
fi

ansible-playbook -u ansible -i $PROJECT_DIR/hosts/hosts.${1} $PROJECT_DIR/site.yml

if [ $? == 0 ]; then
	echo "Provision complete"
#	cd /opt/LinuxCOE/SCM && java -jar BuildClient.jar -log $1 $LOGGER_NAME "Apache deployment complete" Pass
	exit 0
else
	echo "Provision failed"
#	cd /opt/LinuxCOE/SCM && java -jar BuildClient.jar -log $1 $LOGGER_NAME "Apache deployment failed" Fail
	exit 1
fi
