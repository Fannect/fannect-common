require "mocha"
should = require "should"
Job = require "../../jobs/Job"
RenameJob = require "../../jobs/RenameJob"
ProfileImageJob = require "../../jobs/ProfileImageJob"
async = require "async"

dbSetup = require "../dbSetup"
Team = require "../../models/Team"
TeamProfile = require "../../models/TeamProfile"
User = require "../../models/User"
Stadium = require "../../models/Stadium"
Huddle = require "../../models/Huddle"

data_renameJob = require "./res/renameJob"
data_profileImageJob = require "./res/profileImageJob"

describe "Jobs", () ->

   describe "RenameJob", () ->

      afterEach (done) -> dbSetup.unload data_renameJob, done

      it "should create a job with the correct properties", () ->
         job = new RenameJob(user_id: "12345", new_name: "Name Changed!")
         job.meta.user_id.should.equal("12345")
         job.meta.new_name.should.equal("Name Changed!")
         job.is_locking.should.be.false

      it "should not error when creating job without user_id or new_name", () ->
         ( -> new RenameJob() ).should.throw();

      it "should rename all huddles and replies to new name", (done) ->
         user_id = "5102b17168a0c8f70c000002"
         new_name = "Name Changed!"

         dbSetup.load data_renameJob, (err) ->
            return done(err) if err
               
            job = new RenameJob(user_id: user_id, new_name: new_name )
            job.run (err) ->
               return done(err) if err
               Huddle.find
                  $or: [
                     { "owner_user_id": user_id },
                     { "replies.owner_user_id": user_id }
                  ] 
               , (err, huddles) ->
                  return done(err) if err
                     
                  for huddle in huddles
                     if huddle.owner_user_id.toString() == user_id
                        huddle.owner_name.should.equal(new_name)

                     for reply in huddle.replies
                        if reply.owner_user_id.toString() == user_id
                           reply.owner_name.should.equal(new_name)
                  done()

   describe "ProfileImageJob", () ->

      afterEach (done) -> dbSetup.unload data_renameJob, done

      it "should create a job with the correct properties", () ->
         job = new ProfileImageJob(user_id: "12345", new_image_url: "http://fannect.me/newimage")
         job.meta.user_id.should.equal("12345")
         job.meta.new_image_url.should.equal("http://fannect.me/newimage")
         job.is_locking.should.be.false

      it "should not error when creating job without user_id or new_image_urls", () ->
         ( -> new ProfileImageJob() ).should.throw();

      it "should rename all huddles and replies to new name", (done) ->
         user_id = "5102b17168a0c8f70c000002"
         new_image_url = "http://fannect.me/newimage"

         dbSetup.load data_profileImageJob, (err) ->
            return done(err) if err
               
            job = new ProfileImageJob(user_id: user_id, new_image_url: new_image_url )
            job.run (err) ->
               return done(err) if err
               Huddle.find { "replies.owner_user_id": user_id }, (err, huddles) ->
                  return done(err) if err
                     
                  for huddle in huddles
                     for reply in huddle.replies
                        if reply.owner_user_id.toString() == user_id
                           reply.owner_profile_image_url.should.equal(new_image_url)
                  done()
   