exports.handler = async function (event, context) {
  const username = process.env.username;
  const password = process.env.password;
  const loginUrl = "https://" + process.env.host;
  // const client_id = process.env.client_id;
  // const client_secret = process.env.client_secret;

  var jsforce = require("jsforce");
  var conn = new jsforce.Connection({
    loginUrl,
  });

  console.log(conn);

  conn.login(username, password, function (err, userInfo) {
    if (err) {
      return console.error(err);
    }
    console.log(conn.accessToken);
    console.log(conn.instanceUrl);
    // logged in user property
    console.log("User ID: " + userInfo.id);
    console.log("Org ID: " + userInfo.organizationId);
  });

  // event.Records.forEach((record) => {
  //   const { body } = record;
  //   console.log(body);
  // });
  // return {};
};
