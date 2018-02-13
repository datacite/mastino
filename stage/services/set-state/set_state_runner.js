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
      console.log(JSON.stringify(d));
    });
  });

  req.on('error', (e) => {
    console.error(e);
  });
  req.end();
}
