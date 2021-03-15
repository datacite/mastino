exports.handler = async function (event, context) {
  const axios = require("axios");

  let datacite_username = process.env.datacite_username;
  let datacite_password = process.env.datacite_password;
  let datacite_api_url = process.env.datacite_api_url;
  let providerUrl = `${datacite_api_url}/providers/export?query=updated:%20[now-1h%20TO%20*]`;
  let repositoryUrl = `${datacite_api_url}/repositories/export?query=updated:%20[now-1h%20TO%20*]`;
  let contactUrl = `${datacite_api_url}/contacts/export?query=updated:%20[now-1h%20TO%20*]`;

  await axios
    .post(providerUrl, {
      headers: {
        Authorization:
          "Basic " +
          new Buffer(datacite_username + ":" + datacite_password).toString(
            "base64"
          ),
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
          "Basic " +
          new Buffer(datacite_username + ":" + datacite_password).toString(
            "base64"
          ),
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
          "Basic " +
          new Buffer(datacite_username + ":" + datacite_password).toString(
            "base64"
          ),
      },
    })
    .then((response) => {
      console.log(response.data);
    })
    .catch((err) => {
      console.log(err);
    });
};
