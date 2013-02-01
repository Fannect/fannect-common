mongoose = require "mongoose"
Schema = mongoose.Schema

stadiumSchema = new mongoose.Schema(
   {
      _id: { type: Schema.Types.ObjectId, require: true, index: { unique: true } }
      key: { type: String, require: true }
      name: { type: String, require: true }
      location: { type: String }
      coords: [ type: Number ]
   }, { collection: "stadiums" })

module.exports = mongoose.model("Stadium", stadiumSchema)