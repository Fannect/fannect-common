photos = module.exports =
  
   getTypes: () -> 
      return [ "gameday_pics", "spirit_wear", "photo_challenge", "picture_with_player" ]

   calcScore: (rank) ->
      switch rank
         when 1 then return 10
         when 2 then return 9
         when 3 then return 8
         when 4 then return 7
         when 5 then return 6
         when 6 then return 5
         when 7 then return 4
         when 8 then return 3
         when 9 then return 2
         else return 1
      
   getPointType: (game_type) ->
      switch game_type
         when "photo_challenge" then return "dedication" 
         when "gameday_pics" then return "passion" 
         when "spirit_wear" then return "passion" 
         when "picture_with_player" then return "dedication" 
         else return null