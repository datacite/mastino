exports.handler = async function (event, context) {
  require("dotenv").config();

  const axios = require("axios");
  const url = `https://${process.env.host}/services/oauth2/token`;
  const data = await axios
    .post(
      url,
      {},
      {
        params: {
          grant_type: "password",
          username: process.env.username,
          password: process.env.password,
          client_id: process.env.client_id,
          client_secret: process.env.client_secret,
        },
      }
    )
    .then((response) => {
      return response.data;
    })
    .catch((err) => console.warn(err));

  console.log(data);

  // event.Records.forEach((record) => {
  //   const { body } = record;
  //   console.log(body);
  // });
  // return {};
};
