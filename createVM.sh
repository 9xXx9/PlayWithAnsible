###############################################################################

#!/bin/bash
########Author: Manmohan Gehlot and Archana Joshi September 13,2016 ###########

##############################################################################

echo "Make sure you have get following configuration :
1. Create a boto file with aws security credentials.
2. Private key to connect aws instance.
3. Downloaded ec2.py and ec2.ini."

read -p "Are sure to continue? : (y/n) " ans

if [ "$ans" != "y" ]; then 
   echo "Sorry! wrong input. please try againg"
   exit 1;
fi



read -p "Enter the path to ansible installation dir :" pathtofile
export base_dir=$pathtofile

read -p "Provide aws private key path with extenstion(.pem) :" keypath
export pem_path=$keypath

#update the vm time else will get aws auth error
echo "Updating system timestamp .............!!!"
sudo bash -c 'ntpdate ntp.ubuntu.com&>dev null'

echo "Creating EC2 server ...................!!!"

sudo bash -c 'ansible-playbook -i hosts -vvvv ec2_create.yml > log.ec2'

echo "Created instance successfully..........!!!"
echo "Waiting for EC2 isntance come up.......!!!"
 
#Wait until EC2 instance come up
sleep 3m

sudo bash -c 'echo -e "[localhost]\n127.0.0.1 ansible_connection=local" > hosts'

#find the public ip of the new EC2 instance
ec2_public_ip=`grep -o  -P 'public_ip.{0,20}' log.ec2| cut -d'"' -f3|head -1`

#create the new host entry for the new EC2 server in local inventory
sudo rm hosts
sudo touch hosts
 
sudo bash -c 'cat hosts_template | sed '"'s/publicip/$ec2_public_ip/g'"' | sed '"'s?pempath?$pem_path?g'"' > hosts'

echo "Installing and starting Apache webserver.................!!!"

sudo bash -c 'ansible-playbook -i hosts install_webserver.yml > log.tmp'

sudo bash -c 'rm log.tmp'

echo "Bravo!! Apache server successfully installed and running.!!!"
 
echo "Done ....................................................!!!"
echo "Visit URL: http://$ec2_public_ip/HelloAnsible.html"
