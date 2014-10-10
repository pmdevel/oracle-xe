#!/bin/bash

su -l -c "cp /tmp/shutdown_db.sql /u01/app/oracle/ " oracle
su -l -c "source $ORACLE_HOME/bin/oracle_env.sh; sqlplus / as sysdba @shutdown_db" oracle
