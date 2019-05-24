#!/bin/bash
export SUBSCRIPTIONID="95874f21-e6c8-4742-94f4-7698a4b50762"
export PARAMS="./azuredeploy.parameters.json"
export DEPLOYMENTFILE="./azuredeploy.json"
export RESOURCEGROUPNAME="azure-vpn"
export REGION="westus2"


if [ ! $(command -v "az") ]; then
    printf "Azure CLI is not installed or not available in your $PATH. \n
            Please https://aka.ms/az-cli for help installing"
    exit
fi

SESSION_SUB=$(az account show --query "id" -o tsv)

if [ "$SESSION_SUB" = /dev/null ]; then
    az account login
elif [ "$SESSION_SUB" != $SUBSCRIPTIONID ]; then
    az account set -s $SUBSCRIPTION
fi

if [ ! "$(az group show -n $RESOURCEGROUPNAME)"]; then
    az group create -n $RESOURCEGROUPNAME -l $REGION
fi

az group deployment create -n "vpn-deployment" -g $RESOURCEGROUPNAME --template-file $DEPLOYMENTFILE --parameters $PARAMS
