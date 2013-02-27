gf = module.exports =
   calcScore: (motivated_count = 0) ->
      return sports_breakdown(motivated_count) + 1

score_brackets = [ 5, 4, 3, 2, 1 ]
sports_breakdown = (count) ->
   if count >= 15 then return score_brackets[0]
   else if count >= 11 then return score_brackets[1]
   else if count >= 7 then return score_brackets[2]
   else if count >= 4 then return score_brackets[3]
   else if count >= 2 then return score_brackets[4]
   else return 0