as = module.exports =
   calcScore: (games_prev_attended, is_away) ->
      baseScore = 10 + games_prev_attended
      baseScore *= 2 if is_away
      return baseScore