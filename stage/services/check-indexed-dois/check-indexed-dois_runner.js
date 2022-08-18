exports.handler = (events, context) => {
  console.log(events);

  var username = "admin";
  var password = "Mossy-Tag9chef";
  var host = "api.stage.datacite.org";

  var https = require("https");
  var options = {
    host: host,
    path: "/export/check-indexed-dois",
    method: "POST",
    headers: {
      Authorization:
        "Basic " + new Buffer.from(username + ":" + password).toString("base64"),
    },
  };

  console.log(options)

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
  req.end();
};
