(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  _.templateSettings = {
    interpolate: /\{\{(.+?)\}\}/g
  };
  window.Loader = {
    init: function() {
      return $("#loadTracksBtn").click(__bind(function() {
        $("#loadTracksBtn").addClass("disabled");
        this.url = $("#urlInput").attr("disabled", true).val();
        $("#loadingBar").show();
        $.getJSON("/load-tracks?url=" + this.url, __bind(function(data) {
          var template;
          this.data = data;
          if (this.data.error) {
            this.enableForm();
            $("#loadingBar").hide();
            alert(":-( try again in a minute!");
            return;
          }
          $("#tracks").show();
          $("#loadingBar").hide();
          this.enableForm();
          template = _.template($("#trackTmpl").html());
          $("#tracksTable tbody tr").not("#trackTmpl").remove();
          return this.data.tracks.forEach(__bind(function(track) {
            var row;
            row = $("<tr>").html(template(track));
            row.find("a").attr("href", "/save?path=" + track.path + "&cookie=" + this.data.cookie + "&agent=" + this.data.agent + "&filename=" + track.filename);
            track.row = row;
            return $("#tracksTable tbody").append(row);
          }, this));
        }, this));
        $("#tracksTable thead input[type=checkbox]").change(function() {
          return $("#tracksTable tbody input[type=checkbox]").attr("checked", this.checked);
        });
        return $("#dropboxBtn").click(__bind(function() {
          var trackAttrs, tracks;
          tracks = _.select(this.data.tracks, function(t) {
            return t.row.find("input[type=checkbox]").attr("checked");
          });
          trackAttrs = _.map(tracks, function(t) {
            return {
              filename: t.filename,
              path: t.path
            };
          });
          $("#downloadAgent").val(this.data.agent);
          $("#downloadCookie").val(this.data.cookie);
          $("#trackAttrs").val(JSON.stringify(trackAttrs));
          return $("#downloadForm").submit();
        }, this));
      }, this));
    },
    enableForm: function() {
      $("#urlInput").attr("disabled", null);
      return $("#loadTracksBtn").removeClass("disabled");
    }
  };
  $(function() {
    return Loader.init();
  });
}).call(this);
