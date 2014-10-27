#!/bin/bash

CMD=$1

if [ "${CMD}" = "start" ]; then
	su -l -c "source $ORACLE_HOME/bin/oracle_env.sh; lsnrctl start " oracle
elif [ "${CMD}" = "start" ]; then
	su -l -c "source $ORACLE_HOME/bin/oracle_env.sh; lsnrctl stop " oracle
fi

