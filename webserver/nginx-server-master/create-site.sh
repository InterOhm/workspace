#!/usr/bin/env bash

show_menus() {
	write_header " CREATE SITE - M E N U "
	echo "1. Laravel"
	echo "2. Apache"
	echo "3. Magento"
	echo "4. Proxy"
	echo "5. Wordpress"
	echo "6. Zend"
	echo "7. Symfony2"
	echo "8. Symfony4"
	echo "9. Vanilla PHP"
	echo "10. Go Back"
}

read_options(){
	local choice
	read -p "Enter choice [ 1 - 10] " choice
	case $choice in
		1) source $DIR/site-types/laravel.sh ;;
		2) source $DIR/site-types/apache.sh ;;
		3) source $DIR/site-types/magento.sh ;;
		4) source $DIR/site-types/proxy.sh ;;
		5) source $DIR/site-types/wordpress.sh ;;
		6) source $DIR/site-types/zend.sh ;;
		7) source $DIR/site-types/symfony2.sh ;;
		8) source $DIR/site-types/symfony4.sh ;;
		9) source $DIR/site-types/vanilla_php.sh ;;
		10) source $DIR/main.sh ;;
		*) echo -e "${RED}Error...${STD}" && sleep 2
	esac
}