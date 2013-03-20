url = require("url")

module.exports = (redis_url, connection_name = "client") ->
   parsed_url = url.parse(redis_url or "redis://localhost:6379")
   parsed_auth = (parsed_url.auth or "").split(":")

   module.exports[connection_name or "client"] = 
      client = require("redis").createClient(parsed_url.port, parsed_url.hostname)

   if password = parsed_auth[1]
      client.auth password, (err) -> throw err if err

   unless process.env.NODE_TESTING
      client.on "ready", () -> console.log "redis (#{connection_name}) ready!"
      client.on "end", () -> console.log "redis (#{connection_name}) ended!"

   if database = parsed_auth[0] and parsed_auth[0] != "none"
      client.select database
      client.on "connect", () ->
         client.send_anyways = true
         client.select database
         client.send_anyways = false

   return module.exports[connection_name or client] = client

# client = module.exports.client = null
