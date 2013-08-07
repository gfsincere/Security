#! /bin/bash
# This script changes the ssh port for logins on CentOS 5 and 6
if [[ $EUID -ne 0 ]]; then
echo "This script must be run as root"
   exit 1
read -r -p "Would you like to change the ssh port? [Y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
	then	
		read -r -p "What would you like to change the port to? (Chose between 1024-65535)" sshportconfig
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
	