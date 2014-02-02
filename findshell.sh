#!/bin/bash

#Written by @minossec aka Black Tony Stark
#This is to find c99 shell scripts running on a system
#Usage = findshell.sh <directory to search> <where to save the logs> <where to save base64 logs>

if [[ $EUID -ne 0 ]]; then
echo "This script must be run as root"
fi

SEARCHY=${1:-/}
# will work from root if no directory is passed in the argument.
SEA_LOGS=${2:-/var/log/shells.log}
#will store the results in /var/log/shells.log if no argument is passed
DANGER=${3:-/var/log/danger.log}
#will store any results in ../danger.log if no argument is passed
#these logs are stored separately in case they need to be decoded en masse.
PHPCONFIG=/etc/php.ini
echo "Starting search from $SEARCHY..."
echo "Starting with .php files..."
find $SEARCHY -iname '*.php'  -type f -exec grep -Hi "r57" {} \\; | uniq -c > $SEA_LOGS
find $SEARCHY -iname '*.php'  -type f -exec grep -Hi "c99" {} \\; | uniq -c >> $SEA_LOGS
find $SEARCHY -iname '*.php' -exec grep -Hi "base64_decode" {} \;  > $DANGER

echo "Next are .txt files..."
find $SEARCHY  -iname '*.txt'  -type f -exec grep -Hi "r57" {} \\; | uniq -c >> $SEA_LOGS
find $SEARCHY  -iname '*.txt'  -type f -exec grep -Hi "c99" {} \\; | uniq -c >> $SEA_LOGS
find $SEARCHY -iname '*.txt' -exec grep -Hi "base64_decode" {} \;  >> $DANGER

echo "Now searching .gif files..."
find $SEARCHY -iname '*.gif'  -type f -exec grep -Hi "r57" {} \\; | uniq -c >> $SEA_LOGS
find $SEARCHY -iname '*.gif'  -type f -exec grep -Hi "c99" {} \\; | uniq -c >> $SEA_LOGS
find $SEARCHY -iname '*.gif' -exec grep -Hi "base64_decode" {} \;  >> $DANGER


echo "Complete."
sleep 5
echo "The results can be found "
read -r -p "Would you like to disable certain functions (passthru, exec, etc) to protect yourself from future attacks?" response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]] ; then
	if [ ! -f $PHPCONFIG ]; then
		echo "$PHPCONFIG not found"
		exit 1
	fi
	else
	 echo "disable_functions = show_source, system, shell_exec, passthru, exec, phpinfo, popen, proc_open" >> $PHPCONFIG
fi
exit 0