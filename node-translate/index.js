var express = require('express')
var bodyParser = require('body-parser')
var request = require("request");
var rp = require('request-promise');
var config = require('./config')
var winston = require('winston');

var app = express()
app.set('view engine', 'pug')
app.use(bodyParser.urlencoded({
  extended: false
}))

winston.configure({
   transports: [
     new (winston.transports.File)({ filename: 'winston.log' })
   ]
 });

app.get('/nodetranslate', function(req, res) {
  res.render('index')
})

app.post('/nodetranslate/translate', function(req, res) {
  var options = {
    method: 'POST',
    url: 'https://translation.googleapis.com/language/translate/v2',
    qs: {
      key: config.api_key
    },
    headers: {
      'cache-control': 'no-cache',
      'content-type': 'application/json'
    },
    body: {
      format: 'text',
      source: 'en',
      target: req.body.language,
      q: [req.body.phrase]
    },
    json: true
  };

  rp(options)
    .then(function(translation) {
      var translation = translation.data.translations[0].translatedText;
      winston.info("Processed translation: " + translation);
      res.render('translate', {
        "translation": translation
      })
    })
    .catch(function(err) {
      winston.error(err);
      res.render('error')
    });

})

app.listen(3000, function() {
  console.log('Listening on port 3000')
})
