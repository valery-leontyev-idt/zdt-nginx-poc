#!/bin/sh

FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

COMMAND=$1
SERVICE_NAME=$2

if [ "$COMMAND" == "" ]
then
    echo "Usage: ./active-env.sh [get|set-blue|set-green|switch] service_name"
    exit;
fi

getEnv() {
    cat $FILE_DIR"/services/"$SERVICE_NAME"-active-env" | cut -d " " -f 3 | tr -dc '[:alnum:]'
    echo
}

setEnv () {
    printf "set \$ACTIVE_ENV $1;" > $FILE_DIR"/services/"$SERVICE_NAME"-active-env"
    echo $1" environment has been set for "$SERVICE_NAME
}


if [ "$COMMAND" == "get" ]
then
    getEnv
    exit;
fi

if [ "$COMMAND" == "set-blue" ]
then
    setEnv "blue"
    exit;
fi

if [ "$COMMAND" == "set-green" ]
then
    setEnv "green"
    exit;
fi

if [ "$COMMAND" == "switch" ]
then
    if [ `cat $FILE_DIR"/services/"$SERVICE_NAME"-active-env" | grep blue | wc -l` -ne 0 ]
    then
        setEnv "green"
    else
        setEnv "blue"
    fi
    exit;
fi