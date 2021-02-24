exports.handler = async function (event, context) {
  require("dotenv").config();

  const apiVersion = "v51.0";
  const axios = require("axios");
  const authUrl = `https://${process.env.host}/services/oauth2/token`;
  const auth = await axios
    .post(
      authUrl,
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
    let res = JSON.parse(record.body);
    if (res.type === "contacts") {
      let url = `${auth.instance_url}/services/data/${apiVersion}/sobjects/Contact/Uid__c/${res.attributes.uid}`;
      let body = {
        FirstName: res.attributes.given_name,
        LastName: res.attributes.family_name,
        Email: res.attributes.email,
        Fabrica_ID__c: `${res.attributes.provider_id.toUpperCase()}-${
          res.attributes.email
        }`,
        Type__c: res.attributes.role_name.join(";"),
        CreatedAt__c: res.attributes.created_at,
        ModifiedAt__c: res.attributes.updated_at,
        DeletedAt__c: res.attributes.deleted_at,
        Active__c: !res.attributes.deleted_at,
      };

      console.log(body);

      axios
        .patch(url, body, {
          headers: { Authorization: `Bearer ${auth.access_token}` },
        })
        .then((response) => {
          console.log(response.data);
        })
        .catch((err) => console.warn(err));
    } else if (res.type === "providers") {
      console.log("Organization");
      console.log(response.attributes);
    } else if (res.type === "repositories") {
      console.log("Repository");
      console.log(response.attributes);
    }
  });
};
