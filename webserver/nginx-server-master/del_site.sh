#!/usr/bin/env bash

clear

read -p "Enter your site domain name to delete and press [ENTER]: " domainName
dir_name=${domainName%.*}
read -p "Enter your Directory name and press [$dir_name]: " serverRoot

domain=$domainName
rootpath="/home/$SUDO_USER/${serverRoot:-$dir_name}"

PS3='Please enter Service, to delete its site: '
options=("Apache2" "Nginx")
select opt in "${options[@]}"
do
  case $opt in
    "Apache2")
      PATH_SITE="/etc/apache2/sites-available"
      PATH_EN="/etc/apache2/sites-enabled"

      arr_del=(
      		"${PATH_SITE}/${domain}.conf"
      		"${PATH_SITE}/${domain}-ssl.conf"
      		"${PATH_EN}/${domain}.conf"
      		"${PATH_EN}/${domain}-ssl.conf"
      	)
    break
    ;;
    "Nginx")
      PATH_SITE="/etc/nginx/sites-available"
      PATH_EN="/etc/nginx/sites-enabled"

      arr_del=(
      		"${PATH_SITE}/${domain}"
      		"${PATH_EN}/${domain}"
      	)
    break
    ;;
    *) echo invalid option;;
  esac
done

# Delete the Document Root directory
if [ -d $rootpath ]; then
  rm -rf $rootpath 2>/dev/null
fi

if [ -n "$dom_site_ssl" ]; then
	rm -f $dom_site
	rm -f $site_en
	rm -f $dom_site_ssl
	rm -f $site_en_ssl
elif [ -f $dom_site ]; then
	rm -f $dom_site
	rm -f $site_en
fi

PATH_SSL="/etc/nginx/ssl"

PATH_CNF="${PATH_SSL}/${domain}.cnf"
PATH_CRT="${PATH_SSL}/${domain}.crt"
PATH_CSR="${PATH_SSL}/${domain}.csr"
PATH_KEY="${PATH_SSL}/${domain}.key"

if [ -f $PATH_CNF ] || [ -f $PATH_KEY ] || [ -f $PATH_CRT ] || [ -f $PATH_CSR ]
then
	rm -f $PATH_SSL/${domain}.*
fi

pause
return

