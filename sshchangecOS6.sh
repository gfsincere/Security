#! /bin/bash
# This script changes the ssh port for logins on CentOS 5 and 6
if [[ $EUID -ne 0 ]]; then
echo "This script must be run as root"
   exit 2
read -r -p "Would you like to change the ssh port? [Y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then	
   read -p "What would you like to change the port to? (Chose between 1024-65535) " sshportconfig
   if (( ("$sshportconfig" > 1024) && ("$sshportconfig" < 65535) )); then
	sed -ie 's/Port.*[0-19]$/Port '$sshportconfig'/gI' /etc/ssh/sshd_config
	echo "--------------------------------------------------------------------"
	echo ""
	echo ""
	echo "SSH port has been changed to: $sshportconfig. Written by Sincere the Minotaur."
	echo ""
	echo ""
	echo "--------------------------------------------------------------------"
   else
	echo "Port chosen is incorrect."
	exit 1
   fi
else 
   sshPort=$(grep "Port" /etc/ssh/sshd_config) | head -n 1
   echo "--------------------------------------------------------------------"
   echo ""
   echo ""
   echo "SSH is still: $sshPort"
   echo "Written by Sincere the Minotaur."
   echo ""
   echo "---------------------------------------------------------------------"
   exit 1
fi
exit 0

