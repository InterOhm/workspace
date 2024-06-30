#!/usr/bin/env bash

if [ "$EUID" != 0 ]
  then echo "Please run as sudo"
  exit
fi

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# A menu driven shell script sample template 
## ----------------------------------
# Step #1: Define variables
# ----------------------------------
EDITOR=vim
PASSWD=/etc/passwd
RED='\033[0;41;30m'
STD='\033[0;0;39m'
 
# ----------------------------------
# Step #2: User defined function
# ----------------------------------

function pause(){
	local message="$@"
	[ -z $message ] && message="Press [Enter] key to continue..."
	read -p "$message" readEnterKey
}

# Purpose - Display header message
# $1 - message
function write_header(){
	local h="$@"
	echo "---------------------------------------------------------------"
	echo "     ${h}"
	echo "---------------------------------------------------------------"
}

one(){
	source $DIR/setup-server.sh
}
 
# do something in two()
two(){
	source $DIR/create-site.sh
}

disable_passwd(){
	source $DIR/disable_ssh_passwd.sh
}

del_site(){
	source $DIR/del_site.sh
}
 
# function to display menus
show_menus() {
	write_header " M A I N - M E N U "
	echo "1. Setup Server"
	echo "2. Create Site"
	echo "3. Edit Site"
	echo "4. Delete Site"
	echo "5. Disable Password based authentication to server"
	echo "6. Exit"
}
# read input from the keyboard and take a action
# invoke the one() when the user select 1 from the menu option.
# invoke the two() when the user select 2 from the menu option.
# Exit when user the user select 3 form the menu option.
read_options(){
	local choice
	read -p "Enter choice [ 1 - 3] " choice
	case $choice in
		1) one ;;
		2) two ;;
		4) del_site ;;
		5) disable_passwd ;;
		3) exit 0;;
		*) echo -e "${RED}Error...${STD}" && sleep 2
	esac
}
 
# ----------------------------------------------
# Step #3: Trap CTRL+C, CTRL+Z and quit singles
# ----------------------------------------------
# trap '' SIGINT SIGQUIT SIGTSTP
 
# -----------------------------------
# Step #4: Main logic - infinite loop
# ------------------------------------
while true
do
	clear
	show_menus
	read_options
done