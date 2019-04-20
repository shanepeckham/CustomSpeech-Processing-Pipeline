import sys, os, argparse
import azure.cognitiveservices.speech as speechsdk

def main():
    global speech_config
    
    parser = argparse.ArgumentParser()
    parser.add_argument('-k', '--key', help='Speech service key.')
    parser.add_argument('-r', '--region', help='Speech service region.')
    parser.add_argument('-e', '--endpoint', help='Speech service endpoint.', default='')
    parser.add_argument('-i', '--input', help='Folder containing WAV files to process.')
    parser.add_argument('-o', '--output', help='Path to output TXT file.', default='out.txt')

    args, unknown = parser.parse_known_args()
    
    print(args)
    
    if args.key == None:
        print('Speech key needs to be specified. Use --key parameter.')
        return
    
    if args.region == None:
        print('Speech region needs to be specified. Use --region parameter.')
        return
    
    if args.input == None:
        print('Input folder needs to be specified. Use --input parameter.')
        return
    
    if not os.path.exists(args.input):
        print('Input folder doesn\'t exist.')
        return

    if os.path.exists(args.output):
        print('WARNING: Output file {} exists. Lines will be added to it.'.format(args.output))
    
    speech_config = speechsdk.SpeechConfig(subscription=args.key, region=args.region)
    
    source_dir = args.input
    files = os.listdir(source_dir)
    
    results = []
    for file in files:
        result = recognizeSpeech(source_dir + file)
        if result.text != "":
            result_line = "{}\t{}\t{}\n".format(result.offset, file, result.text)
            print(result_line)
            try:
                with open(args.output, 'a', encoding='utf-8') as of:
                    of.write(result_line)        
            except:
                print("Unable to write to the output file ", output)
                return
    
    print("Done. Output file {} written.".format(args.output))


def recognizeSpeech(filename):
    print("Recognizing: " + filename)
    
    audio_config = speechsdk.audio.AudioConfig(filename=filename)
    # Creates a recognizer with the given settings
    speech_recognizer = speechsdk.SpeechRecognizer(speech_config=speech_config, audio_config=audio_config)

    # Starts speech recognition, and returns after a single utterance is recognized. The end of a
    # single utterance is determined by listening for silence at the end or until a maximum of 15
    # seconds of audio is processed.  The task returns the recognition text as result. 
    # Note: Since recognize_once() returns only a single utterance, it is suitable only for single
    # shot recognition like command or query. 
    # For long-running multi-utterance recognition, use start_continuous_recognition() instead.
    result = speech_recognizer.recognize_once()

    # Checks result.
    if result.reason == speechsdk.ResultReason.RecognizedSpeech:
        return result
    elif result.reason == speechsdk.ResultReason.NoMatch:
        print("No speech could be recognized: {}".format(result.no_match_details))
    elif result.reason == speechsdk.ResultReason.Canceled:
        cancellation_details = result.cancellation_details
        print("Speech Recognition canceled: {}".format(cancellation_details.reason))
        if cancellation_details.reason == speechsdk.CancellationReason.Error:
            print("Error details: {}".format(cancellation_details.error_details))

if __name__ == "__main__":
    main()