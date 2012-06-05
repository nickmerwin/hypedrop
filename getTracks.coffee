page = require('webpage').create()
page.settings.loadImages = false

pages = 3

url = phantom.args[0]
nPages = phantom.args[1]

page.onConsoleMessage = (msg)->
    console.log msg

page.open url, (status) ->
  if status isnt "success"
    console.log "Unable to access network"
    phantom.exit()
  else
    checkLoadInt = setInterval ->
      if tracks = page.evaluate(-> window.trackList[document.location.href])
        clearInterval checkLoadInt

        cookie = page.evaluate -> document.cookie
        agent = page.evaluate -> window.navigator.userAgent

        console.log JSON.stringify cookie: cookie, tracks: tracks, agent: agent

        phantom.exit()
    , 100
