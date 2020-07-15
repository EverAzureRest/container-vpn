#!/bin/bash
export SUBSCRIPTION="<mysubscriptionID>"
export KEYVAULTNAME="<mykeyvaultName>"
export SECRETNAME="vpnwebhook"
export DNSLABEL="myvpn"
export ACTION=$1
export REGION=$2

##Checking Requirements
if [ ! "$(command -v "az")" ]; then
    printf "Azure CLI is not installed or not available in your $PATH. \n
            Please https://aka.ms/az-cli for help installing"
    exit
elif [ ! "$(command -v "sslocal")" ]; then 
    printf "Shadowsocks client not installed or not available in your $PATH"
    exit
elif [ ! "$(command -v "curl")" ]; then
    printf "CURL not found or not available in your $PATH. \n
            Please install it using your distribution's package manager"
    exit
fi

if [ $ACTION == "start" ]; then

    SESSION_SUB=$(az account show --query "id" -o tsv)

    if [ $SESSION_SUB != $SUBSCRIPTION ]; then
        az account set -s $SUBSCRIPTION
    fi

    DATA="{\"action\":\"start\",\"region\":\"$REGION\",\"dnslabel\":\"$DNSLABEL\"}"
    URI=$(az keyvault secret show -n $SECRETNAME --vault-name $KEYVAULTNAME --query "value" -o tsv)

    SERVICEIP=$(curl -d $DATA $URI 2>/dev/null)

    PWD=$(az keyvault secret show -n vpnsecret --vault-name $KEYVAULTNAME --query "value" -o tsv)

    SOCKSCONF="{\"server\":\"$SERVICEIP\",\"server_port\":\"8388\",\"local_address\":\"127.0.0.1\",\"local_port\":\"1080\",\"password\":\"$PWD\",\"timeout\":\"600\",\"method\":\"aes-256-gcm\"}"

    echo $SOCKSCONF > ~/.config/socks-config.json

    #connecting Shadowsocks client
    sslocal -c ~/.config/socks-config.json &&
    printf "shadowsocks connected - please set your browser proxy to 127.0.0.1:1080"

elif [ $ACTION == "stop" ]; then

    DATA="{\"action\":\"stop\"}"
    URI=$(az keyvault secret show -n vpnwebhook --vault-name $KEYVAULTNAME --query "value" -o tsv)

    curl -d $DATA $URI
    printf "\n vpn container deleted"

    #Kill local ssocks pid if running
    PID=$(pgrep sslocal)
    if [ $PID ]; then
        kill $PID
        printf "\n sslocal terminated!"
    fi

    rm -f ~/.config/socks-config.json

    exit

fi