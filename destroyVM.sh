###################################################################################
!/bin/bash
###################################################################################
##################### Author : Manmohan Gehlot ####################################
###################################################################################

if [ ! -f /etc/ansible/log.ec2 ];
then
   echo "First create EC2 instance and then use this script to destroy instance!"
   exit 1;
fi 

tmpVar=$(grep -n '"instance_ids": \[' log.ec2)
lineno="${tmpVar//[!0-9]/}"
nextno=$(( $lineno + 1 ))
inst_id=$(sed -n "$nextno"p log.ec2)
inst_id=${inst_id//[[:blank:]]/}

sudo sed -i "s/instance_ids=/instance_ids=$inst_id/g" terminate_EC2.yml

sudo bash -c 'ansible-playbook terminate_EC2.yml > tmpfile'

sudo bash -c 'rm tmpfile'

echo "Executing process ......................!!!"

echo "Instance has been terminated ...........!!!"

sudo bash -c 'rm log.ec2'
