mongoose = require "mongoose"
Schema = mongoose.Schema

huddleSchema = new mongoose.Schema
   owner_id: { type: Schema.Types.ObjectId, ref: "TeamProfile", require: true, index: true }
   owner_user_id: { type: Schema.Types.ObjectId, ref: "User", require: true, index: true }
   owner_name: { type: String, require: true }
   owner_verified: { type: String }
   topic: { type: String, require: true }
   reply_count: { type: Number, require: true, default: 0 }
   replies: [
      owner_id: { type: Schema.Types.ObjectId, ref: "TeamProfile", require: true, index: true }
      owner_user_id: { type: Schema.Types.ObjectId, ref: "User", require: true, index: true }
      owner_name: { type: String, require: true }
      owner_verified: { type: String }
      content: { type: String, require: true }
      team_id: { type: Schema.Types.ObjectId, ref: "Team", require: true }
      team_name: { type: String, require: true }
   ]
   tags: [
      include_id: { type: Schema.Types.ObjectId }
      include_key: { type: String }
      type: { type: String, require: true }
      name: { type: String, require: true }
   ]
   team_id: { type: Schema.Types.ObjectId, ref: "Team", require: true, index: true }
   team_name: { type: String, require: true }
   rating: { type: Number, require: true, default: 0 }
   rating_count: { type: Number, require: true, default: 0 }
   last_comment_time: { type: Date, default: Date.now }

module.exports = mongoose.model("Huddle", huddleSchema)




