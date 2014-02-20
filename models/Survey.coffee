mongoose = require "mongoose"
Schema = mongoose.Schema

surveySchema = new mongoose.Schema
   user_id: { type: Schema.Types.ObjectId, ref: "User", require: true }
   response: { type: String, require: true }
   additional: String
   
module.exports = mongoose.model("Survey", surveySchema)
