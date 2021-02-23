exports.handler = async function (event, context) {
  require("dotenv").config();

  const axios = require("axios");
  const url = `https://${process.env.host}/services/oauth2/token`;
  const auth = await axios
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

  event.Records.forEach((record) => {
    let response = JSON.parse(record.body);
    if (response.type === "contacts") {
      console.log("Contact");
      console.log(response.attributes);
    } else if (response.type === "providers") {
      console.log("Organization");
      console.log(response.attributes);
    } else if (response.type === "repositories") {
      console.log("Repository");
      console.log(response.attributes);
    }
  });
};
