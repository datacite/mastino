exports.handler = async function (event, context) {
  const username = process.env.username;
  const password = process.env.password;
  const host = process.env.host;
  const client_id = process.env.client_id;
  const client_secret = process.env.client_secret;

  const querystring = require("querystring");
  const postData = querystring.stringify({
    grant_type: "password",
    username: username,
    password: password,
    client_id: client_id,
    client_secret: client_secret,
  });
  const https = require("https");
  const options = {
    host: host,
    path: "/services/oauth2/token",
    method: "POST",
  };

  const req = https.request(options, (res) => {
    console.log("status:", res.statusCode);

    res.setEncoding("utf8");
    res.on("data", (d) => {
      var json = JSON.parse(d);
      console.log("message:", json.message);
    });
  });

  req.on("error", (e) => {
    console.error(e);
  });
  req.write(postData);
  req.end();

  // event.Records.forEach((record) => {
  //   const { body } = record;
  //   console.log(body);
  // });
  // return {};
};
