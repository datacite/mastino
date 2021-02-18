exports.handler = async function (event, context) {
  const https = require("https");
  const querystring = require("querystring");

  let username = process.env.username;
  let password = process.env.password;
  let host = process.env.host;
  let client_id = process.env.client_id;
  let client_secret = process.env.client_secret;

  let params = querystring.stringify({
    grant_type: "password",
    username: username,
    password: password,
    client_id: client_id,
    client_secret: client_secret,
  });

  let options = {
    host: host,
    path: `/services/oauth2/token${params}`,
    method: "POST",
  };

  console.log(options);

  const req = https.request(options, (res) => {
    console.log("status:", res.statusCode);

    res.setEncoding("utf8");
    res.on("data", (d) => {
      let json = JSON.parse(d);
      console.log("message:", json.message);
    });
  });

  req.on("error", (e) => {
    console.error(e);
  });

  req.end();

  // event.Records.forEach((record) => {
  //   const { body } = record;
  //   console.log(body);
  // });
  // return {};
};
