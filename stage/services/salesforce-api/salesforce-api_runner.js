exports.handler = async function (event, context) {
  const username = process.env.username;
  const password = process.env.password;
  const url = `https://${process.env.host}/services/oauth2/token`;
  const client_id = process.env.client_id;
  const client_secret = process.env.client_secret;

  const axios = require("axios");

  const params = {
    grant_type: "password",
    username: username,
    password: password,
    client_id: client_id,
    client_secret: client_secret,
  };
  console.log(params);

  axios
    .post(url, {}, { params })
    .then((response) => {
      console.log(response);
    })
    .catch((err) => {
      if (err.response) {
        console.log(err.response);
      } else if (err.request) {
        console.log(err.request);
      } else {
        console.log(err);
      }
    });

  // event.Records.forEach((record) => {
  //   const { body } = record;
  //   console.log(body);
  // });
  // return {};
};
