#!/usr/bin/env bash

# First run az login 
RESOURCE_GROUP='btsportshack'
PROCESSNAME='nytest'
IMAGE='msimecek/speech-pipeline:0.15-full'
languageModelId=''
DETAILSTATUS=$(az container show --resource-group $RESOURCE_GROUP --name $PROCESSNAME --query containers[].instanceView[].currentState.detailStatus[] --output tsv)
STATE=$(az container show --resource-group $RESOURCE_GROUP --name $PROCESSNAME --query containers[].instanceView[].currentState.state  --output tsv)
EVENTS=$(az container show --resource-group $RESOURCE_GROUP --name $PROCESSNAME --query containers[].instanceView[].events[-1].message  --output tsv)
echo 'State is' $STATE $DETAILSTATUS $EVENTS
#az container show --resource-group $RESOURCE_GROUP --name $PROCESSNAME --query 'containers[].environmentVariables[]'
az container show --resource-group $RESOURCE_GROUP --name $PROCESSNAME --query provisioningState
if [ "$STATE" = 'Terminated' ] 
then az container delete --resource-group $RESOURCE_GROUP --name $PROCESSNAME --yes
echo 'Deleted' $PROCESSNAME
fi
#az container show --resource-group $RESOURCE_GROUP --name $PROCESSNAME 
#az container logs --resource-group $RESOURCE_GROUP --name $PROCESSNAME -o table