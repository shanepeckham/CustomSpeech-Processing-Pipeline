#!/bin/sh
//@ts-nocheck
const commandLineArgs = require('command-line-args');
const speechService = require('ms-bing-speech-service');
const fs = require('fs');

const args = commandLineArgs([
  { name: "key", alias: "k", type: String },
  { name: "region", alias: "r", type: String, defaultValue: "westus" },
  { name: "endpoint", alias: "e", type: String, defaultValue: "" },
  { name: "input", alias: "i", type: String, defaultOption: true },
  { name: "output", alias: "o", type: String, defaultValue: "out.txt" },
  { name: "help", alias: "h", type: Boolean, defaultValue: false }
]);

if (args.key === undefined) {
  console.error("Provide Speech API key as the --key parameter.");
  args.help = true;
}

if (args.input === undefined) {
  console.error("Provide input directory as the --input parameter.");
  args.help = true;
}

if (args.help === true) {
  console.log("\nUsage:");
  console.log("node batcher.js [parameters]\n");
  console.log("Parameters:\n--key <Speech API key>\t(Required) Speech API key\n--region <Region>\tSpeech API region. Default: westus\n--endpoint <ID>\t\tSpeech endpoint ID\n--input <directory>\tDirectory with WAV files\n--output <filename>\tOutput file.");

  process.exit(1);
}

const sourceDir = args.input;
const destFile = args.output;

if (!fs.existsSync(sourceDir)) {
  console.error("Specified source directory doesn't exist.");
  process.exit(2);
}

// test write to see if target file is accessible
try {
  fs.writeFileSync(destFile, "");
}
catch(err) {
  console.error("Unable to write to destination file.");
  process.exit(2);
}

const files = fs.readdirSync(sourceDir);

console.log(files);

const recognizerOptions = {
  language: 'en-US',
  subscriptionKey: args.key,
  serviceUrl: `wss://${args.region}.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1?cid=${args.endpoint}`,
  issueTokenUrl: `https://${args.region}.api.cognitive.microsoft.com/sts/v1.0/issueToken`
};

const recognizer = new speechService(recognizerOptions);
var index = 0;
var results = [];

recognizer
  .start()
  .then(_ => {
    const emptyResult = {
      filename: "",
      text: "",
      offset: -1
    };

    var result = {}

    recognizer.on('recognition', (e) => {
      console.log(JSON.stringify(e));
      if (e.RecognitionStatus === 'Success') {
        if (result.filename === "") result.filename = files[index]; // first time setting file
        if (result.offset === -1) result.offset = e.Offset; // first time setting offset
        result.text += " " + e.DisplayText;
      }
    });
    
    recognizer.on('turn.end', (e) => {
      console.log(result);
      if (result.filename !== "") {
        results.push({ filename: result.filename, text: result.text, offset: result.offset });
        Object.assign(result, emptyResult); // reset
      }

      if (index < files.length - 1)
        next(recognizer, files[++index]);
      else
        done();
    });

    Object.assign(result, emptyResult);
    next(recognizer, files[index]); // start process with first file
  })
  .catch(console.error);
  
function next(recognizer, filename) {
  console.log('Processing file ' + filename);
  recognizer.sendFile(`${sourceDir}/${filename}`).catch(console.error);
}

function done() {
  console.log('Processing done.');
  var lines = "";
  results.forEach((val, index) => {
    if (val.text != "") // skip files with silence
      lines += `${val.offset}\t${val.filename}\t${val.text}\n`;
  });
  
  fs.writeFileSync(destFile, lines);
  console.log(`Output file ${destFile} written.`);

  process.exit(1);
}