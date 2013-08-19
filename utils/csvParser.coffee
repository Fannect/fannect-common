fs = require "fs"
mongoose = require "mongoose"
csv = require "csv"
Team = require "../models/Team"
MongoError = require "../errors/MongoError"
Stadium = require "../models/Stadium"

csvParser = module.exports = (file_path, done) -> 
   fs.readFile file_path, "utf8", (err, data) ->
      done(err) if err
      csvParser.parse data, done

csvParser.parseTeams = (data, done) ->
   headers = null
   count = 0
   running = 0
   errors = []
   hasContent = false

   csv()   
   .from(data)
   .on("record", (data, index) ->
      # set header row
      if index == 0
         headers = data
      else
         line = parseRowIntoObject(headers, data)

         if line.activate == "a"
            running++
            hasContent = true

            newTeam =
               team_key: line.team_key?.trim()
               mascot: line.mascot?.trim()
               location_name: line.location_name?.trim()
               full_name: line.full_name?.trim()
               aliases: line.aliases?.split(",") or []
               # stadium:
               #    name: line.stadium_name
               #    coords: [ line.stadium_long, line.stadium_lat ]
               sport_key: line.sport_key
               sport_name: line.sport_name
               league_key: line.league_key
               league_name: line.league_name
               conference_key: line.conference_key
               conference_name: line.conference_name
               is_college: line.college == "c"
            
            newTeam.aliases[i] = a.trim() for a, i in newTeam.aliases

            Team.createAndAttach newTeam, (err) ->
               errors.push(new MongoError(err)) if err
               count++
               if --running == 0
                  error = if errors.length > 0 then errors else null
                  done(error, count)
   )
   .on("end", () ->
      if running == 0 and not hasContent
         error = if errors.length > 0 then errors else null
         done(error, count)
   )

csvParser.parseStadiums = (data, done) ->
   headers = null
   count = 0
   running = 0
   errors = []

   csv()   
   .from(data)
   .on("record", (data, index) ->
      # set header row
      
      if index == 0
         headers = data
      else
         line = parseRowIntoObject(headers, data)

         if line.activate == "a"
            running++

            newStadium =
               team_key: line.team_key.trim()
               stadium_key: line.stadium_key.trim()
               name: line.name?.trim() or line.stadium_name?.trim()
               location: line.location?.trim() or line.stadium_location?.trim()
               lat: line.lat or line.stadium_lat
               lng: line.lng or line.stadium_long or line.stadium_lng

            Stadium
            .createAndAttach newStadium, (err) ->
               errors.push(new MongoError(err)) if err
               count++
               if --running == 0
                  error = if errors.length > 0 then errors else null
                  done(error, count)
   )
   .on("end", () ->
      if running == 0
         error = if errors.length > 0 then errors else null
         done(error, count)
   )

parseRowIntoObject = (headers, row) ->
   obj = {}
   for header, i in headers
      obj[header.trim()] = row[i]
   return obj