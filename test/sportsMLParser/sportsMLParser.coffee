require "mocha"
should = require "should"
fs = require "fs"

# Check and see if xml2js is installed, skip if not
try
   require "xml2js"
catch e
   skip = true

sportsML = require "../../sportsMLParser/sportsMLParser" unless skip

describe "sportsMLParser", () ->

   # Return if should skip
   return  it "skipping because 'xml2js' is not installed" if skip

   it "should identify empty document", (done) ->
      fs.readFile "#{__dirname}/res/fakeNoResult.xml", (err, xml) ->
         return done(err) if err
         sportsML.preview xml, (err, preview) ->
            should.not.exist(preview)
            done()

   it "should parse sample schedule xml file", (done) ->
      fs.readFile "#{__dirname}/res/fakeSchedule.xml", (err, xml) ->
         return done(err) if err
         sportsML.schedule xml, (err, schedule) ->
            result1 = schedule.sportsEvents[0]
            result1.eventMeta.event_key.should.equal("l.nba.com-2012-e.16887")
            result1.away_team.team_key.should.equal("l.nba.com-t.1")
            result1.home_team.team_key.should.equal("l.nba.com-t.2")
            result1.eventMeta.stadium_key.should.equal("AmericanAirlines_Arena_TEST")
            result1.eventMeta.coverage.should.equal("TNT, CSN-NE")
            result1.eventMeta.isPast().should.be.true
            done()

   it "should parse sample game preview xml file", (done) ->
      fs.readFile "#{__dirname}/res/fakePreview.xml", (err, xml) ->
         return done(err) if err
         sportsML.preview xml, (err, preview) ->
            return done(err) if err
            preview.articles.length.should.equal(2)
            preview.articles[0].event_key.should.equal("l.nba.com-2012-e.17856")
            preview.articles[0].preview.should.be.ok
            done()

   it "should parse sample event", (done) ->
      fs.readFile "#{__dirname}/res/fakeEvent.xml", (err, xml) ->
         return done(err) if err
         sportsML.eventStats xml, (err, eventStats) ->
            docs = eventStats.sportsEvents[0].eventMeta.docs
            docs.lineup.should.equal("xt.17810278-lineup")
            docs.pre_event_coverage.should.equal("xt.17810721-preview")
            docs.schedule_day.should.equal("xt.17810570-daysked")
            docs.event_score.should.equal("xt.17814385-update-post-event")
            docs.post_event_coverage.should.equal("xt.17814590-recap")
            docs.event_stats.should.equal("xt.17814514-box")
            done()

   it "should parse sample box scores xml file", (done) ->
      fs.readFile "#{__dirname}/res/fakeBoxScores.xml", (err, xml) ->
         return done(err) if err
         sportsML.eventStats xml, (err, eventStats) ->
            eventStats.sportsEvents[0].eventMeta.attendance.should.equal("18624")
            eventStats.sportsEvents[0].home_team.score.should.equal(99)
            eventStats.sportsEvents[0].away_team.score.should.equal(81)
            eventStats.sportsEvents[0].home_team.won().should.be.true
            eventStats.sportsEvents[0].away_team.won().should.be.false
            done()
