misc = require "../../utils/misc"

class EventMetaML

   constructor: (metaDoc) ->
      return @ unless metaDoc
      @event_key = misc.reachIn(metaDoc, "$.event-key")
      @event_status = misc.reachIn(metaDoc, "$.event-status")
      @duration = misc.reachIn(metaDoc, "$.duration")?.trim()
      @start_date_time = parseDate(misc.reachIn(metaDoc, "$.start-date-time"))
      @attendance = misc.reachIn(metaDoc, "site.0.site-stats.0.$.attendance")
      @stadium_key = misc.reachIn(metaDoc, "site.0.site-metadata.0.$.site-key")

      @docs = {}
      properties = misc.reachIn(metaDoc, "sports-property")
      
      if properties
         for prop in properties
            id = misc.reachIn(prop, "$.formal-name").replace(/-/g, "_")
            value = misc.reachIn(prop, "$.value")
            
            if id == "television_coverage" then @coverage = value
            else @docs[id] = value

   isValid: () => return @event_key?
   isPast: () => return @event_status == "post-event"
   isBefore: () => return @event_status == "pre-event"
   isPostponed: () => return @event_status == "postponed"

parseDate = (dateString) ->
   return dateString unless dateString
   y = dateString.substring(0,4)
   m = dateString.substring(4,6) - 1
   d = dateString.substring(6,8)
   h = dateString.substring(9,11)
   min = dateString.substring(11,13) 
   s = dateString.substring(13,15)
   zone = dateString.substring(16, 20)
   strDate = (new Date(y, m, d, h, min, s)).toString()
   return new Date(strDate.substring(0, strDate.indexOf("GMT") + 3) + "-" + zone)

module.exports = EventMetaML