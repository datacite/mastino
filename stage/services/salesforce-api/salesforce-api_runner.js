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

  // each message has a single record
  let res = JSON.parse(event.Records[0].body);
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
    let url = `${auth.instance_url}/services/data/${apiVersion}/sobjects/Account/Fabrica__c/${res.attributes.symbol}`;
    let body = {
      Name: res.attributes.name,
      Website: res.attributes.website,
      Description: res.attributes.description,
      System_Email__c: res.attributes.system_email,
      Group_Email__c: res.attributes.group_email,
      ROR__c: res.attributes.ror_id,
      Twitter__c: res.attributes.twitter_handle,
      Member_Type__c: res.attributes.member_type,
      Sector__c: res.attributes.organization_type,
      Focus_Area__c: res.attributes.focus_area,
      Region__c: res.attributes.region,
      Assign_DOIs__c: [
        "Direct Member",
        "Consortium",
        "Consortium Organization",
      ].includes(res.attributes.member_type),
      Billing_Organization__c: res.attributes.billing_organization,
      Billing_Department__c: res.attributes.billing_department,
      BillingAddress: res.attributes.billing_address,
      BillingCity: res.attributes.billing_city,
      BillingState: res.attributes.billing_state,
      BillingPostalCode: res.attributes.billing_post_code,
      BillingCountry: res.attributes.billing_country,
      Date_Joined__c: res.attributes.joined,
      Fabrica_Creation_Date__c: res.attributes.created,
      Fabrica_Modification_Date__c: res.attributes.updated,
      Fabrica_Deletion_Date__c: res.attributes.deleted_at,
      Is_Active__c: res.attributes.is_active,
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
  } else if (res.type === "repositories") {
    console.log(res.attributes);

    // let url = `${auth.instance_url}/services/data/${apiVersion}/sobjects/Repositories__c/Repository_ID__c/${res.attributes.symbol}`;
    // let body = {
    //   Name: res.attributes.name,
    //   Website: res.attributes.website,
    //   Description: res.attributes.description,
    //   System_Email__c: res.attributes.system_email,
    //   Group_Email__c: res.attributes.group_email,
    //   ROR__c: res.attributes.ror_id,
    //   Twitter__c: res.attributes.twitter_handle,
    //   Member_Type__c: res.attributes.member_type,
    //   Sector__c: res.attributes.organization_type,
    //   Focus_Area__c: res.attributes.focus_area,
    //   Region__c: res.attributes.region,
    //   Assign_DOIs__c: [
    //     "Direct Member",
    //     "Consortium",
    //     "Consortium Organization",
    //   ].includes(res.attributes.member_type),
    //   Billing_Organization__c: res.attributes.billing_organization,
    //   Billing_Department__c: res.attributes.billing_department,
    //   BillingAddress: res.attributes.billing_address,
    //   BillingCity: res.attributes.billing_city,
    //   BillingState: res.attributes.billing_state,
    //   BillingPostalCode: res.attributes.billing_post_code,
    //   BillingCountry: res.attributes.billing_country,
    //   Date_Joined__c: res.attributes.joined,
    //   Fabrica_Creation_Date__c: res.attributes.created,
    //   Fabrica_Modification_Date__c: res.attributes.updated,
    //   Fabrica_Deletion_Date__c: res.attributes.deleted_at,
    //   Is_Active__c: res.attributes.is_active,
    // };

    // console.log(body);

    // axios
    //   .patch(url, body, {
    //     headers: { Authorization: `Bearer ${auth.access_token}` },
    //   })
    //   .then((response) => {
    //     console.log(response.data);
    //   })
    //   .catch((err) => console.warn(err));
  }
};
