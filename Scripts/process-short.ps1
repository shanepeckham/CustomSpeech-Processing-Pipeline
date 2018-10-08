#
# Before running this script, change initial variables to reflect your environment.
# Run this script from an empty working folder - it will download and produce many files.
#

# TXT file with links to source WAV files. One line = one file.
$sourceFileUrl = "https://<url>/<file>.txt"
#$sourceFileUrl = $env:sourceFileUrl

# TXT file with links to transcription files corresponding to WAV files. One file = complete trascript of the whole WAV file (no timestamps, only text).
$sourceTranscriptUrl = "https://<url>/<file>.txt"
#$sourceTranscriptUrl = $env:sourceTranscriptUrl

# TXT file with language model. Not used in this script.
$sourceLanguageUrl = "https://<url>/<file>.txt"
#$sourceLanguageUrl = $env:sourceLanguageUrl

# ZIP file containing FFmpeg tool (expects ffmpeg.exe in root).
$ffmpegUrl = "https://<url>/ffmpeg.zip"
#$ffmpegUrl = $env:ffmpegUrl

# Key to Speech API (get from Azure portal or from Speech portal).
$speechKey = ""
#$speechKey = $env:speechKey

# Region where the Speech API is deployed (get from Azure portal or from Speech portal).
$speechRegion = "northeurope"
#$speechRegion = $env:speechRegion

# GUID of speech endpoint to run the initial transcription against. Better endpoint (e.g. with language model, pre-trained etc.) = better results. Get from Speech portal (CRIS.ai).
$speechEndpoint = ""
#$speechEndpoint = $env:speechEndpoint

# How will datasets, models, tests and endpoints be called in Speech Service.
$processName = ""
#$processName = $env:processName

#-----------------------------------------------------

$rootDir = (Get-Item -Path ".\" -Verbose).FullName;

# Test tools.
pip --version
python --version
npm --version
node --version

# Download ffmpeg as ZIP
Invoke-WebRequest $ffmpegUrl -OutFile .\ffmpeg.zip

# Unpack ffmpeg
Add-Type -Assembly System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory("$rootDir\ffmpeg.zip", "$rootDir\ffmpeg")

# Parse source files - each line is expected to be file URL
$sourceWavs = (Invoke-WebRequest $sourceFileUrl | Select-Object -ExpandProperty Content) -Split '\n'
$sourceTxts = (Invoke-WebRequest $sourceTranscriptUrl | Select-Object -ExpandProperty Content) -Split '\n'

New-Item .\SourceWavs -ItemType Directory -Force
#$sourceWavs | % {$i = 0} { Invoke-WebRequest $_ -OutFile .\SourceWavs\$i.wav; $i++ } # only different syntax of downloading every file

for ($i = 0; $i -lt $sourceWavs.Count; $i++) {
    # Download WAV file locally to prevent Storage transfer errors    
    Invoke-WebRequest $sourceWavs[$i] -OutFile .\SourceWavs\$i.wav
    
    # Run FFmpeg on each source file - chunk & convert
    New-Item .\Chunks-$i -ItemType Directory -Force
    .\ffmpeg\ffmpeg.exe -i .\SourceWavs\$i.wav -acodec pcm_s16le -vn -ar 16000  -f segment -segment_time 10 -ac 1 .\Chunks-$i\$i-part%03d.wav

    # Download full transcript
    Invoke-WebRequest $sourceTxts[$i] -OutFile "$rootDir\source-transcript-$i.txt"
}

# Get Batcher script
# install dependencies
git clone https://github.com/shanepeckham/CustomSpeech-Processing-Pipeline.git
cd .\CustomSpeech-Processing-Pipeline\Batcher
npm install

#TODO: if language data available, create baseline endpoint with language model first

# Run Batcher, if there's no machine-transcript present
# - machine transcript creation is time consuming, this allows to skip it if the process needs to be run again
for ($i = 0; $i -lt $sourceWavs.Count; $i++) {
    If (!(Test-Path "$rootDir\machine-transcript-$i.txt")) {
        node batcher.js --key $speechKey --region $speechRegion --endpoint $speechEndpoint  --input "$rootDir\Chunks-$i" --output "$rootDir\machine-transcript-$i.txt"
    }
}

# Run Transcriber
cd "$rootDir\CustomSpeech-Processing-Pipeline\Transcriber"
pip install -r requirements.txt
python -m spacy download en_core_web_lg

New-Item "$rootDir\Cleaned" -ItemType Directory -Force
New-Item "$rootDir\Compiled" -ItemType Directory -Force

$cleaned = @()
for ($i = 0; $i -lt $sourceWavs.Count; $i++) 
{
    # TODO: exclude empty machine transcripts from the loop
    
    # python transcriber.py -t '11_WTA_ROM_STEPvGARC_2018/11_WTA_ROM_STEPvGARC_2018.txt' -a '11_WTA_ROM_STEPvGARC_2018/11_WTA_ROM_STEPvGARC_OFFSET.txt' -g '11_WTA_ROM_STEPvGARC_TRANSCRIPT_testfunc2.txt'
    # -t = TRANSCRIBED_FILE = official full transcript
    # -a = audio processed file = output from batcher
    # -g = output file
    python transcriber.py -t "$rootDir\source-transcript-$i.txt" -a "$rootDir\machine-transcript-$i.txt" -g "$rootDir\matched-transcript-$i.txt"

    # Cleanup (remove NEEDS MANUAL CHECK and files which don't have transcript)
    $present = Get-Content -Path "$rootDir\matched-transcript-$i.txt" | Where-Object {$_ -notlike "*NEEDS MANUAL CHECK*"}
    
    ForEach ($line in $present) {
        $filename = ($line -split '\t')[0]
        Copy-Item -Path "$rootDir\Chunks-$i\$filename" -Destination "$rootDir\Cleaned\$filename" # copy all to one place
    }

    $cleaned += $present
}

Write-Host "Transcribe done. Writing cleaned-transcript.txt"
$cleaned | Out-File "$rootDir\cleaned-transcript.txt"

# Next steps:
# - use 'Cleaned' folder and 'cleaned-transcript.txt' file to create training and test datasets
# - upload datasets to Speech Service
# - create model & create endpoint
# - (optional) run process againist this new endpoint - results should be better