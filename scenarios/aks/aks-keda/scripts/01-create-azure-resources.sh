#!/bin/bash

id=$RANDOM
rg=adt-rg-$id
loc=westeurope
acr=adt0acr0$id
aks=adt-aks-$id
sb=adt-sb-$id

# Service Bus Authorization Rule Names
sb_rule_azfn_trigger="azfn-trigger"
sb_rule_azfn_binding="azfn-binding"
sb_rule_kedascaler="keda-scaler"
sb_rule_publisher="publisher-app"


#echo 'Creating resource group' $rg

# Create the resource group
az group create -n $rg -l $loc
echo

echo 'Creating Azure Container Registry' $acr

az acr create -g $rg -l $loc -n $acr --sku Basic
acrid=$(az acr show -n $acr --query "id" -o tsv)
echo "ACR created with name" $acr".azurecr.io"
echo

echo 'Creating Azure Service Bus Namespace' $sb

az servicebus namespace create -g $rg -l $loc -n $sb --sku Basic
echo
echo 'Creating Azure Service Bus Queue (inbound)'
az servicebus queue create -g $rg -n inbound --namespace-name $sb
echo
echo 'Creating Azure Service Bus Queue (outbound)'
az servicebus queue create -g $rg -n outbound --namespace-name $sb
echo
echo 'Creating Azure Service Bus Authorization Rules'
az servicebus queue authorization-rule create -g $rg \
    --namespace-name $sb \
    --queue-name inbound \
    --rights Listen Send Manage \
    -n $sb_rule_kedascaler
az servicebus queue authorization-rule create -g $rg \
    --namespace-name $sb \
    --queue-name inbound \
    --rights Listen \
    -n $sb_rule_azfn_trigger
az servicebus queue authorization-rule create -g $rg \
    --namespace-name $sb \
    --queue-name outbound \
    --rights Send \
    -n $sb_rule_azfn_binding
az servicebus queue authorization-rule create -g $rg \
    --namespace-name $sb \
    --queue-name inbound \
    --rights Send \
    -n $sb_rule_publisher
echo
echo 'Generated all authorization rules'
echo
echo 'Creating service principal for AKS'
akssp=$(az ad sp create-for-rbac --skip-assignment --name $aks -o json)
echo 'Created service principal'
aksspid=$(jq -r '.appId' <<< ${akssp})
akssppw=$(jq -r '.password' <<< ${akssp})
echo 'App ID is ' $aksspid
echo 'Password is ' $akssppw
