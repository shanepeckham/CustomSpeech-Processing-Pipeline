#!/usr/bin/env bash

# First run az login 
RESOURCE_GROUP=''
PROCESSNAME='nytest'
IMAGE='msimecek/speech-pipeline:0.15-full'
LANGUAGEMODELID=''
AUDIOFILESLIST=''
TRANSCRIPTFILESLIST=''
SPEECHENDPOINT=''
SPEECHKEY=''
SPEECHREGION='westeurope'
WEBHOOK='localhost'
SUBSCRIPTIONKEY=''
LANGUAGEMODELFILE=''
CHUNKLENGTH=''
TESTPERCENTAGE=''
REMOVESILENCE=''
SILENCEDURATION=''
SILENCETHRESHOLD=''
SUBMITURL='https://prod-15.westeurope.logic.azure.com:443/workflows//triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=-nbpZml-jrNj7BoqP85hh9E_bq3zr5QQb78OJH550_8'

HTTP=$(curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"username":"xyz","password":"xyz"}' \
  $SUBMITURL)

RES=$(az container create \
    --resource-group $RESOURCE_GROUP \
    --name $PROCESSNAME \
    --image $IMAGE \
    --restart-policy OnFailure \
    --environment-variables "languageModelId"=$LANGUAGEMODELID "processName"=$PROCESSNAME \
    "transcriptFilesList"=$TRANSCRIPTFILESLIST "audioFilesList"=$AUDIOFILESLIST \
    "speechEndpoint"=$SPEECHENDPOINT "speechKey"=$SPEECHKEY "speechRegion"=$SPEECHREGION \
    "webHook"=$WEBHOOK "subscriptionKey"=$SUBSCRIPTIONKEY "languageModelFile"=$LANGUAGEMODELFILE \
    "chunkLength"=$CHUNKLENGTH "testPercentage"=$TESTPERCENTAGE "removeSilence"=$REMOVESILENCE \
    "silenceDuration"=$SILENCEDURATION "silenceThreshold"=$SILENCETHRESHOLD --output tsv)

while true
do
    STATE=$(az container show --resource-group $RESOURCE_GROUP --name $PROCESSNAME --query provisioningState --output tsv)
    PROVSTATE=$(az container show --resource-group $RESOURCE_GROUP --name $PROCESSNAME --query containers[].instanceView[].currentState.detailStatus[] --output tsv)
    EVENTS=$(az container show --resource-group $RESOURCE_GROUP --name $PROCESSNAME --query containers[].instanceView[].events[-1].message)
    if [ $STATE = 'Succeeded' ] ; then
            break
    else 
        printf "ContainerGroup: "$STATE" Image: "$PROVSTATE\\r 
    fi
done
echo "Job submitted"



