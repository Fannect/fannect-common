_reachIn = (obj, segments) ->
   return obj unless (obj and segments?.length > 0)
   inner = obj[segments.shift()]

   if inner and segments.length > 0
      return _reachIn(inner, segments)
   
   return inner 

module.exports = 
   reachIn: (obj, path) ->
      segments = path.split(".")
      # parse segments that are numbers
      for s, i in segments
         unless isNaN(s)
            segments[i] = parseInt(s)

      return _reachIn(obj, segments)

