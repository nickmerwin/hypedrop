# HypeDrop!
#
# TODO:
# * mutli pages
# * specify username
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
dbox  = require("dbox")
dboxApp = dbox.app({ "app_key": "lnfmadcothfb9ds", "app_secret": "xmv6otph4yr0ish" })

express = require('express')
app = express.createServer()
app.use(express.cookieParser())
app.use(express.session({ secret: "asdfasdf" }))

domain = "http://localhost:9000"

# nick@lemurheavy.com oauth:
access_token = 
  oauth_token_secret: 'qxnx9fflp0fq0ba'
  oauth_token: 'bx2uct9jqwn7cq8'
  uid: '1989285' 

app.get '/auth', (req, res)->
  dboxApp.request_token (status, request_token)->
    req.session.request_token = request_token
    res.redirect "https://www.dropbox.com/1/oauth/authorize?oauth_token=#{ request_token.oauth_token }&oauth_callback=http://#{req.headers.host}/token"

app.get '/token', (req, res)->
  dboxApp.access_token req.session.request_token, (status, access_token)->
    console.log util.inspect access_token
    req.session.access_token = access_token
    res.redirect '/'

app.get '/', (req, res)->
  return res.redirect "/auth" unless req.session.access_token

  dboxClient = dboxApp.createClient(req.session.access_token)

  exec "phantomjs getTracks.coffee", (err, stdout, stderr)->
    data = JSON.parse stdout

    data.tracks.forEach (track)->
      console.log "id: #{track.id}"

      path = "#{track.artist}-#{track.song}.mp3"

      opts = 
        url: "http://hypem.com/serve/play/#{track.id}/#{track.key}", 
        headers: 
          'Cookie': data.cookie
          'User-Agent': data.agent
          'Referer': 'http://hypem.com/popular'

      request.get opts, (err, res, body)->

        console.log "putting: #{path}"

        dboxClient.put path, body, (status, meta)->
          console.log meta
        
    res.send data

port = process.env.PORT || 9000
app.listen port

console.log "Hypedrop on port #{port}"
