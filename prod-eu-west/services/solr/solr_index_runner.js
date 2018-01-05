var AWS = require('aws-sdk')
var ecs = new AWS.ECS();

exports.handler = (events, context) => {
  console.log(events)
  var ecs_task_def  = process.env.ecs_task_def;
  var exec_region   = 'eu-west-1';
  var cluster       = process.env.cluster;
  var clean         = process.env.clean;
  var solr_user     = process.env.solr_user;
  var solr_password = process.env.solr_password;
  var host          = process.env.host;
  var path          = null;


  console.log(ecs_task_def, exec_region)
  var params = {
      taskDefinition: ecs_task_def,
      cluster: cluster,
      count: 1
  }

 // Start Index
    var http = require('http');

    // default is delta-import, do full-import if clean == true
    if (clean === "true") {
      path = '/admin/dataimport?command=full-import&commit=true&clean=true&optimize=false&wt=json';
    } else {
      path = '/admin/dataimport?command=full-import&commit=true&optimize=false&wt=json';
    }

    var options = {
      host: host,
      port: 40195,
      path: path,
      headers: {
        'Authorization': 'Basic ' + new Buffer(solr_user + ':' + solr_password).toString('base64')
      }
    };

    http.get(options, function(res) {
      console.log("Got response: " + res.statusCode);
    }).on('error', function(e) {
      console.log("Got error: " + e.message);
    });
}
