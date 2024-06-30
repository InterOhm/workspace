#!/usr/bin/env bash

echo "$ ssh-keygen"
echo "$ ssh-copy-id <username>@<remote_host>"
echo ""
echo "Note: Remember only disable password based authentication after following above steps"
read -p "Do you want to continue (Y/n): " conti

if [ $conti = "Y" ]; then
	sed -i "s/PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config
	systemctl restart ssh
	return
else
	return
fi