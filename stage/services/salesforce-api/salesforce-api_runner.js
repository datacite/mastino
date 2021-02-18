exports.handler = async function (event, context) {
  const username = process.env.username;
  const password = process.env.password;
  const host = process.env.host;
  const client_id = process.env.client_id;
  const client_secret = process.env.client_secret;

  const axios = require("axios");

  axios
    .post(`https://${host}/services/oauth2/token`, {
      grant_type: "password",
      username: username,
      password: password,
      client_id: client_id,
      client_secret: client_secret,
    })
    .then(function (response) {
      console.log(response);
    })
    .catch(function (error) {
      console.log(error);
    });

  // event.Records.forEach((record) => {
  //   const { body } = record;
  //   console.log(body);
  // });
  // return {};
};
