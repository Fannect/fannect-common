InvalidArgumentError = require "../errors/InvalidArgumentError"

mongoose = require "mongoose"
Schema = mongoose.Schema

appSchema = new mongoose.Schema
   name: { type: String, require: true }
   client_id: { type: String, require: true, index: { unique: true } }
   client_secret: { type: String, require: true, index: true }
   role: { type: String, default: "manager" }

module.exports = mongoose.model("App", appSchema)