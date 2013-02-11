mongoose = require "mongoose"
Schema = mongoose.Schema

huddleSchema = new mongoose.Schema
   title: { type: String, require: true }
   content: { type: String, require: true }
   owner_id: { type: Schema.Types.ObjectId, ref: "TeamProfile", require: true }
   owner_name: { type: String, require: true }
   owner_image_url: { type: String, require: true }
   comments: [
      owner_id: { type: Schema.Types.ObjectId, ref: "TeamProfile", require: true }
      owner_name: { type: String, require: true }
      owner_image_url: { type: String, require: true }
      content: { type: String, require: true }
   ]


module.exports = mongoose.model("Huddle", huddleSchema)




