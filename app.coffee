# HypeDrop!
#
# TODO:
# * mutli pages
# * triggered at interval
# * folder structure:
# * playlist bulider
# * ajax submit w/ socket.io for progress

exec  = require('child_process').exec
request = require 'request'
util  = require('util')
fs = require('fs')
_ = require 'underscore'

m3uWriter = require('m3u').writer()

dbox  = require("dbox")
dboxApp = dbox.app({ "app_key": process.env.HYPEDROP_DROPBOX_APP_KEY, "app_secret": process.env.HYPEDROP_DROPBOX_APP_SECRET })

express = require('express')
app = express.createServer()
app.use(express.cookieParser())
app.use(express.bodyParser())
app.use(express.session({ secret: "asdfasdf" }))

coffeeDir = __dirname + '/coffee'
publicDir = __dirname + '/public'

app.use express.compiler(src: coffeeDir, dest: publicDir, enable: ['coffeescript'])
app.use express.static publicDir

app.set('view engine', 'jade')

# ===================================================================

app.get '/auth', (req, res)->
  dboxApp.request_token (status, request_token)->
    req.session.request_token = request_token
    res.redirect "https://www.dropbox.com/1/oauth/authorize?oauth_token=#{ request_token.oauth_token }&oauth_callback=http://#{req.headers.host}/token"

app.get '/token', (req, res)->
  dboxApp.access_token req.session.request_token, (status, access_token)->
    console.log util.inspect access_token
    req.session.access_token = access_token
    res.redirect '/download'

# ===================================================================

app.get '/load-tracks', (req, res) ->
  url = (req.query.url || 'http://hypem.com/popular').replace /[ ]/g, "%20"

  phantomCmd = "phantomjs getTracks.coffee '#{url}' #{req.params.pages || 1} 2> /dev/null"
  console.log phantomCmd
  exec phantomCmd, (err, stdout, stderr)->
    try
      data = JSON.parse stdout
      data.tracks.forEach (track)->
        track.path = "http://hypem.com/serve/play/#{track.id}/#{track.key}"
        track.title = "#{track.artist} - #{track.song}"
        track.filename = "#{track.artist}-#{track.song}.mp3"
        track.length = track.time

      res.send data
    catch e
      console.log e.message
      console.log stdout
      res.send error: true

app.get '/', (req, res)->
  res.render 'index', info: req.flash("info")

app.get '/save', (req, res)->
  opts =
    url: req.query.path
    encoding: null
    headers:
      'Cookie': req.query.cookie
      'User-Agent': req.query.agent
      'Referer': 'http://hypem.com/popular'

  request opts, (err, reqRes, body)->
    res.attachment req.query.filename
    res.contentType "application/mp3"
    res.end body, 'binary'

# ================================================================

app.all '/download', (req, res)->
  if req.body?.tracks
    req.session.downloadBody = req.body

  unless req.session.access_token
    return res.redirect "/auth"

  tracks = JSON.parse req.session.downloadBody.tracks
  cookie = req.session.downloadBody.cookie
  agent = req.session.downloadBody.agent

  req.session.downloadBody = null

  dboxClient = dboxApp.createClient(req.session.access_token)

  tracks.forEach (track)->

    dboxClient.metadata track.filename, (status, meta)->
      return if status == 200 && !meta.is_deleted

      opts =
        url: track.path,
        encoding: null
        headers:
          'Cookie': cookie
          'User-Agent': agent
          'Referer': 'http://hypem.com/popular'

      request opts, (err, reqRes, body)->
        console.log "putting: #{track.filename}"

        dboxClient.put track.filename, body, (status, meta)->
          console.log "done! #{track.filename}"

  req.flash "info", "Delivering #{tracks.length} track(s) to your dropbox!"
  res.redirect "/"

# ===================================================================

port = process.env.PORT || 9000
app.listen port

console.log "HypeDrop on port #{port}"
