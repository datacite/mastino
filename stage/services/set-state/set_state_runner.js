var AWS = require('aws-sdk')
var ecs = new AWS.ECS();

exports.handler = (events, context) => {
  console.log(events)

  var username      = process.env.username;
  var password      = process.env.password;
  var host          = process.env.host;
  
  var http = require('http');
  var options = {
    host: host,
    path: 'dois/set-state',
    headers: {
      'Authorization': 'Basic ' + new Buffer(username + ':' + password).toString('base64')
    }
  };

  http.get(options, function(res) {
    console.log("Got response: " + res.statusCode);
  }).on('error', function(e) {
    console.log("Got error: " + e.message);
  });
}
