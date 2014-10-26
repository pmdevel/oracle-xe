#!/bin/bash

CMD=$1

if [ "${CMD}" = "start" ]; then
    echo "Start"
elif [ "${CMD}" = "stop" ]; then
    echo "Stop"
fi
