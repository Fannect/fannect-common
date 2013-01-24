mongoose = require "mongoose"
Email = mongoose.SchemaTypes.Email
Url = mongoose.SchemaTypes.Url
Schema = mongoose.Schema

userSchema = mongoose.Schema
   email: { type: Email, index: { unique: true }, lowercase: true, trim: true }
   password: { type: String, required: true }
   first_name: { type: String, required: true }
   last_name: { type: String, required: true }
   profile_image_url: { type: Url }
   created_on: { type: Date, require: true, default: Date.now }
   refresh_token: { type: String, required: true }
   facebook_token: String
   twitter_token: String
   friends: [{ type: Schema.Types.ObjectId, ref: "User" }]
   team_profiles: [{ type: Schema.Types.ObjectId, ref: "TeamProfile" }]
   role: String
   invites: [{ type: Schema.Types.ObjectId, ref: "User" }]
   reload_stream: String

module.exports = mongoose.model("User", userSchema)