require "mocha"
should = require "should"
async = require "async"

Job = require "../../jobs/Job"
RenameJob = require "../../jobs/RenameJob"
ProfileImageJob = require "../../jobs/ProfileImageJob"
ProfileRankUpdateJob = require "../../jobs/ProfileRankUpdateJob"
TeamRankUpdateJob = require "../../jobs/TeamRankUpdateJob"

dbSetup = require "../dbSetup"
Team = require "../../models/Team"
TeamProfile = require "../../models/TeamProfile"
User = require "../../models/User"
Stadium = require "../../models/Stadium"
Huddle = require "../../models/Huddle"
Group = require "../../models/Group"

data_renameJob = require "./res/renameJob"
data_profileImageJob = require "./res/profileImageJob"
data_profileRankUpdateJob = require "./res/profileRankUpdateJob"
data_teamRankUpdateJob = require "./res/teamRankUpdateJob"

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

      it "should error when creating job without user_id or new_image_urls", () ->
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
   
   describe "ProfileRankUpdateJob", () ->

      afterEach (done) -> dbSetup.unload data_profileRankUpdateJob, done

      runRankTest = (job, order, cb) ->
         job.run (err) ->
            return done(err) if err

            TeamProfile
            .find(team_id: job.meta.team_id)
            .select("rank name")
            .sort("rank")
            .exec (err, profiles) ->
               return done(err) if err
               for profile, i in profiles
                  profile.name.should.equal(order[i])
                  profile.rank.should.equal(i + 1)

               cb()

      it "should create a job with the correct properties", () ->
         meta = 
            team_profile_id: "5102b17148a0c8f70c100005"
            team_id: "123"

         job = new ProfileRankUpdateJob(meta)
         job.meta.team_profile_id.should.equal("5102b17148a0c8f70c100005")
         job.meta.team_id.should.equal("123")
         job.is_locking.should.be.true
         job.locking_id.should.equal("rank_123")

      it "should error when creating job without team_profile_id or team_id", () ->
         ( -> new ProfileRankUpdateJob() ).should.throw();

      it "should rerank profiles when no tie exists", (done) ->
         id = "5102b17148a0c8f70c100005"
         meta = 
            team_profile_id: id
            team_id: "5102b17148a0c8f70c100111"

         dbSetup.load data_profileRankUpdateJob, (err) ->
            return done(err) if err 
            TeamProfile.update {_id: id}, "points.overall": 20, (err) ->
               return done(err) if err
               job = new ProfileRankUpdateJob(meta)
               order = [ "Test5", "Test1", "Test2", "Test3", "Test4" ]
               runRankTest(job, order, done)

      it "should rerank profiles when a tie exists", (done) ->
         id = "5102b17148a0c8f70c100005"
         meta = 
            team_profile_id: id
            team_id: "5102b17148a0c8f70c100111"

         dbSetup.load data_profileRankUpdateJob, (err) ->
            return done(err) if err
            TeamProfile.update {_id: id}, "points.overall": 8, (err) ->
               return done(err) if err
               job = new ProfileRankUpdateJob(meta)
               order = [ "Test1", "Test2", "Test5", "Test3", "Test4" ]
               runRankTest(job, order, done)

      it "should not rerank when no movement is needed", (done) ->
         id = "5102b17148a0c8f70c100005"
         meta = 
            team_profile_id: id
            team_id: "5102b17148a0c8f70c100111"

         dbSetup.load data_profileRankUpdateJob, (err) ->
            return done(err) if err
            TeamProfile.update {_id: id}, "points.overall": 6, (err) ->
               return done(err) if err
               job = new ProfileRankUpdateJob(meta)
               order = [ "Test1", "Test2", "Test3", "Test4", "Test5" ]
               runRankTest(job, order, done)

   describe "TeamRankUpdateJob", () ->

      before (done) -> 
         async.series [
            (done) -> dbSetup.unload data_teamRankUpdateJob, done
            (done) -> dbSetup.load data_teamRankUpdateJob, done
            (done) => 
               job = new TeamRankUpdateJob({ team_id: "51084c19f71f55551a7b1ef6" })
               job.run(done)
            (done) => 
               TeamProfile
               .find(team_id: "51084c19f71f55551a7b1ef6")
               .sort("rank")
               .select("rank points groups")
               .exec (err, profiles) =>
                  return done(err) if err
                  @profiles = profiles
                  done()
         ], done

      after (done) -> dbSetup.unload data_teamRankUpdateJob, done

      it "should create a job with the correct properties", () ->
         meta = team_id: "123"

         job = new TeamRankUpdateJob(meta)
         job.meta.team_id.should.equal("123")
         job.meta.batch_size.should.equal(40)
         job.is_locking.should.be.true
         job.locking_id.should.equal("rank_123")

      it "should error when creating job without a team_id", () ->
         ( -> new TeamRankUpdateJob() ).should.throw();

      it "should update all team profiles to have the correct rank", () ->
         @profiles[0].rank.should.equal(1)
         @profiles[1].rank.should.equal(2)
         @profiles[2].rank.should.equal(3)
         (@profiles[0].points.overall >= @profiles[1].points.overall).should.be.true
         (@profiles[1].points.overall >= @profiles[2].points.overall).should.be.true
        
      it "should update the points of the team", (done) ->
         Team.findById "51084c19f71f55551a7b1ef6", "points", (err, team) =>
            return done(err) if err
            overall = @profiles[0].points.overall + @profiles[1].points.overall + @profiles[2].points.overall 
            passion = @profiles[0].points.passion + @profiles[1].points.passion + @profiles[2].points.passion 
            dedication = @profiles[0].points.dedication + @profiles[1].points.dedication + @profiles[2].points.dedication 
            knowledge = @profiles[0].points.knowledge + @profiles[1].points.knowledge + @profiles[2].points.knowledge 

            team.points.overall.should.equal(overall)
            team.points.passion.should.equal(passion)
            team.points.dedication.should.equal(dedication)
            team.points.knowledge.should.equal(knowledge)
            done()

      it "should update group points correctly", (done) ->
         group_id = "51084c19f71f55551a7b2ef7"
         Group.findById group_id, "points", (err, group) =>
            group = group.toObject()
            sum = 0
            for profile in @profiles
               for g in profile.groups
                  if g.group_id?.toString() == "51084c19f71f55551a7b2ef7"
                     sum += profile.points.overall
                     break
            group.points.overall.should.equal(sum)
            done()

   