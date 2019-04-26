# Language Model Generation

This process will generate a [language model](https://docs.microsoft.com/en-us/azure/cognitive-services/custom-speech-service/customspeech-how-to-topics/cognitive-services-custom-speech-create-language-model) by using [Spacy](https://spacy.io/) to extract [Named Entities](https://spacy.io/usage/linguistic-features#section-named-entities)

* To install run ```pip install -r requirements.txt``` .
* As we use [Spacy for industrial strength NLP](https://spacy.io/) the following model will need to be downloaded. Run ```python -m spacy download en_core_web_lg```

## The following parameters need to be populated. 

```TRANSCRIPTION_FILE = '/Users/shanepeckham/sources/video/File/language_model_files.txt'```
* This is a file containing the full transcript that you want to use to generate your language model
* Format: Text, UTF-8 BOM encoded.

```LANGUAGE_MODEL_FILE = '/Users/shanepeckham/sources/video/File/language_model_files_output.txt'```
* This is the language model file that will be generated as the output

## Usage

```bash
python3 GenerateLanguageModel -i transcript.txt -o lang.txt
```




