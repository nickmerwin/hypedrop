_.templateSettings = 
  interpolate : /\{\{(.+?)\}\}/g

window.Loader = 
  init: ->
    $("#loadTracksBtn").click =>
      $("#loadTracksBtn").addClass "disabled"

      @url = $("#urlInput").attr("disabled", true).val()

      $("#loadingBar").show()

      $.getJSON "/load-tracks?url=#{@url}", (@data)=>

        $("#tracks").show()

        $("#loadingBar").hide()

        $("#urlInput").attr "disabled", null
        $("#loadTracksBtn").removeClass "disabled"

        template = _.template $("#trackTmpl").html()

        @data.tracks.forEach (track)=>
          row = $("<tr>").html template track

          row.find("a").attr "href",
            "/save?path=#{track.path}&cookie=#{@data.cookie}&agent=#{@data.agent}&filename=#{track.filename}"

          track.row = row

          $("#tracksTable tbody").append row

      $("#tracksTable thead input[type=checkbox]").change ->
        $("#tracksTable tbody input[type=checkbox]").attr "checked", @checked

      $("#dropboxBtn").click =>
        tracks = _.select @data.tracks, (t)-> t.row.find("input[type=checkbox]").attr("checked")
        trackAttrs = _.map tracks, (t)-> {filename: t.filename, path: t.path}

        $("#downloadAgent").val @data.agent
        $("#downloadCookie").val @data.cookie
        $("#trackAttrs").val JSON.stringify trackAttrs
        $("#downloadForm").submit()

$ -> Loader.init()
