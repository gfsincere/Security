#!/bin/bash

# Regular Colors
Black='\e[0;30m'
Red='\e[0;31m'
Green='\e[0;32m'
Yellow='\e[0;33m'
Blue='\e[0;34m'
Purple='\e[0;35m'
Cyan='\e[0;36m'
White='\e[0;37m'

# Bold Colors
BBlack='\e[1;30m'
BRed='\e[1;31m'
BGreen='\e[1;32m'
BYellow='\e[1;33m'
BBlue='\e[1;34m'
BPurple='\e[1;35m'
BCyan='\e[1;36m'
BWhite='\e[1;37m'

# Reset Color
Color_Off='\e[0m'

remove_apf_bfd() {
	printf "\n${Yellow}[!]${Color_Off} APF and/or BFD has been detected!\n"
	printf "${Blue}Do you want to remove them?${Color_Off} [yes or no]: "
	read yesno
	case $yesno in
		[yY][Ee][Ss] ) printf "Proceeding...\n";;
		[nN][Oo] ) printf "Exiting...\n\n"; exit 1;;
		*) printf "Invalid input\n\n"; exit 1;;
	esac
}

# Determine installed OS and install dependencies if missing
#OS=$(lsb_release -i | awk '{print $3}')

if [ -f /etc/redhat-release ]; then
	OS="CentOS"
elif [ -f /etc/debian_version ]; then
	OS="Debian"
fi

if [ $OS = "CentOS" ]; then
        installer='yum'
	if [ -n "$(grep 'CentOS release 6' /etc/redhat-release)" ]; then
		depends='perl-libwww-perl perl-Time-HiRes'
	else
		depends='perl-libwww-perl'
	fi
	printf "\n${Green}CentOS confirmed!${Color_Off}\n"
	sleep 1
elif [ $OS = "Debian" ]; then
        installer='apt-get'
	depends='libwww-perl'
        printf "\n${Green}Debian confirmed!${Color_Off}\n"
	sleep 1
#elif [ $OS = "Ubuntu" ]; then
#        installer='apt-get'
#	depends='libwww-perl'
#        printf "\n${Green}Ubuntu confirmed!${Color_Off}\n"
#	sleep 1
else
        printf "\nThis is not a supported OS.\n"
        exit 1
fi

# Check if either CSF/LFD or APF/BFD is installed
if [ -d /etc/csf ]; then csf=true; else csf=false; fi
if [ -d /etc/apf ]; then apf=true; else apf=false; fi
if [ -d /usr/local/bfd ]; then bfd=true; else bfd=false; fi

if [ $csf = false ]; then
        # Download and install CSF/LFD
        printf "\n${Yellow}[!]${Color_Off} No CSF/LFD installation detected!\n"
	sleep 2
	if [ $apf = true -o $bfd = true ]; then
        	remove_apf_bfd
		remove=true
	fi
	printf "\n${Yellow}[1]${Color_Off} Backing up current firewall rules to /etc/iptables.bak\n"
	sleep 2
        /sbin/iptables-save > /etc/iptables.bak
	printf "\n${Yellow}[2]${Color_Off} Installing dependencies...\n"
	sleep 2
	$installer install -y $depends
	printf "\n${Yellow}[3]${Color_Off} Downloading and installing CSF/LFD...\n"
	sleep 2
	rm -rf csf*
	wget http://www.configserver.com/free/csf.tgz
	tar -xzf csf.tgz
	cd csf
	if [ $remove = true ]; then
		sh remove_apf_bfd.sh
	fi
	sh install.sh
	cd ..
	rm -rfv csf*
	printf "\n${Yellow}[4]${Color_Off} Performing post-install configuration and restarting services...\n"
	sleep 2
	sed -i 's/^TESTING = "1"/TESTING = "0"/' /etc/csf/csf.conf
	sed -i 's/^ICMP_IN_RATE = "1/ICMP_IN_RATE = "5/' /etc/csf/csf.conf
	sed -i 's/^LF_DIRWATCH_DISABLE = "0"/LF_DIRWATCH_DISABLE = "1"/' /etc/csf/csf.conf
	sed -i 's/^SYSLOG_CHECK = "0"/SYSLOG_CHECK = "300"/' /etc/csf/csf.conf
	sed -i '/69.65.5.30/d' /etc/csf/csf.allow
	echo -e "69.65.5.30 # GigeNET NOC IP\n69.65.30.3 # GigeNET Monitor IP" | tee -a /etc/csf/csf.allow /etc/csf/csf.ignore > /dev/null
	/etc/init.d/csf restart && /etc/init.d/lfd restart
	printf "\n${Green}[5]${Color_Off} It's done!\n\n"
else
        # Inform the administrator
        printf "${Green}Detected CSF/LFD already installed, checking status...${Color_Off}\n\n"
	sleep 2
        /etc/init.d/csf status && /etc/init.d/lfd status
fi

sleep 20
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
sleep 20
#This next section is dedicated to securing SSH
#Changing the SSH port
read -r -p "Would you like to change the ssh port? [Y/N] " sshresp
if [[ $sshresp =~ ^([yY][eE][sS]|[yY])$ ]]
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
	exit 0
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
   exit 0
fi
sleep 20
# Future addons: 
# Disable root login
# Creating a user to have su access and group granted su access
# Installing OSSEC agent
# Adding Artillery for port scanning lockdown
#
#
#saving maldet for last as it might be a new server or if its a older server with security issues
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
read -r -p "Would you like to run the scan in screen now? [Y/N] " malscresp
if [[ $malscresp =~ ^([yY][eE][sS]|[yY])$ ]]
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
sleep 5
