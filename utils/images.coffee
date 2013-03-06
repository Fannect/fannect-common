cloudinary = require "cloudinary"

name = process.env.CLOUDINARY_NAME or "fannect-dev"
key = process.env.CLOUDINARY_KEY or "498234921417922"
secret = process.env.CLOUDINARY_SECRET or "Q4qI_uIoi5D4fwkGOIDm84xZMQc"

cloudinary.config "cloud_name", name
cloudinary.config "api_key", key
cloudinary.config "api_secret", secret

images = module.exports

images.uploadToCloud = (image_path, options, done) ->
   if arguments.length < 3 then done = options
   cloudinary.uploader.upload image_path, (results) ->
      if done
         if results.error then done results.error
         else done null, results
   , options


images.getSignature = (params) ->
   return cloudinary.utils.api_sign_request(params, secret)

images.getTransformString = (options) ->
   return cloudinary.utils.generate_transformation_string(options)

images.getParams = (params) ->
   params.timestamp = new Date() / 1

   if params.transformation and typeof params.transformation != "string"
      params.transformation = images.getTransformString(params.transformation)

   params.signature = images.getSignature(params)
   params.api_key = key

   return params

images.getCloudName = () -> return name