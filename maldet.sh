# To install Screen and Maldet on Servers
#!/bin/bash
#Server hardening script written by Sincere the Minotaur
if [[ $EUID -ne 0 ]]; then
echo "This script must be run as root"
   exit 1
fi
echo "---------------------------------"
echo ""
echo "Installing screen and maldet to server"
echo ""
echo ""
echo "---------------------------------"
#grabbing screen
yum install screen -y
#grabbing maldet
wget http://www.rfxn.com/downloads/maldetect-current.tar.gz
tar -xzf maldetect-current.tar.gz
cd maldetect-1.4.2
sh install.sh
#Running the maldet automagically
read -r -p "Would you like to run the scan in screen now? [Y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then
	screen -d -m -S "maldet" maldet -a /
	echo "--------------------------------------------------------------------"
	echo ""
	echo ""
	echo "Maldet scan running successfully. Use screen -r maldet to check progress."
	echo "++++++++++++++Written by Sincere the Minotaur+++++++++++++++++"
	echo ""
	echo ""
	echo "---------------------------------------------------------------------"
else
	echo "--------------------------------------------------------------------"
	echo ""
	echo ""
	echo "Maldet and screen successfully installed. Written by Sincere the Minotaur."
	echo ""
	echo ""
	echo "---------------------------------------------------------------------"
	exit 0
fi
	
