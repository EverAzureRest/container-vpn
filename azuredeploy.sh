#!/bin/bash
export SUBSCRIPTIONID="mySubscriptionID"
export PARAMS="./azuredeploy.parameters.json"
export DEPLOYMENTFILE="./azuredeploy.json"
export DEPLOYMENTREGION="eastus2"



if [ ! "$(command -v "az")" ]; then
    printf "Azure CLI is not installed or not available in your $PATH. \n
            Please visit https://aka.ms/az-cli for help installing"
    exit
fi

SESSION_SUB=$(az account show --query "id" -o tsv)

if [ "$SESSION_SUB" = /dev/null ]; then
    printf "Azure Session not valid, initiating login"
    az account login
elif [ "$SESSION_SUB" != $SUBSCRIPTIONID ]; then
    az account set -s $SUBSCRIPTIONID
fi

az deployment create -n "vpnServicesDeployment" --template-file $DEPLOYMENTFILE --parameters $PARAMS -l $DEPLOYMENTREGION
