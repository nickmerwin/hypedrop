(function() {
  var app, phantom, port;

  app = require('express').createServer();

  phantom = require('phantom');

  app.get('/', function(req, res) {
    return phantom.create(function(ph) {
      return ph.createPage(function(page) {
        return page.open("http://hypem.com/popular", function(status) {
          return page.evaluate((function() {
            return document.title;
          }), function(result) {
            res.send('Page title is ' + result);
            return ph.exit();
          });
        });
      });
    });
  });

  port = process.env.PORT || 9000;

  app.listen(port);

  console.log("Hypedrop on port " + port);

}).call(this);
