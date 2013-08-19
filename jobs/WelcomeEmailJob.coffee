async = require "async"
Job = require "./Job"
request = require "request"

username = process.env.SENDGRID_USERNAME or "fannect"
password = process.env.SENDGRID_PASSWORD or "1Billion!"

sendgrid = new (require("sendgrid-web"))({ 
   user: username,
   key: password
})

welcomeEmailExpired = null
welcomeEmailSubject = null
welcomeEmailHtml = null

class WelcomeEmailJob extends Job
   constructor: (data = {}) ->
      data.is_locking = false
      data.type = "welcome_email"
      
      if data.email and data.first_name
         data.meta = 
            email: data.email
            first_name: data.first_name
         delete data.email

      else if not data.meta
         throw new Error("email and first_name are required to create WelcomeEmailJob")

      super data

   run: (cb) =>
      @fetchHtml (err, subject, html) =>
         return cb(err) if err
         sendgrid.send
            to: @meta.email
            from: "team@fannect.me"
            fromname: "Joe Fannect"
            subject: subject.replace(/\[first_name\]/g, @meta.first_name)
            html: html.replace(/\[first_name\]/g, @meta.first_name)
         , cb

   fetchHtml: (cb) ->
      now = new Date() / 1
      if not welcomeEmailExpired or now > welcomeEmailExpired
         # refresh email
         request
            url: "http://sendgrid.com/api/newsletter/get.json?name=Welcome%20to%20Fannect&api_user=#{username}&api_key=#{password}"
            method: "GET"
         , (err, resp, body) ->
            return cb(err) if err
            body = JSON.parse(body)

            welcomeEmailHtml = body.html
            welcomeEmailSubject = body.subject
            welcomeEmailExpired = now + 3.6e6
            cb(null, welcomeEmailSubject, welcomeEmailHtml)
      else
         cb(null, welcomeEmailSubject, welcomeEmailHtml)      

module.exports = WelcomeEmailJob
