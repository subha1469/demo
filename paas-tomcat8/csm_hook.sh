#!/bin/bash

export PATH=/etc/ansible/openssh/bin:$PATH
PROJECT_DIR=/etc/ansible/projects/paas-tomcat7

if [ -z $1 ]; then
        echo "Missing required hostname to provision to"
        exit 1
fi

# Sleeping for a few mins to give DNS a chance to update (known issue - ben)
sleep 300

LOGGER_NAME="AIS.PaaS.Provisioner"

echo "Provisioning Tomcat 7 to $1"

CURRENT_DIR=$(pwd)
cd /opt/LinuxCOE/SCM && java -jar BuildClient.jar -log $1 $LOGGER_NAME  "Initiating Tomcat 7 deployment" Info
cd $CURRENT_DIR
sed "s/__SERVER__/${1}/" $PROJECT_DIR/hosts > $PROJECT_DIR/hosts.${1}
ansible-playbook -u ansible -i $PROJECT_DIR/hosts.${1} $PROJECT_DIR/site.yml

if [ $? == 0 ]; then
        echo "Provision complete"
        cd /opt/LinuxCOE/SCM && java -jar BuildClient.jar -log $1 $LOGGER_NAME "Tomcat 7 deployment complete" Pass
        exit 0
else
        echo "Provision failed"
        cd /opt/LinuxCOE/SCM && java -jar BuildClient.jar -log $1 $LOGGER_NAME "Tomcat 7 deployment failed" Fail
        exit 1
fi
