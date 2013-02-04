mongoose = require "mongoose"
Schema = mongoose.Schema
Stadium = require "./Stadium"

teamSchema = new mongoose.Schema
   team_key: { type: String, require: true }
   mascot: { type: String, require: true }
   location_name: { type: String, require: true }
   full_name: { type: String, require: true, index: { unique: true } }
   stadium: 
      stadium_id: { type: String, require: true }
      name: { type: String, require: true }
      location: { type: String, require: true }
      coords: [ Number ]
   sport_key: { type: String, require: true, index: true }
   sport_name: { type: String, require: true }
   league_key: { type: String, require: true, index: true }
   league_name: { type: String, require: true }
   conference_key: { type: String, require: true, index: true }
   conference_name: { type: String, require: true }
   has_processing: { type: Boolean, require: true, index: true, default: false }
   needs_processing: { type: Boolean, require: true, index: true, default: false }
   points: 
      overall: { type: Number, require: true, default: 0 }
      knowledge: { type: Number, require: true, default: 0 }
      passion: { type: Number, require: true, default: 0 }
      dedication: { type: Number, require: true, default: 0 }
   is_college: { type: Boolean, require: true }
   schedule:
      season: [
         {
            event_key: { type: String }
            game_time: { type: Date }
            opponent: { type: String }
            opponent_id: { type: Schema.Types.ObjectId, ref: "Team" }
            stadium_id: { type: String }
            stadium_name: { type: String }
            stadium_coords: [ type: Number ]
            stadium_location: { type: String }
            is_home: { type: Boolean }
            coverage: { type: String }
         }
      ]
      pregame: 
         event_key: { type: String }
         game_time: { type: Date, index: true }
         opponent: { type: String }
         opponent_id: { type: Schema.Types.ObjectId, ref: "Team" }
         stadium_id: { type: String }
         stadium_name: { type: String } 
         stadium_location: { type: String }
         stadium_coords: [ Number ]
         is_home: { type: Boolean }
         coverage: { type: String }
         preview: [{ type: String }]
         record: { type: String }
         opponent_record: { type: String }
      postgame: 
         event_key: { type: String }
         game_time: { type: Date }
         opponent: { type: String }
         opponent_id: { type: Schema.Types.ObjectId, ref: "Team" }
         is_home: { type: Boolean }
         score: { type: Number }
         opponent_score: { type: Number }
         won: { type: Boolean }
         attendance: { type: Number }

teamSchema.statics.createAndAttach = (newTeam, cb) ->
   context = @

   delete newTeam._id 

   key = newTeam.stadium_key or newTeam.stadium.key or newTeam.stadium.stadium_key

   if key
      Stadium.findOne { key: newTeam.stadium.stadium_key }, (err, stadium) ->
         return cb(err) if err

         # Remove stadium key that is not needed
         delete newTeam.stadium_key
         delete newTeam.stadium.key
         delete newTeam.stadium.stadium_key

         if stadium
            newTeam.stadium = {} unless newTeam.stadium
            newTeam.stadium.stadium_id = stadium._id
            newTeam.stadium.name = stadium.name
            newTeam.stadium.location = stadium.location
            newTeam.stadium.location = stadium.location
            newTeam.stadium.coords = stadium.coords
         
         context.update { team_key: newTeam.team_key }, newTeam, { upsert: true }, cb
   else      
      context.update { team_key: newTeam.team_key }, newTeam, { upsert: true }, cb


module.exports = mongoose.model("Team", teamSchema)




