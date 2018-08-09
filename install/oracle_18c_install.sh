#!/bin/bash

set -e

RSP = $HOME/docker-oracle-ee-base-18c/install/oracle-18c-ee.rsp

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
su oracle -c 'unzip -q /oracle_database.zip -d /u01/app/oracle/product/18.0.0/dbhome_1/'
rm -f /oracle_database.zip

#Run installer
#su oracle -c "cd $ORACLE_HOME && ./runInstaller -skipPrereqs -silent -responseFile $RSP -waitForCompletion"
#Run Root.sh
/u01/app/oraInventory/orainstRoot.sh > /dev/null 2>&1
echo | /u01/app/oracle/product/18.0.0/dbhome_1/root.sh > /dev/null 2>&1 || true
#Cleanup
echo "Cleaning up"
#rm -rf /home/oracle/database /tmp/*

#Move product to custom location
#mv /u01/app/oracle/product /u01/app/oracle-product
