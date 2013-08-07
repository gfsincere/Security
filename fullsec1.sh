#! /bin/bash
#Attempt at a full sec script
if [[ $EUID -ne 0 ]]; then
echo "This script must be run as root"
   exit 1
read -r -p "Would you like to change the ssh port? [Y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then	
	read -r -p "What would you like to change the port to? (Chose between 1024-65535) " sshportconfig
	echo "Port $sshportconfig" >> /etc/ssh/sshd_config
	echo "--------------------------------------------------------------------"
	echo ""
	echo ""
	echo "SSH port has been changed to $sshportconfig. Written by Sincere the Minotaur."
	echo ""
	echo ""
	echo "--------------------------------------------------------------------"
else 
	sshPort=$(grep "Port" /etc/ssh/sshd_config) | head -n 1
	echo "--------------------------------------------------------------------"
	echo ""
	echo ""
	echo "SSH is still $sshPort"
	echo "Written by Sincere the Minotaur."
	echo ""
	echo "---------------------------------------------------------------------"
	exit 0
fi
sleep 1
read -r -p "Would you like to install denyhosts [Y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then
	wget http://downloads.sourceforge.net/project/denyhosts/denyhosts/2.6/DenyHosts-2.6.tar.gz
	tar -xzvf DenyHosts-2.6.tar.gz
	cd DenyHosts-2.6
# installs DenyHosts
	python setup.py install
	cd /usr/share/denyhosts
	cp denyhosts.cfg-dist denyhosts.cfg
	cp daemon-control-dist daemon-control
	ln -s /usr/share/denyhosts/daemon-control /etc/init.d/denyhosts
	update-rc.d denyhosts defaults
	crontab -l > denyho
	echo "0,20,40 * * * * python DenyHosts-2.6/denyhosts.py -c 0,20,40 * * * * python DenyHosts-2.6/denyhosts.cfg" >> denyho
	crontab denyho
	rm denyho
	echo "--------------------------------------------------------------------"
	echo ""
	echo ""
	echo "Denyhosts is installed and running. Written by Sincere the Minotaur."
	echo ""
	echo ""
	echo "---------------------------------------------------------------------"
	exit 0
else
	echo "--------------------------------------------------------------------"
	echo ""
	echo ""
	echo "Denyhosts not installed. Written by Sincere the Minotaur."
	echo ""
	echo ""
	echo "---------------------------------------------------------------------"
	exit 0
fi
