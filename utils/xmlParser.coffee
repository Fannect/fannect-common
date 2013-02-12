xml2js = require "xml2js"
xmlParser = new xml2js.Parser()

parser = module.exports = 
   parse: (xml, done) ->
      xmlParser.parseString xml, done

   isEmpty: (doc) ->
      return false if not doc?["xts:sports-content-set"]

      count = 0
      for k, v of doc?["xts:sports-content-set"]
         count++ if k != "$"
      
      return count == 0

   schedule:
      parseGames: (doc) -> doc?["xts:sports-content-set"]?["sports-content"]?[0]?["schedule"]?[0]?["sports-event"]
      _parseMeta: (game) -> game?["event-metadata"]?[0]
      _parseCoverage: (meta) -> meta?["sports-property"]?[0]?["$"]?["value"]
      _parseStadiumKey: (meta) -> meta?["site"]?[0]?["site-metadata"]?[0]?["$"]?["site-key"]               
      _parseStartTime: (meta) -> parser.schedule._parseDate(meta["$"]?["start-date-time"])
      _parseStatus: (meta) -> meta["$"]?["event-status"]
      _parseTeamKey: (team) -> team["team-metadata"]?[0]?["$"]?["team-key"]
      _parseAwayTeamKey: (teams) -> parser.schedule._parseTeamKey(teams[0])
      _parseHomeTeamKey: (teams) -> parser.schedule._parseTeamKey(teams[1])
      _parseEventKey: (meta) -> meta["$"]?["event-key"]
      _parseTeams: (game) -> game["team"]
      _parseDate: (dateString) ->
         y = dateString.substring(0,4)
         m = dateString.substring(4,6) - 1
         d = dateString.substring(6,8)
         h = dateString.substring(9,11)
         min = dateString.substring(11,13) 
         s = dateString.substring(13,15)
         zone = dateString.substring(16, 20)
         strDate = (new Date(y, m, d, h, min, s)).toString()
         return new Date(strDate.substring(0, strDate.indexOf("GMT") + 3) + "-" + zone)

      parseGameToJson: (game) ->
         meta = parser.schedule._parseMeta(game)
         teams = parser.schedule._parseTeams(game)
         parser.schedule._parseEventKey(meta)
         return {
            event_key: parser.schedule._parseEventKey(meta)
            game_time: parser.schedule._parseStartTime(meta)
            away_key: parser.schedule._parseAwayTeamKey(teams)
            home_key: parser.schedule._parseHomeTeamKey(teams)
            stadium_key: parser.schedule._parseStadiumKey(meta)
            coverage: parser.schedule._parseCoverage(meta)
            is_past: parser.schedule._parseStatus(meta) == "post-event"
         }

   preview:
      parseArticles: (doc) -> doc?["xts:sports-content-set"]?["sports-content"]
      _parseEventKey: (article) -> article?["sports-event"]?[0]?["event-metadata"]?[0]?["$"]?["event-key"]
      _parsePreview: (article) -> article?["article"]?[0]?["nitf"]?[0]?["body"]?[0]?["body.content"]?[0]?["p"]

      parseArticleToJson: (article) ->
         return {
            event_key: parser.preview._parseEventKey(article)
            preview: parser.preview._parsePreview(article)
         }

   boxScores:

      _parseAlignment: (team) -> team?["team-metadata"]?[0]?["$"]["alignment"]
      _parseTeamKey: (team) -> team?["team-metadata"]?[0]?["$"]["team-key"]
      _parseEventKey: (sportsEvent) -> sportsEvent?[0]?["event-metadata"]?[0]["$"]?["event-key"]
      
      parseEvents: (doc) ->
         doc?["xts:sports-content-set"]?["sports-content"]?[0]["sports-event"]

      parseBoxScoreToJson: (sportsEvent) ->
         teamStats = sportsEvent?["team"]?[0]?["team-stats"]?[0]?["$"]
         
         return {} unless teams = sportsEvent?["team"]
         
         results = 
            is_past: sportsEvent?["event-metadata"]?[0]?["$"]?["event-status"] == "post-event"
            attendance: sportsEvent?["event-metadata"]?[0]?["site"]?[0]?["site-stats"]?[0]?["$"]?["attendance"]
            event_key: sportsEvent?["event-metadata"]?[0]["$"]?["event-key"]

         for team in teams         
            alignment = parser.boxScores._parseAlignment(team)
            teamStats = team?["team-stats"]?[0]?["$"]
            results[alignment] =
               team_key: parser.boxScores._parseTeamKey(team)
               score: parseInt(teamStats?["score"])
               won: teamStats?["event-outcome"] != "loss"

         return results


