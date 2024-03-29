mongoose = require "mongoose"
Schema = mongoose.Schema
async = require "async"

stadiumSchema = new mongoose.Schema(
   {
      stadium_key: { type: String, require: true, index: { unique: true } }
      alias_keys: [{ type: String, index: { unique: true } }]
      name: { type: String, require: true }
      location: { type: String }
      coords: [ type: Number ]
   }, { collection: "stadiums" })

stadiumSchema.statics.createAndAttach = (newStadium, cb) ->
   Team = require "./Team"
   context = @

   team_key = newStadium.team_key
   newStadium.stadium_key = newStadium.stadium_key or newStadium.key

   if not (newStadium.lng or newStadium.lat)
      return cb(new Error(code: "no lat or lng", message: newStadium))

   newStadium.coords = [ newStadium.lng, newStadium.lat ]
   delete newStadium._id
   delete newStadium.team_key
   delete newStadium.lng
   delete newStadium.lat

   if team_key
      context.findOne { stadium_key: newStadium.stadium_key }, (err, stadium) ->
         return cb(err) if err
             
         if stadium
            stadium.name = newStadium.name
            stadium.stadium_key = newStadium.stadium_key
            stadium.location = newStadium.location
            stadium.coords = newStadium.coords
         else
            stadium = new Stadium(newStadium)
         
         async.parallel 
            team: (done) ->
               Team.update { team_key: team_key }
                  "stadium.stadium_id": stadium._id
                  "stadium.name": stadium.name
                  "stadium.location": stadium.location
                  "stadium.coords": stadium.coords
               , done
            stadium: (done) -> stadium.save(done)
         , cb
   else      
      context.update { stadium_key: newStadium.stadium_key }, newStadium, { upsert: true }, cb

Stadium = module.exports = mongoose.model("Stadium", stadiumSchema)