mongoose = require "mongoose"
Schema = mongoose.Schema

teamSchema = mongoose.Schema
   _id: { type: Schema.Types.ObjectId, require: true, index: { unique: true } }
   team_key: { type: String, require: true }
   abbreviation: { type: String, require: true }
   nickname: { type: String, require: true }
   stadium: 
      name: { type: String, require: true }
      coords: [ type: Number ]
   location_name: { type: String, require: true }
   sport_key: { type: String, require: true, index: true }
   sport_name: { type: String, require: true }
   league_key: { type: String, require: true, index: true }
   league_name: { type: String, require: true }
   conference_key: { type: String, require: true, index: true }
   conference_name: { type: String, require: true }
   next_game: { type: Date, index: true }
   has_processing: { type: Boolean, require: true, index: true, default: false }
   needs_processing: { type: Boolean, require: true, index: true, default: false }
   points: 
      overall: { type: Number, require: true, default: 0 }
      knowledge: { type: Number, require: true, default: 0 }
      passion: { type: Number, require: true, default: 0 }
      dedication: { type: Number, require: true, default: 0 }
   is_college: { type: Boolean, require: true }

module.exports = mongoose.model("Team", teamSchema)