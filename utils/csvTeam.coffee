fs = require "fs"
mongoose = require "mongoose"
csv = require "csv"
Team = require "../models/Team"
MongoError = require "../errors/MongoError"


csvTeam = module.exports = (file_path, done) -> 
   fs.readFile file_path, "utf8", (err, data) ->
      done(err) if err
      csvTeam.parse data, done

csvTeam.parse = (data, done) ->
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
            Team.update { team_key: line.team_key },
               team_key: line.team_key
               abbreviation: line.abbreviation
               nickname: line.nickname
               stadium:
                  name: line.stadium_name
                  coords: [ line.stadium_long, line.stadium_lat ]
               location_name: line.location_name
               sport_key: line.sport_key
               sport_name: line.sport_name
               league_key: line.league_key
               league_name: line.league_name
               conference_key: line.conference_key
               conference_name: line.conference_name
               is_college: line.college == "c"
            , { upsert: true, multi: true }
            , (err) ->
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