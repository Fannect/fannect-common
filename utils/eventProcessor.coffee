guessTheScore = require "./eventProcessor/guessTheScore"
attendanceStreak = require "./eventProcessor/attendanceStreak"
_ = require "underscore"

proc = module.exports =
 
   attendance_streak: (ev, team, profile) ->
      streak = _.where(profile.events, { type: "attendance_streak" }).length
      score = attendanceStreak.calcScore(streak, not team.schedule.postgame.is_home)

      profile.events.addToSet
         type: ev.type
         points_earned: { dedication: score }
         meta: ev.meta
         event_key: ev.event_key or team.schedule.postgame.event_key
      
   game_face: (ev, team, profile) ->
      profile.events.addToSet
         type: ev.type
         points_earned: { passion: 1 }
         meta: ev.meta
         event_key: ev.event_key or team.schedule.postgame.event_key
         
   guess_the_score: (ev, team, profile) ->
      if team.schedule.postgame.is_home
         ev.meta.actual_home_score = team.schedule.postgame.score
         ev.meta.actual_away_score = team.schedule.postgame.opponent_score
      else
         ev.meta.actual_home_score = team.schedule.postgame.opponent_score
         ev.meta.actual_away_score = team.schedule.postgame.score
      
      distance = guessTheScore.calcDistance(ev.meta, team.schedule.postgame)
      earned = guessTheScore.calcScore(team.sport_key, distance)
      
      profile.events.addToSet
         type: ev.type
         points_earned: { knowledge: earned }
         meta: ev.meta
         event_key: ev.event_key or team.schedule.postgame.event_key
