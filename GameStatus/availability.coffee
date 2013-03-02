availability = module.exports = 
   
   before: (info, status, next) ->
      if _hasSchedule(info)
         now = new Date() / 1
         gameTime = info.team.schedule.pregame.game_time / 1
         status.available = (not _in_progress(now, gameTime) and _within_hours(now, gameTime, 16))
         status.in_progress = _in_progress(now, gameTime)
      else
         status.available = false
         status.in_progress = false
      next()

   during: (info, status, next) ->
      if _hasSchedule(info)
         now = new Date() / 1
         gameTime = info.team.schedule.pregame.game_time / 1
         status.available = status.in_progress = _in_progress(now, gameTime)
      else
         status.available = false
         status.in_progress = false
      next()

   tillEnd: (info, status, next) ->
      if _hasSchedule(info)
         now = new Date() / 1
         gameTime = info.team.schedule.pregame.game_time / 1
         status.available = _within_hours(now, gameTime, 12)
         status.in_progress = _in_progress(now, gameTime)
      else
         status.available = false
         status.in_progress = false
      next()

   inSeason: (info, status, next) ->
      if _hasSchedule(info)
         now = new Date() / 1
         gameTime = info.team.schedule.pregame.game_time / 1
         status.available = true
         status.in_progress = _in_progress(now, gameTime)
      else
         status.available = false
         status.in_progress = false
      next()

_hasSchedule = (info, status, next) ->
   return info.team.schedule?.pregame?.game_time?

_within_hours = (now, gameTime, hours) ->
   return (now > gameTime - 1000 * 60 * 60 * hours)

_in_progress = (now, gameTime) ->
   return (now > gameTime)
