var AWS = require('aws-sdk')
var ecs = new AWS.ECS();

exports.handler = (events, context) => {
  console.log(events)

  var token         = process.env.token;
  var host          = process.env.host;

  var https = require('https');
  var options = {
    host: host,
    path: '/agents/crossref',
    method: 'POST',
    headers: {
      'Authorization': 'Bearer ' + token
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
