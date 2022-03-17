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

echo
echo 'Creating service principal for AKS'
akssp=$(az ad sp create-for-rbac --skip-assignment --name $aks -o json)
echo 'Created service principal'
aksspid=$(jq -r '.appId' <<< ${akssp})
akssppw=$(jq -r '.password' <<< ${akssp})
echo 'App ID is' $aksspid
echo 'Password is' $akssppw

# Because it all happens to fast and fails
echo "Wait 30..."
sleep 30
echo "Wait 30 DONE"

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

acrid=$(az acr show -n $acr --query "id" -o tsv)
echo 'Creating role assignment for ACR'
az role assignment create --assignee $aksspid --scope $acrid --role acrpull

echo 'Creating Azure Kubernetes Service' $aks
az aks create -g $rg \
    -l $loc \
    -n $aks \
    --node-count 1 \
    --service-principal $aksspid \
    --client-secret $akssppw \
    --generate-ssh-keys
echo
echo 'Attaching ACR to AKS'
az aks update -g $rg -n $aks --attach-acr $acrid
echo 'Downloading AKS credentials'
az aks get-credentials -g $rg -n $aks
echo
echo 'Switching kubectl context to' $aks
kubectl config set-context $aks
echo
echo 'creating keda namespace in kubernetes'
kubectl create namespace keda
echo
echo 'Installing KEDA using Helm 3'
helm install keda kedacore/keda --namespace keda

echo 'Creating Kubernetes namespace'
kubectl create namespace tt
echo

# Get the connection string from Azure Service Bus
KEDA_SCALER_CONNECTION_STRING=$(az servicebus queue authorization-rule keys list \
    -g $rg \
    --namespace-name $sb \
    --queue-name inbound \
    -n $sb_rule_kedascaler \
    --query "primaryConnectionString" \
    -o tsv)

echo 'Creating Kubernetes secret for KEDA scaler:'
kubectl create secret generic tt-keda-auth \
    --from-literal KedaScaler=$KEDA_SCALER_CONNECTION_STRING \
    --namespace tt

echo 'Creating Kubernetes secret for Azure Functions:'
AZFN_TRIGGER_CONNECTION_STRING=$(az servicebus queue authorization-rule keys list \
    -g $rg \
    --namespace-name $sb \
    --queue-name inbound \
    -n $sb_rule_azfn_trigger \
    --query "primaryConnectionString" \
    -o tsv)

AZFN_OUTPUT_BINDING_CONNECTION_STRING=$(az servicebus queue authorization-rule keys list \
    -g $rg \
    --namespace-name $sb \
    --queue-name outbound \
    -n $sb_rule_azfn_binding \
    --query "primaryConnectionString" \
    -o tsv)

# create the secret
kubectl create secret generic tt-func-auth \
    --from-literal InboundQueue=${AZFN_TRIGGER_CONNECTION_STRING%EntityPath*} \
    --from-literal OutboundQueue=${AZFN_OUTPUT_BINDING_CONNECTION_STRING%EntityPath*} \
    --namespace tt

echo
echo 'DONE'
