mongoose = require "mongoose"
Schema = mongoose.Schema

stadiumSchema = new mongoose.Schema(
   {
      key: { type: String, require: true }
      name: { type: String, require: true }
      location: { type: String }
      coords: [ type: Number ]
   }, { collection: "stadiums" })

module.exports = mongoose.model("Stadium", stadiumSchema)