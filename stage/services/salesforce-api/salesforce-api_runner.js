exports.handler = async function (event, context) {
  const username = process.env.username;
  const password = process.env.password;
  const loginUrl = "https://" + process.env.host;
  const clientId = process.env.client_id;
  const clientSecret = process.env.client_secret;

  var jsforce = require("jsforce");
  var conn = new jsforce.Connection({
    oauth2: {
      loginUrl,
      clientId,
      clientSecret,
      redirectUri: "<callback URI is here>",
    },
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
