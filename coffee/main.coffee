_.templateSettings = 
  interpolate : /\{\{(.+?)\}\}/g

window.Loader = 
  init: ->
    $("#loadTracksBtn").click =>
      $("#loadTracksBtn").addClass "disabled"

      @url = $("#urlInput").attr("disabled", true).val()

      $("#loadingBar").show()

      $.getJSON "/load-tracks?url=#{@url}", (@data)=>

        if @data.error
          @enableForm()
          $("#loadingBar").hide()
          alert ":-( try again in a minute!"
          return

        $("#tracks").show()

        $("#loadingBar").hide()

        @enableForm()

        template = _.template $("#trackTmpl").html()

        $("#tracksTable tbody tr").not("#trackTmpl").remove()

        @data.tracks.forEach (track)=>
          return unless track.type

          row = $("<tr>").html template track

          row.find("a").attr "href",
            "/save?path=#{track.path}&cookie=#{@data.cookie}&agent=#{@data.agent}&filename=#{track.filename}"

          track.row = row

          $("#tracksTable tbody").append row

      $("#tracksTable thead input[type=checkbox]").change ->
        $("#tracksTable tbody input[type=checkbox]").attr "checked", @checked

      $("#dropboxBtn").click =>
        tracks = _.select @data.tracks, (t)-> t.row?.find("input[type=checkbox]").attr("checked")
        trackAttrs = _.map tracks, (t)-> {filename: t.filename, path: t.path}

        $("#downloadAgent").val @data.agent
        $("#downloadCookie").val @data.cookie
        $("#trackAttrs").val JSON.stringify trackAttrs
        $("#downloadForm").submit()

  enableForm: ->
    $("#urlInput").attr "disabled", null
    $("#loadTracksBtn").removeClass "disabled"

$ -> Loader.init()
