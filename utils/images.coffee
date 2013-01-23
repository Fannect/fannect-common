cloudinary = require "cloudinary"

cloudinary.config "cloud_name", "fannect-dev"
cloudinary.config "api_key", "498234921417922"
cloudinary.config "api_secret", "Q4qI_uIoi5D4fwkGOIDm84xZMQc"

images = module.exports

images.uploadToCloud = (image_path, options, done) ->
   if arguments.length < 3 then done = options
   cloudinary.uploader.upload image_path, (results) ->
      if done
         if results.error then done results.error
         else done null, results
   , options