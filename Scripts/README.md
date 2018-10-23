# Scripts

A set of scripts to run and orchestrate our speech processing pipeline.

More scripts may be added as we see the need, but currently there are only two:

* process.ps1
* process-short.ps1 (As name suggests, it's a shortened version of process.ps1, without Speech CLI and model creation.)

## Usage

First create a working folder.

Then navigate to this folder and... run!

## process.ps1

Main orchestrator for the process. Requires a few settings, spend some time editing the beginning of the script.

* **sourceFileUrl** = URL of TXT file with links to source WAV/MP4 files. Each line should point to one file. Each file has to be accessible from the internet (good choice is SAS-protected Azure Storage Blob).
* **sourceTranscriptUrl** = URL of TXT file with transcription files corresponding with source WAV files. Each line should point to one file.
* **ffmpegUrl** = ffmpeg is not provided as part of this pipeline, so download it, ZIP it, upload somewhere and put URL in here.
* **speechCliUrl** = Speech Service CLI is not part of this repo, it can be found [TODO]. This parameter should contain link to the ZIP file.
* **speechKey** = Subscription key to your Speech Service endpoint.
* **speechRegion** = Region where your Speech Service endpoint is provisioned.
* **speechEndpoint** = GUID of published Speech Service endpoint (get from Speech portal).
* **languageModelId** = GUID of language model from Speech portal.

> Remark: The process will generate language model itself, but currently this functionality is not there.

Beware that depending on the amount of training data you provide the process can take several hours to complete. This may cause issues when using time-limited environments (such as Azure Pipelines provisioned machines).

