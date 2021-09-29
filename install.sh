#!/bin/bash

# VARIABLES 
ROOTUSER="root"
DIR_SCRITP="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

printf "\n"
printf "Ingrese el hostname ej. octopus.vectoritcgroup.com\n"
printf "Si no existe ingrese la ip publica\n"
printf "Si no existe ingrese la ip local\n"
printf "[domain or ip]: "
read -r HOST_MACHINE
if [ -z "$HOST_MACHINE" ]
then
    echo "No valido"
    exit 1
fi

printf "\n"
printf "ingrese su ip publica ej. 181.181.181.181\n"
printf "Si no existe ingrese la ip local\n"
printf "[ip]: "
read IP_MACHINE
if [ -z "$IP_MACHINE" ]
then
    echo "No valido"
    exit 1
fi


printf "\n"
printf "ingrese nombre de la compania. ej. Vector ITC Group\n"
printf "Si no existe ingrese la ip local\n"
printf "[compania]: "
read COMPANY
if [ -z "$COMPANY" ]
then
    echo "No valido"
    exit 1
fi

printf "\n"
printf "ingrese contasena para el usuario root en la base de datos.\n"
printf "Minimo 6 caracteres\n"
printf "[mysql root pass]: "
read KEYPASS
if [ -z "$KEYPASS" ]
then
    echo "No valido"
    exit 1
fi

printf "\n"
printf "ingrese contasena para el usuario de asterisk en la base de datos.\n"
printf "Minimo 6 caracteres\n"
printf "[mysql asterisk pass]: "
read KEYPASS_ASTERISK
if [ -z "$KEYPASS_ASTERISK" ]
then
    echo "No valido"
    exit 1
fi

# instalacion dependencias primarias
yum -y install wget ca-certificates nano net-tools yum-utils
 
# instalacion de asterisk para octopus
cd /usr/local/src
wget http://downloads.asterisk.org/pub/telephony/asterisk/releases/asterisk-15.5.0.tar.gz
tar -zxvf asterisk-*
cd asterisk-*
./contrib/scripts/install_prereq install
./configure
make menuselect.makeopts
./menuselect/menuselect --enable format_mp3 menuselect.makeopts
./menuselect/menuselect --enable CORE-SOUNDS-ES-GSM menuselect.makeopts
./menuselect/menuselect --enable EXTRA-SOUNDS-EN-GSM menuselect.makeopts
./menuselect/menuselect --enable res_config_mysql menuselect.makeopts
./menuselect/menuselect --enable app_mysql menuselect.makeopts
./menuselect/menuselect --enable cdr_mysql menuselect.makeopts
make
./contrib/scripts/get_mp3_source.sh
make install
make config

# configuracion de certificado
cd contrib/scripts
mkdir -p /etc/asterisk/keys
./ast_tls_cert -C "$HOST_MACHINE" -O "$COMPANY" -d /etc/asterisk/keys

# configuraciones estandar asterisk
cd $DIR_SCRITP
cp etc/asterisk/* /etc/asterisk/

# error: Unable to connect to remote asterisk (does /var/run/asterisk/asterisk.ctl exist?)
# si obtienes este error se debe deshabilitar selinux usando la siguiente linea: 
setenforce 0 && sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
 
# desactivar firewalld (si es necesario)
systemctl stop firewalld
systemctl disable firewalld

# instalacion web server
yum -y install httpd mod_ssl
systemctl enable httpd

#configuracion virtualhost 
mkdir /etc/httpd/sites-available
mkdir /etc/httpd/sites-enabled
printf "\nIncludeOptional sites-enabled/*.conf" >> /etc/httpd/conf/httpd.conf
cp etc/httpd/sites-available/* /etc/httpd/sites-available/
ln -s /etc/httpd/sites-available/000-default.conf /etc/httpd/sites-enabled/000-default.conf

systemctl start httpd
 
#instalacion php y modulos especificos
yum -y install php php-common php-cli php-dom php-mysqlnd php-posix php-soap libzip
 
# servidor db mysql y configuracion 
yum -y install http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
yum -y install mysql-community-server
systemctl start mysqld
systemctl enable mysqld

yum -y install lame

mysql -uroot -e "use mysql; 
                  UPDATE user SET password=PASSWORD('$KEYPASS') WHERE user='$ROOTUSER'; 
                  FLUSH PRIVILEGES;"

mysql -uroot -p"$KEYPASS" -e "CREATE DATABASE asterisk;
                              GRANT ALL PRIVILEGES ON asterisk.* TO 'asterisk'@'localhost' IDENTIFIED BY '$KEYPASS_ASTERISK'; 
                              FLUSH PRIVILEGES;"

mysql -uroot -p"$KEYPASS" -e "CREATE TABLE asterisk.ast_cdr (
                                calldate datetime NOT NULL default '0000-00-00 00:00:00', 
                                clid varchar(80) NOT NULL default '', 
                                src varchar(80) NOT NULL default '', 
                                dst varchar(80) NOT NULL default '', 
                                dcontext varchar(80) NOT NULL default '', 
                                channel varchar(80) NOT NULL default '', 
                                dstchannel varchar(80) NOT NULL default '', 
                                lastapp varchar(80) NOT NULL default '', 
                                lastdata varchar(80) NOT NULL default '', 
                                duration int(11) NOT NULL default '0', 
                                billsec int(11) NOT NULL default '0', 
                                disposition varchar(45) NOT NULL default '', 
                                amaflags int(11) NOT NULL default '0', 
                                accountcode varchar(20) NOT NULL default '', 
                                uniqueid varchar(32) NOT NULL default '', 
                                userfield varchar(255) NOT NULL default '' 
                              );"


cd /etc/asterisk/
sed -i "s/^externip=public_ip/externip=$IP_MACHINE/g" sip.conf
sed -i "s/^localnet=local_ip/localnet=$IP_MACHINE/g" sip.conf
sed -i "s/asterisk_db_password/$KEYPASS_ASTERISK/g" res_mysql.conf
sed -i "s/asterisk_db_password/$KEYPASS_ASTERISK/g" cdr_mysql.conf

# reinicio de servicios
systemctl stop httpd
systemctl start httpd
systemctl status httpd

systemctl stop mysql
systemctl start mysql
systemctl status mysql

systemctl stop asterisk
systemctl start asterisk
systemctl status asterisk
