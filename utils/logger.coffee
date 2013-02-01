loggly = require "loggly"
 
client = loggly.createClient
   subdomain: "fannect"

key = process.env.LOGGLY_KEY #or "eae3d3ef-af37-4fb3-a771-2a50112312e1"

process.on "uncaughtException", (err) -> 
   client.log(key, err)

logger = module.exports = (k) -> key = k or key
logger.log = (data) -> client.log(key, data)