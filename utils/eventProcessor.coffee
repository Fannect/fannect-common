guessTheScore = require "./eventProcessor/guessTheScore"

proc = module.exports =
 
   attendance_streak: (ev, team, profile) ->
      _createEvent(ev, profile, { dedication: 4 })
      
   game_face: (ev, team, profile) ->
      _createEvent(ev, profile, { passion: 1 })
      
   guess_the_score: (ev, team, profile) ->
      distance = guessTheScore.calcDistance(ev.meta, team.schedule.postgame)
      earned = guessTheScore.calcScore(team.sport_key, distance)
      _createEvent(ev, profile, { knowledge: earned })
      
_createEvent = (ev, profile, points) ->
   profile.events.push
      type: ev.type
      points_earned: points
      meta: ev.meta
   profile.points.passion += points.passion if points.passion
   profile.points.dedication += points.dedication if points.dedication
   profile.points.knowledge += points.knowledge if points.knowledge
   profile.points.overall = profile.points.passion + profile.points.dedication + profile.points.knowledge


      


