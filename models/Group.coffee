InvalidArgumentError = require "../errors/InvalidArgumentError"

mongoose = require "mongoose"
Schema = mongoose.Schema

groupSchema = new mongoose.Schema
   name: { type: String, require: true }
   team_id: { type: Schema.Types.ObjectId, ref: "Team", require: true, index: true }
   team_key: { type: String, require: true }
   team_name: { type: String, require: true }
   sport_name: { type: String, requie: true }
   sport_key: { type: String, requie: true }
   points: 
      overall: { type: Number, require: true, default: 0 }
      knowledge: { type: Number, require: true, default: 0 }
      passion: { type: Number, require: true, default: 0 }
      dedication: { type: Number, require: true, default: 0 }
   members: { type: Number }
   tags: [{ type: String }]

groupSchema.statics.createAndAttach = (group, cb) ->
   context = @
   Team = require "./Team"
   
   if group.team_id
      query = { _id: group.team_id }
   else if group.team_key
      query = { team_key: group.team_key }
   else
      return cb(new InvalidArgumentError("Required: team_id or team_key"))

   if typeof group.tags == "string"
      group.tags = group.tags.split(",")
      group.tags[i] = tag.trim() for tag, i in group.tags

   Team
   .findOne(query)
   .select("name team_key team_id sport_name sport_key")
   .exec (err, team) ->
      return cb(new InvalidArgumentError("Invalid: team_id or team_key")) unless team
      group.team_id = team._id
      group.team_key = team.team_key
      group.team_name = team.team_name
      group.sport_key = team.sport_key
      group.sport_name = team.sport_name
      context.create(group, cb)

module.exports = mongoose.model("Group", groupSchema)




