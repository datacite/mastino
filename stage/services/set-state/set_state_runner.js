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

  const req = https.request(options, (res) => {
    console.log('status:', res.statusCode);

    res.setEncoding('utf8');
    res.on('data', (d) => {
      var json = JSON.parse(d);
      console.log('message:', json.message);
    });
  });

  req.on('error', (e) => {
    console.error(e);
  });
  req.end();
}
