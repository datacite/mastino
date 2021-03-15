exports.handler = async function (event, context) {
  const axios = require("axios");

  let username = process.env.username;
  let password = process.env.password;
  let host = process.env.host;
  let providerUrl = `https://${host}/providers/export?query=updated:%20[now-1h%20TO%20*]`;
  let repositoryUrl = `https://${host}/repositories/export?query=updated:%20[now-1h%20TO%20*]`;
  let contactUrl = `https://${host}/contacts/export?query=updated:%20[now-1h%20TO%20*]`;

  await axios
    .post(providerUrl, {
      headers: {
        Authorization:
          "Basic " + new Buffer(username + ":" + password).toString("base64"),
      },
    })
    .then((response) => {
      console.log(response.data);
    })
    .catch((err) => {
      console.log(err);
    });

  await axios
    .post(repositoryUrl, {
      headers: {
        Authorization:
          "Basic " + new Buffer(username + ":" + password).toString("base64"),
      },
    })
    .then((response) => {
      console.log(response.data);
    })
    .catch((err) => {
      console.log(err);
    });

  await axios
    .post(contactUrl, {
      headers: {
        Authorization:
          "Basic " + new Buffer(username + ":" + password).toString("base64"),
      },
    })
    .then((response) => {
      console.log(response.data);
    })
    .catch((err) => {
      console.log(err);
    });
};
