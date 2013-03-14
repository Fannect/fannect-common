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
      owner_profile_image_url: { type: String }
      owner_verified: { type: String }
      content: { type: String, require: true }
      team_id: { type: Schema.Types.ObjectId, ref: "Team", require: true }
      team_name: { type: String, require: true }
      voted_by: [{ type: Schema.Types.ObjectId, ref: "User" }]
      up_votes: { type: Number, default: 0, require: true }
      down_votes: { type: Number, default: 0, require: true }
      image_url: { type: String }
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
   rated_by: [{ type: Schema.Types.ObjectId, ref: "TeamProfile", index: {unique: true} }]
   last_reply_time: { type: Date, default: Date.now }
   views: { type: Number, default: 0, require: true }

module.exports = mongoose.model("Huddle", huddleSchema)




