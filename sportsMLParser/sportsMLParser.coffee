xml2js = require "xml2js"
xmlParser = new xml2js.Parser()
PreviewML = require "./PreviewML"
ScheduleML = require "./ScheduleML"
EventStatsML = require "./EventStatsML"

module.exports = 
   preview: (xml, done) -> parse(PreviewML, xml, done)
   schedule: (xml, done) -> parse(ScheduleML, xml, done)
   eventStats: (xml, done) -> parse(EventStatsML, xml, done)

parse = (type, xml, done) ->
   xml = xml.toString()
   return done() if isEmptyXml(xml)
   xmlParser.parseString xml, (err, doc) ->
      return done(err) if err
      return done() if isEmptyDoc(doc)
      done(null, new type(doc))

isEmptyXml = (xml) ->
   return xml?.indexOf("<xts:sports-content-set />") > -1
   
isEmptyDoc = (doc) ->
   return false if not doc?["xts:sports-content-set"]

   count = 0
   for k, v of doc?["xts:sports-content-set"]
      count++ if k != "$"
   
   return count == 0

