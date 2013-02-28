guessTheScore = require "./eventProcessor/guessTheScore"
attendanceStreak = require "./eventProcessor/attendanceStreak"
gameFace = require "./eventProcessor/gameFace"
_ = require "underscore"
mongoose = require "mongoose"

proc = module.exports =
 
   attendance_streak: (ev, team, profile) ->
      streak = _.where(profile.events, { type: "attendance_streak" }).length
      score = attendanceStreak.calcScore(streak, not team.schedule.postgame.is_home)
      
      ev.meta.team_name = team.full_name
      ev.meta.opponent = team.schedule.postgame.opponent
      ev.meta.is_home = team.schedule.postgame.score
      ev.meta.stadium_name = team.schedule.postgame.stadium_name
      ev.meta.stadium_location = team.schedule.postgame.stadium_location

      profile.events.addToSet
         _id: generateNewId(ev._id)
         type: ev.type
         points_earned: { dedication: score }
         meta: ev.meta
         event_key: ev.event_key or team.schedule.postgame.event_key
      
   game_face: (ev, team, profile) ->
      ev.meta.team_name = team.full_name
      ev.meta.opponent = team.schedule.postgame.opponent
      
      earned = gameFace.calcScore(ev.meta?.motivated_count)
      
      profile.events.addToSet
         _id: generateNewId(ev._id)
         type: ev.type
         points_earned: { passion: earned }
         meta: ev.meta
         event_key: ev.event_key or team.schedule.postgame.event_key
         
   guess_the_score: (ev, team, profile) ->
      ev.meta.team_name = team.full_name
      ev.meta.opponent = team.schedule.postgame.opponent
      if ev.meta.is_home = team.schedule.postgame.is_home
         ev.meta.actual_home_score = team.schedule.postgame.score
         ev.meta.actual_away_score = team.schedule.postgame.opponent_score
      else
         ev.meta.actual_home_score = team.schedule.postgame.opponent_score
         ev.meta.actual_away_score = team.schedule.postgame.score
      
      distance = guessTheScore.calcDistance(ev.meta, team.schedule.postgame)
      earned = guessTheScore.calcScore(team.sport_key, distance)
      
      profile.events.addToSet
         _id: generateNewId(ev._id)
         type: ev.type
         points_earned: { knowledge: earned }
         meta: ev.meta
         event_key: ev.event_key or team.schedule.postgame.event_key

generateNewId = (old_id) ->
   new_id = new mongoose.Types.ObjectId
   return old_id.toString().substring(0,8) + new_id.toString().substring(8)
