# Batch transcriber (aka Batcher)

This script takes all files from a specified folder and sends them for transcription to the Speech Service.

## Usage

```bash
npm install
node batcher.js --key <Speech API key> --region <Speech API region> --endpoint <Endpoint ID> --input <path to folder with WAV files> --output <path to final TXT>
```

`--key` and `--input` are required.

|Parameter  |Default  |
|---------|---------|
|--key (-k)     | *Required*         |
|--region (-r)  | "westus"        |
|--endpoint (-e)| ""        |
|--input (-i)   | *Required*        |
|--output (-o)  | "out.txt"        |

## Output

Output TXT file contains list of files and corresponding transcripts - one line per file, separated by TABs.

```
offset<tab>filename1.wav<tab>Transcript as whole sentences.<eol>
```

## Remarks

If the Speech API detects silence in the audio file, it's not included in output.

Required audio format is described in [Speech Service documentation](https://docs.microsoft.com/en-us/azure/cognitive-services/speech-service/how-to-customize-acoustic-models#prepare-the-data).