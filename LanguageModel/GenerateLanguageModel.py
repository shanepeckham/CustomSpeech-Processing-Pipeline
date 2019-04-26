import codecs
import spacy
import pandas as pd
import sys, getopt
nlp = spacy.load('en_core_web_lg')

def main(argv):

    # This is a file containing full transcript of the audio.
    TRANSCRIPTION_FILE = ''

    # This is the language model TXT file that will be generated as the output.
    LANGUAGE_MODEL_FILE = ''

    try:
        print("Getting args")
        opts, args = getopt.getopt(argv, "i:o:", ["TRANSCRIPTION_FILE=", "LANGUAGE_MODEL_FILE="])
        print(opts, args)
    except getopt.GetoptError:
        print("Arguments required for language model input transcriptions file -i, out language model file -o")
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-i':
            print("-i", arg)
            TRANSCRIPTION_FILE = arg
        elif opt == "-o":
            print("-o", arg)
            LANGUAGE_MODEL_FILE = arg

    entities = ['PERSON', 'GPE', 'NORP', 'ORG']

    with open(TRANSCRIPTION_FILE, "r", encoding='utf-8-sig') as transcribed_file:
        transcribed_text = transcribed_file.read().replace('\n', ' ')
        full = nlp(transcribed_text)
        ner_results = []

        for ent in full.ents:
            if ent.label_ in entities:
                ner_results.append({'Text': ent.text})


    with codecs.open(LANGUAGE_MODEL_FILE, "w", "utf-8-sig") as language_model:
        df_ner_results = pd.DataFrame.from_dict(ner_results)
        df_ner_results.drop_duplicates(subset='Text', keep='first', inplace=True)

        for row in df_ner_results.itertuples():
            language_model.write(row.Text + "\n")

    print("Done.")

if __name__ == "__main__":
    main(sys.argv[1:])
