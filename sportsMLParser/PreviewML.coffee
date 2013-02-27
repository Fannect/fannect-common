misc = require "../utils/misc"
ArticleML = require "./sub/ArticleML"

class PreviewML

   constructor: (doc) ->
      @articles = []

      for o in misc.reachIn(doc, "xts:sports-content-set.sports-content")
         article = new ArticleML(o)
         @articles.push(article) if article.isValid()


module.exports = PreviewML