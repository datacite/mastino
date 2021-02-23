exports.handler = async function (event, context) {
  const username = process.env.username;
  const password = process.env.password;
  const host = process.env.host;

  var jsforce = require("jsforce");
  var conn = new jsforce.Connection({
    loginUrl: "https://" + host,
  });

  conn.login(username, password, function (err, res) {
    if (err) {
      return console.error(err);
    }
    conn.query("SELECT Id, Name FROM Account", function (err, res) {
      if (err) {
        return console.error(err);
      }
      console.log(res);
    });
  });

  // event.Records.forEach((record) => {
  //   const { body } = record;
  //   console.log(body);
  // });
  // return {};
};
