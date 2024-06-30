#!/usr/bin/env bash

# awk -F'[/:]' '{if ($3 >= 1000 && $3 != 65534) print $1}' /etc/passwd
# awk -F'[/:]' '{if ($3 >= 1000 && $3 != 65534) print $1}' /etc/group

# userdel -r <user>

# cuser=$(awk -F'[/:]' '{if ($3 >= 1000 && $3 != 65534) print $1}' /etc/passwd)

# echo ${cuser}

# read -p "Enter your site domain name to delete and press [ENTER]: " domainName
# dir_name=${domainName%.*}
# read -p "Enter your Directory name and press [$dir_name]: " serverRoot

# domain=$domainName

# PATH_SITE="/etc/apache2/sites-available"
# PATH_EN="/etc/apache2/sites-enabled"

# arr=(
# 		"${PATH_SITE}/${domain}.conf"
# 		"${PATH_EN}/${domain}.conf"
# 	)

# for i in "${arr[@]}"
# do
#     # access each element  
#     # as $i 
#     echo $i 
# done

sudo nginx -T | grep "server_name " | sed 's/.*server_name .\(.*\);/\1/' | sed 's/ /\n/'