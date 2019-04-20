# Batch transcriber (aka Batcher)

This script takes all files from a specified folder and sends them for transcription to the Speech Service.

## Usage

Install dependencies:

```bash
pip3 install -r ./requirements.txt
```

Run:

```bash
python3 ./batcher.py -i <path to folder with WAV files> -k <Speech API key> -r <Speech API region> -e <Speech API endpoint> -o <output TXT file>
```

`-k`, `-r` and `-i` are required.

|Parameter  |Default  |
|---------|---------|
|--key (-k)     | *Required*         |
|--region (-r)  | *Required*        |
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