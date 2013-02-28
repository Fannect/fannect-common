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
   xmlParser.parseString xml, (err, doc) ->
      return done(err) if err
      return done() if isEmpty(doc)
      done(null, new type(doc))

isEmpty = (doc) ->
   return false if not doc?["xts:sports-content-set"]

   count = 0
   for k, v of doc?["xts:sports-content-set"]
      count++ if k != "$"
   
   return count == 0

