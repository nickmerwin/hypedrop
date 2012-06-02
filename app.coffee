app = require('express').createServer()
phantom = require 'phantom'

app.get '/', (req, res)->
  phantom.create (ph) ->
    ph.createPage (page) ->
      page.open "http://hypem.com/popular", (status) ->
        page.evaluate (-> document.title), (result) ->
          res.send 'Page title is ' + result
          ph.exit()

port = process.env.PORT || 9000
app.listen port

console.log "Hypedrop on port #{port}"
