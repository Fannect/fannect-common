mongoose = require "mongoose"

teamProfileSchema = mongoose.Schema
   # email: { type: String, lowercase: true, trim: true }
   # password: String
   # first_name: String
   # last_name: String
   # profile_image_url: String
   # created_on: { type: Date, default: Date.now }
   # refresh_token: String

module.exports = mongoose.model("TeamProfile", teamProfileSchema)
