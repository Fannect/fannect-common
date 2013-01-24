mongoose = require "mongoose"
Url = mongoose.SchemaTypes.Url
Schema = mongoose.Schema

teamProfileSchema = mongoose.Schema
   user_id: { type: Schema.Types.ObjectId, ref: "User", require: true, index: true }
   name: { type: String, require: true, index: true }
   team_id: { type: Schema.Types.ObjectId, ref: "Team", require: true, index: true }
   team_name: { type: String, require: true }
   points:
      overall: { type: Number, require: true, default: 0 }
      knowledge: { type: Number, require: true, default: 0 }
      passion: { type: Number, require: true, default: 0 }
      dedication: { type: Number, require: true, default: 0 }
   friends: [{ type: Schema.Types.ObjectId, index: true }]
   events: [
      type: { type: String, require: true, }
      timestamp: { type: Date, default: Date.now }
      points_earned: 
         overall: { type: Number, require: true, default: 0 }
         knowledge: { type: Number, require: true, default: 0 }
         passion: { type: Number, require: true, default: 0 }
         dedication: { type: Number, require: true, default: 0 }
      meta: Schema.Types.Mixed
   ]
   team_image_url: Url
   profile_image_url: Url
   has_processing: { type: Boolean, require: true, index: true, default: false }
   waiting_events: [
      type: { type: String, require: true, }
      timestamp: { type: Date, require: true, default: Date.now }
      meta: Schema.Types.Mixed   
      is_processing: { type: Boolean, require: true, default: false }
   ]
   trash_talk: [
      _id: { type: Schema.Types.ObjectId, require: true }
      text: { type: String, require: true }
      timestamp: { type: Date, require: true, default: Date.now }
   ]

module.exports = mongoose.model("TeamProfile", teamProfileSchema)