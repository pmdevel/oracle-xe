#!/bin/bash

CHARSET=$1

echo "####################################################"
echo "Recreating database with $CHARSET character set"
echo "####################################################"
su -l -c "source $ORACLE_HOME/bin/oracle_env.sh; $ORACLE_HOME/bin/createdb.sh -dbchar $CHARSET;" oracle
