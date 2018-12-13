#!/usr/bin/env bash

# First run az login 
RESOURCE_GROUP='speech'
PROCESSNAME='nytest'
IMAGE='msimecek/speech-pipeline:0.15-full'
LANGUAGEMODELID=''
AUDIOFILESLIST=''
TRANSCRIPTFILESLIST=''
WEBHOOK='localhost'
SUBSCRIPTIONKEY=''
LANGUAGEMODELFILE=''
CHUNKLENGTH=''
TESTPERCENTAGE=''
REMOVESILENCE=''
SILENCEDURATION=''
SILENCETHRESHOLD=''
SUBMITURL='https://prod-15.westeurope.logic.azure.com:443/workflows//triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=-nbpZml-'
SPEECHNAME=$(az cognitiveservices list -g $RESOURCE_GROUP --query "[?kind=='SpeechServices'].name" --output tsv) 
SPEAKERNAME=$(az cognitiveservices list -g $RESOURCE_GROUP --query "[?kind=='SpeakerRecognition'].name" --output tsv) 
SPEECHKEY=$(az cognitiveservices account keys list -g $RESOURCE_GROUP -n $SPEECHNAME --query "[key1]" --output tsv)
SPEAKERKEY=$(az cognitiveservices account keys list -g $RESOURCE_GROUP -n $SPEAKERNAME --query "[key1]" --output tsv)
SPEECHREGION=$(az cognitiveservices list -g $RESOURCE_GROUP --query "[?kind=='SpeechServices'].location" --output tsv) 
SPEAKERREGION=$(az cognitiveservices list -g $RESOURCE_GROUP --query "[?kind=='SpeakerRecognition'].location" --output tsv) 
SPEECHENDPOINT=$(az cognitiveservices list -g $RESOURCE_GROUP --query "[?kind=='SpeechServices'].endpoint" --output tsv)
SUBSCRIPTIONKEY=$(az account list --query "[?isDefault].id" --output tsv --all)
TENANT=$(az account list --query "[?isDefault].tenantId" --output tsv --all)

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



