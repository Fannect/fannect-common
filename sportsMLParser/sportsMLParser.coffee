xml2js = require "xml2js"
xmlParser = new xml2js.Parser()
PreviewML = require "./PreviewML"

module.exports = 
   preview: (xml, done) ->
      xmlParser.parseString xml, (err, doc) ->
         return done(err) if err
         done(null, new PreviewML(doc))

