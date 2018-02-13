var AWS = require('aws-sdk')
var ecs = new AWS.ECS();

exports.handler = (events, context) => {
  console.log(events)

  var username      = process.env.username;
  var password      = process.env.password;
  var host          = process.env.host;

  var https = require('https');
  var options = {
    host: host,
    path: '/dois/set-state',
    method: 'POST',
    headers: {
      'Authorization': 'Basic ' + new Buffer(username + ':' + password).toString('base64')
    }
  };

  https.request(options, function(res) {
    console.log("[" + res.statusCode + "] Got response: " + res.message);
  }).on('error', function(e) {
    console.log("Got error: " + e.message);
  });
}
