exports.handler = async function (event, context) {
  const axios = require("axios");

  let datacite_username = process.env.datacite_username;
  let datacite_password = process.env.datacite_password;
  let datacite_api_url = process.env.datacite_api_url;
  let providerUrl = `${datacite_api_url}/providers/export`;
  let repositoryUrl = `${datacite_api_url}/repositories/export`;
  let contactUrl = `${datacite_api_url}/contacts/export`;

  await axios
    .post(
      providerUrl,
      {},
      {
        auth: {
          username: datacite_username,
          password: datacite_password,
        },
      }
    )
    .then((response) => {
      console.log(response.data);
    })
    .catch((err) => {
      console.log(err.response);
    });

  await axios
    .post(
      repositoryUrl,
      {},
      {
        auth: {
          username: datacite_username,
          password: datacite_password,
        },
      }
    )
    .then((response) => {
      console.log(response.data);
    })
    .catch((err) => {
      console.log(err.response);
    });

  await axios
    .post(
      contactUrl,
      {},
      {
        auth: {
          username: datacite_username,
          password: datacite_password,
        },
      }
    )
    .then((response) => {
      console.log(response.data);
    })
    .catch((err) => {
      console.log(err.response);
    });
};