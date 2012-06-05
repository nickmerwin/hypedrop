# HypeDrop!
#
# TODO:
# * mutli pages
# * specify username
# * specify single track url
# * triggered at interval
# * check file existance
# * folder structure:
#   * /popular
#   * /yicksterparty
# * playlist bulider

exec  = require('child_process').exec
request = require 'request'
util  = require('util')
fs = require('fs')
_ = require 'underscore'
buffertools = require('buffertools')

m3uWriter = require('m3u').writer()

dbox  = require("dbox")
dboxApp = dbox.app({ "app_key": "lnfmadcothfb9ds", "app_secret": "xmv6otph4yr0ish" })

express = require('express')
app = express.createServer()
app.use(express.cookieParser())
app.use(express.session({ secret: "asdfasdf" }))
app.use(express.static(__dirname + '/public'));
app.set('view engine', 'jade')


# nick@lemurheavy.com oauth:
access_token = 
  oauth_token_secret: 'qxnx9fflp0fq0ba'
  oauth_token: 'bx2uct9jqwn7cq8'
  uid: '1989285' 

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
app.get '/', (req, res)->
  res.render 'index'

app.get '/download', (req, res)->
  unless req.session.access_token
    req.session.downloadParams = req.query
    return res.redirect "/auth" 

  dboxClient = dboxApp.createClient(req.session.access_token)

  if req.session.downloadParams?
    opts = req.session.downloadParams
    req.session.downloadParams = null
  else
    opts = req.params

  nTracks = parseInt opts.nTracks

  phantomCmd = "phantomjs getTracks.coffee #{opts.hypemUrl || 'http://hypem.com/popular'} #{opts.nPages}"
  console.log phantomCmd
  exec phantomCmd, (err, stdout, stderr)->
    data = JSON.parse stdout

    # init m3u 
    # m3uWriter.comment "HypeDrop"

    tracks = if nTracks > 0 then data.tracks.slice(0, nTracks) else data.tracks

    tracks.forEach (track)->
      console.log "id: #{track.id}"

      path = "#{track.artist}-#{track.song}.mp3"

      opts = 
        url: "http://hypem.com/serve/play/#{track.id}/#{track.key}", 
        encoding: null
        headers: 
          'Cookie': data.cookie
          'User-Agent': data.agent
          'Referer': 'http://hypem.com/popular'

      request opts, (err, res, body)->

        console.log "putting: #{path}"

        dboxClient.put path, body, (status, meta)->
          console.log meta
        
    res.send data.tracks

# ===================================================================

port = process.env.PORT || 9000
app.listen port

console.log "HypeDrop on port #{port}"
