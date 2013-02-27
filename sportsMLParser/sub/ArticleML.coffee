misc = require "../../utils/misc"

class ArticleML

   constructor: (articleDoc) ->
      @event_key = misc.reachIn(articleDoc, "sports-event.0.event-metadata.0.$.event-key")
      @preview = articleDoc["article"]?[0]?["nitf"]?[0]?["body"]?[0]?["body.content"]?[0]?["p"]

   isValid: () => return @preview? and @event_key?


module.exports = ArticleML