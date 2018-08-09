#!/bin/bash

set -e
export INSTALL=$HOME/docker-oracle-ee-base-18c/install

echo "Creating Directory"
groupadd dba && useradd -m -G dba oracle
rm -rf /u01
mkdir /u01 && mkdir -p /u01/app/oracle/product/18.0.0/dbhome_1 && chown -R oracle:dba /u01 && chmod -R 775 /u01

echo "Setting ENV"
echo oracle:oracle | chpasswd
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/18.0.0/dbhome_1

groupadd dba && useradd -m -G dba oracle
rm -rf /u01
mkdir /u01 && mkdir -p /u01/app/oracle/product/18.0.0/dbhome_1 && chown -R oracle:dba /u01 && chmod -R 775 /u01
echo oracle:oracle | chpasswd
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/18.0.0/dbhome_1

#Download oracle database zip
echo "Downloading oracle database zip"
wget -q --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=15CLHkPZzwih26oINeXvIB79Jny8zgqWh' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=15CLHkPZzwih26oINeXvIB79Jny8zgqWh" -O oracle_database.zip && rm -rf /tmp/cookies.txt

echo "Extracting oracle database zip"
su oracle -c 'unzip -q oracle_database.zip -d /u01/app/oracle/product/18.0.0/dbhome_1/'
#rm -f /oracle_database.zip

echo "setting up Response files"
cp $INSTALL/oracle-18c-ee.rsp $ORACLE_HOME/oracle-18c-ee.rsp
cp $INSTALL/oracle-18c-ee.rsp $ORACLE_HOME/dbca_18c.rsp
chmod 777 $ORACLE_HOME/oracle-18c-ee.rsp
chmod 777 $ORACLE_HOME/dbca_18c.rsp

su oracle -c "$ORACLE_HOME/runInstaller -force -skipPrereqs -silent -responseFile $ORACLE_HOME/oracle-18c-ee.rsp -waitForCompletion"

echo "Done"

#Cleanup
echo "Cleaning up"
rm -rf /home/oracle/database /tmp/*

#Connect to Oracle
su - oracle <<EOF
id
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/18.0.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
sqlplus -v
EOF

#database installation
echo "Default 18c database install with PDB"
dbca -silent -createDatabase -responseFile $ORACLE_HOME/dbca_18c.rsp

#Cleanup
echo "Cleaning up"
rm -rf /home/oracle/database /tmp/*

echo "DataBase Installed!!!"
