misc = require "../utils/misc"
ArticleML = require "./ArticleML"

class ScheduleML

   constructor: (doc) ->
      @articles = []

      for o in misc.reachIn(doc, "xts:sports-content-set.sports-content")
         article = new ArticleML(o)
         @articles.push(article) if article.isValid()

module.exports = ScheduleML