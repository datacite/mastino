var AWS = require('aws-sdk')
var ecs = new AWS.ECS();

exports.handler = (events, context) => {
  // CLI example:

  console.log(events)
  var ecs_task_def = process.env.ecs_task_def;
  var exec_region  = 'eu-west-1';
  var cluster      = process.env.cluster;
  var count        = process.env.count;

  console.log(ecs_task_def, exec_region)
  var params = {
      taskDefinition: ecs_task_def,
      cluster: cluster,
      count: count
  }
  ecs.runTask(params, function(err, data) {
      if (err) console.log(err, err.stack); // an error occurred
      else     console.log(data);           // successful response
      context.done(err, data)
  })

}
