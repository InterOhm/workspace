#!/usr/bin/env bash
clear
read -p "Enter your domain name and press [ENTER]: " domainName
dir_name=${domainName%.*}
read -p "Enter your Directory name and press [$dir_name]: " serverRoot
read -p "Enter HTTP port number [80]: " defaultPort
read -p "Enter HTTPS port number [443]: " sslPort

PS3='Please enter PHP version of your choice: '
options=("7.3" "7.2" "7.1" "7.0" "5.6")
select opt in "${options[@]}"
do
  case $opt in
    "7.3")
      phpVer="7.3"
    break
    ;;
    "7.2")
      phpVer="7.2"
    break
    ;;
    "7.1")
      phpVer="7.1"
    break
    ;;
    "7.0")
      phpVer="7.0"
    break
    ;;
    "5.6")
      phpVer="5.6"
    break
    ;;
    *) echo invalid option;;
  esac
done

domain=$domainName
rootpath="/home/$SUDO_USER/${serverRoot:-$dir_name}"
defaultPort=${defaultPort:-80}
sslPort=${sslPort:-443}

# Create the Document Root directory
if [ ! -d $rootpath ]; then
  mkdir -p $rootpath 2>/dev/null
  # Assign ownership to your regular user account
  chown -R $SUDO_USER:$SUDO_USER $rootpath 2>/dev/null
fi

source $DIR/create-certificate.sh
