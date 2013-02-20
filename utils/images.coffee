cloudinary = require "cloudinary"

cloudinary.config "cloud_name", process.env.CLOUDINARY_NAME or "fannect-dev"
cloudinary.config "api_key", process.env.CLOUDINARY_KEY or "498234921417922"
cloudinary.config "api_secret", process.env.CLOUDINARY_SECRET or "Q4qI_uIoi5D4fwkGOIDm84xZMQc"

images = module.exports

images.uploadToCloud = (image_path, options, done) ->
   if arguments.length < 3 then done = options
   cloudinary.uploader.upload image_path, (results) ->
      if done
         if results.error then done results.error
         else done null, results
   , options