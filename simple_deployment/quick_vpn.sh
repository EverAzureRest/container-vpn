#!/bin/bash 

export SUBSCRIPTION="my Subcription ID"
export REGION=$3

USAGE="Usage: quickdeploy.sh -p <password> <region> OR quickdeploy.sh -stop"

if [ "$1" = -stop ]; then
    ACTION="stop"

elif [ "$1" = -p ]; then
    SECRET="$2"
    if [ ! $SECRET ]; then
        printf "You didn't enter a password"
        printf $USAGE
        exit
    elif [ ! $REGION ]; then
        printf "\n Looks like you didn't specify a region"
        printf $USAGE
        exit
    fi
elif [ "$1" = $null ]; then
    echo $USAGE
    exit
fi

if [ ! "$(command -v "az")" ]; then
    printf "Azure CLI is not installed or not available in your $PATH. \n
            Please https://aka.ms/az-cli for help installing"
    exit
elif [ ! "$(command -v "sslocal")" ]; then 
    SSCHECK=1
    printf "Shadowsocks client not installed or not available in your $PATH \n
            will not automatically try to connect the Proxy"
fi

SESSION_SUB=$(az account show --query "id" -o tsv)

if [ $SESSION_SUB != $SUBSCRIPTION ]; then
    az account set -s $SUBSCRIPTION
fi

if [ $ACTION ]; then
    az group delete -n shadowsocks -y 
    rm -f ~/.config/socks-config.json
    if [ "$SSCHECK" != 1 ]; then
    PID=$(pgrep sslocal)
        if [ $PID ]; then
            kill $PID
            printf "\n sslocal terminated!"
        fi
    fi
    exit
fi

printf "\n Creating a Resource Group named shadowsocks"

if [ ! $(az group show -n shadowsocks 2> /dev/null) ]; then
    az group create -n shadowsocks -l $REGION
fi

printf "\n Building shadowsocks server"

az container create -n shadowsocks -g shadowsocks -l $REGION --image oddrationale/docker-shadowsocks --command-line "/usr/local/bin/ssserver -k $SECRET -m aes-256-cfb" --ports 8388 --ip-address public

SERVICEIP=$(az container show -n shadowsocks -g shadowsocks --query "ipAddress.ip" -o tsv)

if [ "$SSCHECK" != 1 ]; then
    printf "\nConnecting to VPN... \n"
    SOCKSCONF="{\"server\":\"$SERVICEIP\",\"server_port\":\"8388\",\"local_address\":\"127.0.0.1\",\"local_port\":\"1080\",\"password\":\"$SECRET\",\"timeout\":\"600\",\"method\":\"aes-256-cfb\"}"
    echo $SOCKSCONF > ~/.config/socks-config.json
    sslocal -c ~/.config/socks-config.json &
    exit

else
    printf "Connect shadowsocks client to $SERVICEIP"
fi

exit