page = require('webpage').create()
page.settings.loadImages = false
page.settings.userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/536.11 (KHTML, like Gecko) Chrome/20.0.1132.17 Safari/536.11"

pages = 3

url = phantom.args[0]
nPages = phantom.args[1]

page.onConsoleMessage = (msg)-> null
page.onError = (msg,trace)-> null

page.open url, (status) ->
  if status isnt "success"
    console.log "Unable to access network"
    phantom.exit()
  else
    page.evaluate -> jQuery(".play-ctrl").first().click()

    checkLoadInt = setInterval ->
      getTracks = ->
        try
          window.playList['tracks']
        catch e

      if tracks = page.evaluate(getTracks)
        clearInterval checkLoadInt

        cookie = page.evaluate -> document.cookie
        agent = page.evaluate -> window.navigator.userAgent

        console.log JSON.stringify cookie: cookie, tracks: tracks, agent: agent

        phantom.exit()
    , 100
