mongoose = require "mongoose"
Schema = mongoose.Schema

configSchema = new mongoose.Schema(
   {
      games:
         photo_challenge:
            active_title: { type: String, require: true }
            active_description: { type: String, require: true }
            active_index: { type: Number, require: true, default: 0 }
            queued_challenges: [{
               title: { type: String, require: true }
               description: { type: String, require: true }
            }]
   }
, { collection: "config" })

configSchema.statics.nextPhotoChallenge = (cb) ->
   Config.findOne {}, (err, configuration) -> 
      return cb(err) if err
      return cb(new Error("Configuration has not be set")) unless configuration
      config = configuration.games.photo_challenge
      config.active_index += 1
      config.active_index = 0 if config.active_index >= config.queued_challenges.length
      config.active_title = config.queued_challenges[config.active_index].title
      config.active_description = config.queued_challenges[config.active_index].description
      configuration.save(cb)

configSchema.statics.getPhotoChallenge = (cb) ->
   Config.findOne {}, (err, configuration) ->
      return cb(err) if err
      return cb(new Error("Configuration has not be set")) unless configuration
      cb null, 
         title: configuration.games.photo_challenge.active_title
         description: configuration.games.photo_challenge.active_description

Config = module.exports = mongoose.model("Config", configSchema)