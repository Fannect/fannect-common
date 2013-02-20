gts = module.exports =
   calcDistance: (guess, actual) ->
      if actual.is_home
         return Math.abs(actual.score - guess.home_score) + Math.abs(actual.opponent_score - guess.away_score)
      else
         return Math.abs(actual.score - guess.away_score) + Math.abs(actual.opponent_score - guess.home_score)

   calcScore: (sport_key, distance) ->
      return sports_breakdown[sport_key](distance)

score_brackets = [ 8, 5, 4, 3, 2, 1 ]
sports_breakdown =
   # Basketball
   "15008000": (distance) ->
      if distance == 0 then return score_brackets[0]
      else if distance <= 5 then return score_brackets[1]
      else if distance <= 10 then return score_brackets[2]
      else if distance <= 15 then return score_brackets[3]
      else if distance <= 18 then return score_brackets[4]
      else return score_brackets[5]

   # Football
   "15003000": (distance) ->
      if distance == 0 then return score_brackets[0]
      else if distance <= 3 then return score_brackets[1]
      else if distance <= 7 then return score_brackets[2]
      else if distance <= 14 then return score_brackets[3]
      else if distance <= 18 then return score_brackets[4]
      else return score_brackets[5]
   
   # Soccer
   "15054000": (distance) ->
      if distance == 0 then return score_brackets[0]
      else if distance <= 2 then return score_brackets[2]
      else if distance <= 4 then return score_brackets[4]
      else return score_brackets[5]
   
   # Baseball
   "15007000": (distance) ->
      if distance == 0 then return score_brackets[0]
      else if distance <= 1 then return score_brackets[1]
      else if distance <= 2 then return score_brackets[2]
      else if distance <= 3 then return score_brackets[3]
      else if distance <= 4 then return score_brackets[4]
      else return score_brackets[5]
      
   # Ice hockey
   "15031000": (distance) ->
      if distance == 0 then return score_brackets[0]
      else if distance <= 2 then return score_brackets[2]
      else if distance <= 4 then return score_brackets[4]
      else return score_brackets[5]