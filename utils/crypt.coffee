crypto = require "crypto"

crypt = module.exports =
   hashPassword: (password) ->
      hash = crypto.createHash "sha512"
      hash.update password
      return hash.digest "hex"

   generateAccessToken: () -> return crypto.randomBytes(16).toString("hex")
   generateRefreshToken: () -> return crypto.randomBytes(32).toString("hex")
   generateResetToken: () -> return crypto.randomBytes(4).toString("hex")