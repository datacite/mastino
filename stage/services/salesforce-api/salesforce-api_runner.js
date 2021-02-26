//persistent storage between lambda invocations
let auth;

exports.handler = async function (event, context) {
  require("dotenv").config();

  const apiVersion = "v51.0";
  const axios = require("axios");
  const authUrl = `https://${process.env.host}/services/oauth2/token`;

  // check if no token or token older than 20 min
  if (
    !auth ||
    !auth.issued_at ||
    (auth.issued_at && new Date() - new Date(auth.issued_at) > 20 * 60 * 1000)
  ) {
    auth = await axios
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
      .catch((err) => {
        if (err.response) {
          console.log(err.response.data);
        } else if (err.request) {
          console.log(err.request);
        } else {
          console.log(err);
        }
      });
  }
  console.log(auth);

  if (!auth) {
    console.log("Authentication error.");
    return null;
  }

  let url, body, organization;

  // each message has a single record
  let res = JSON.parse(event.Records[0].body);
  if (res.type === "contacts") {
    console.log(res.attributes);
    url = `${
      auth.instance_url
    }/services/data/${apiVersion}/sobjects/Account/Fabrica__c/${res.attributes.provider_id.toUpperCase()}`;
    organization = await axios
      .get(url, {
        headers: { Authorization: `Bearer ${auth.access_token}` },
      })
      .then((response) => {
        console.log(response.data);
      })
      .catch((err) => {
        if (err.response) {
          console.log(err.response.data);
        } else if (err.request) {
          console.log(err.request);
        } else {
          console.log(err);
        }
      });

    url = `${auth.instance_url}/services/data/${apiVersion}/sobjects/Contact/Uid__c/${res.id}`;
    body = {
      FirstName: res.attributes.given_name,
      LastName: res.attributes.family_name,
      Email: res.attributes.email,
      AccountId: organization.Id,
      Fabrica_ID__c: `${res.attributes.provider_id.toUpperCase()}-${
        res.attributes.email
      }`,
      Type__c: res.attributes.role_name
        ? res.attributes.role_name.join(";")
        : null,
      CreatedAt__c: res.attributes.created_at,
      ModifiedAt__c: res.attributes.updated_at,
      DeletedAt__c: res.attributes.deleted_at,
      Active__c: !res.attributes.deleted_at,
    };

    axios
      .patch(url, body, {
        headers: { Authorization: `Bearer ${auth.access_token}` },
      })
      .then((response) => {
        console.log(response.data);
      })
      .catch((err) => {
        if (err.response) {
          console.log(err.response.data);
        } else if (err.request) {
          console.log(err.request);
        } else {
          console.log(err);
        }
      });
  } else if (res.type === "providers") {
    const regions = { AMER: "Americas", EMEA: "EMEA", APAC: "Asia Pacific" };
    console.log(res.attributes);
    if (res.attributes.parent_organization) {
      url = `${auth.instance_url}/services/data/${apiVersion}/sobjects/Account/Fabrica__c/${res.attributes.parent_organization}`;
      organization = await axios
        .get(url, {
          headers: { Authorization: `Bearer ${auth.access_token}` },
        })
        .then((response) => {
          console.log(response.data);
        })
        .catch((err) => {
          if (err.response) {
            console.log(err.response.data);
          } else if (err.request) {
            console.log(err.request);
          } else {
            console.log(err);
          }
        });
    }
    console.log(organization);

    url = `${auth.instance_url}/services/data/${apiVersion}/sobjects/Account/Fabrica__c/${res.id}`;
    body = {
      Name: res.attributes.name,
      ParentId: organization ? organization.Id : null,
      Website: res.attributes.website,
      Description: res.attributes.description,
      System_Email__c: res.attributes.system_email,
      Group_Email__c: res.attributes.group_email,
      ROR__c: res.attributes.ror_id,
      Twitter__c: res.attributes.twitter_handle,
      Member_Type__c: res.attributes.member_type,
      Sector__c: res.attributes.organization_type,
      Focus_Area__c: res.attributes.focus_area,
      Region__c: res.attributes.region ? regions[res.attributes.region] : null,
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

    axios
      .patch(url, body, {
        headers: { Authorization: `Bearer ${auth.access_token}` },
      })
      .then((response) => {
        console.log(response.data);
      })
      .catch((err) => {
        if (err.response) {
          console.log(err.response.data);
        } else if (err.request) {
          console.log(err.request);
        } else {
          console.log(err);
        }
      });
  } else if (res.type === "clients") {
    url = `${
      auth.instance_url
    }/services/data/${apiVersion}/sobjects/Account/Fabrica__c/${res.attributes.provider_id.toUpperCase()}`;
    organization = await axios
      .get(url, {
        headers: { Authorization: `Bearer ${auth.access_token}` },
      })
      .then((response) => {
        console.log(response.data);
      })
      .catch((err) => {
        if (err.response) {
          console.log(err.response.data);
        } else if (err.request) {
          console.log(err.request);
        } else {
          console.log(err);
        }
      });

    url = `${auth.instance_url}/services/data/${apiVersion}/sobjects/Repositories__c/Repository_ID__c/${res.attributes.symbol}`;
    body = {
      Name: res.attributes.name,
      Organization__c: organization.Id,
      Repository_URL__c: res.attributes.url,
      re3data_Record__c: res.attributes.re3data_id,
      Description__c: res.attributes.description,
      Service_Email__c: res.attributes.system_email,
      Fabrica_creation_Date__c: res.attributes.created,
      Fabrica_modified_Date__c: res.attributes.updated,
      Fabrica_Deletion_Date__c: res.attributes.deleted_at,
      IsActive__c: res.attributes.is_active,
    };

    console.log(body);

    axios
      .patch(url, body, {
        headers: { Authorization: `Bearer ${auth.access_token}` },
      })
      .then((response) => {
        console.log(response.data);
      })
      .catch((err) => {
        if (err.response) {
          console.log(err.response.data);
        } else if (err.request) {
          console.log(err.request);
        } else {
          console.log(err);
        }
      });
  }
};
