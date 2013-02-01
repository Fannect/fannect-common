mongoose = require "mongoose"
Schema = mongoose.Schema

stadiumSchema = mongoose.Schema
   _id: { type: Schema.Types.ObjectId, require: true, index: { unique: true } }
   stadium_key: { type: String, require: true }
   stadium_name: { type: String, require: true }
   coords: [ type: Number ]

module.exports = mongoose.model("Stadium", teamSchema)