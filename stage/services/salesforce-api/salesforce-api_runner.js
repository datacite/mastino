//persistent storage between lambda invocations
let auth;

exports.handler = async function (event, context) {
  require("dotenv").config();

  var jsforce = require("jsforce");
  var conn = new jsforce.Connection({
    oauth2: {
      loginUrl: `https://${process.env.host}`,
      client_id: process.env.client_id,
      client_secret: process.env.client_secret,
    },
  });

  // check if no token or token older than 20 min
  if (
    !auth ||
    !auth.issued_at ||
    (auth.issued_at && new Date() - new Date(auth.issued_at) > 20 * 60 * 1000)
  ) {
    conn.login(
      process.env.username,
      process.env.password,
      function (err, userInfo) {
        if (err) {
          console.error(err);
        }

        console.log(conn.accessToken);
        console.log(conn.instanceUrl);
        auth = {
          accessToken: conn.accessToken,
          instanceUrl: conn.instanceUrl,
          issued_at: new Date(),
        };

        // logged in user property
        console.log("User ID: " + userInfo.id);
        console.log("Org ID: " + userInfo.organizationId);
      }
    );
  }

  if (!auth) {
    console.log("Authentication error.");
    return null;
  }

  const slack = require("slack-notify")(process.env.slack_webhook_url);
  const iconUrl = process.env.slack_icon_url;

  var slackMessage = slack.extend({
    channel: "#ops",
    icon_url: iconUrl,
    username: "Fabrica",
  });
};

// //persistent storage between lambda invocations
// let auth;

// exports.handler = async function (event, context) {
//   require("dotenv").config();

//   const apiVersion = "v51.0";
//   const axios = require("axios");
//   const slack = require("slack-notify")(process.env.slack_webhook_url);
//   const iconUrl = process.env.slack_icon_url;
//   const authUrl = `https://${process.env.host}/services/oauth2/token`;

//   var slackMessage = slack.extend({
//     channel: "#ops",
//     icon_url: iconUrl,
//     username: "Fabrica",
//   });

//   // check if no token or token older than 20 min
//   if (
//     !auth ||
//     !auth.issued_at ||
//     (auth.issued_at && new Date() - new Date(auth.issued_at) > 20 * 60 * 1000)
//   ) {
//     auth = await axios
//       .post(
//         authUrl,
//         {},
//         {
//           params: {
//             grant_type: "password",
//             username: process.env.username,
//             password: process.env.password,
//             client_id: process.env.client_id,
//             client_secret: process.env.client_secret,
//           },
//         }
//       )
//       .then((response) => {
//         return response.data;
//       })
//       .catch((err) => {
//         if (err.response) {
//           console.log(err.response);
//         } else if (err.request) {
//           console.log(err.request);
//         } else {
//           console.log(err);
//         }
//       });
//   }

//   if (!auth) {
//     console.log("Authentication error.");
//     return null;
//   }

//   let url, body, organization;

//   // each message has a single record
//   let res = JSON.parse(event.Records[0].body);
//   if (res.type === "providers") {
//     console.log(event.Records[0].body);
//     const regions = { AMER: "Americas", EMEA: "EMEA", APAC: "Asia Pacific" };
//     if (res.attributes.parent_organization) {
//       url = `${auth.instance_url}/services/data/${apiVersion}/sobjects/Account/Fabrica__c/${res.attributes.parent_organization}`;
//       organization = await axios
//         .get(url, {
//           headers: { Authorization: `Bearer ${auth.access_token}` },
//         })
//         .then((response) => {
//           return response.data;
//         })
//         .catch((err) => {
//           if (err.response) {
//             console.log(err.response);
//           } else if (err.request) {
//             console.log(err.request);
//           } else {
//             console.log(err);
//           }
//         });
//     }

//     url = `${auth.instance_url}/services/data/${apiVersion}/sobjects/Account/Fabrica__c/${res.id}`;
//     body = {
//       Name: res.attributes.name,
//       Website: res.attributes.website,
//       Description: res.attributes.description,
//       System_Email__c: res.attributes.system_email,
//       Group_Email__c: res.attributes.group_email,
//       ROR__c: res.attributes.ror_id,
//       Twitter__c: res.attributes.twitter_handle,
//       Member_Type__c: res.attributes.member_type,
//       Sector__c: res.attributes.organization_type,
//       Focus_Area__c: res.attributes.focus_area,
//       Region__c: res.attributes.region ? regions[res.attributes.region] : null,
//       Assign_DOIs__c: [
//         "Direct Member",
//         "Consortium",
//         "Consortium Organization",
//       ].includes(res.attributes.member_type),
//       Date_Joined__c: res.attributes.joined,
//       Fabrica_Creation_Date__c: res.attributes.created,
//       Fabrica_Modification_Date__c: res.attributes.updated,
//       Fabrica_Deletion_Date__c: res.attributes.deleted_at,
//       Is_Active__c: res.attributes.is_active,
//     };

//     // consortium organizations have a parent organization
//     if ("Consortium Organization" === res.attributes.member_type) {
//       body = Object.assign(body, {
//         ParentId: organization ? organization.Id : null,
//       });
//     }

//     // some member types support billing information
//     if (
//       ["Direct Member", "Consortium Organization", "Member Only"].includes(
//         res.attributes.member_type
//       )
//     ) {
//       body = Object.assign(body, {
//         Billing_Organization__c: res.attributes.billing_organization,
//         Billing_Department__c: res.attributes.billing_department,
//         BillingStreet: res.attributes.billing_street,
//         BillingCity: res.attributes.billing_city,
//         BillingStateCode: res.attributes.billing_state_code,
//         BillingPostalCode: res.attributes.billing_postal_code,
//         BillingCountryCode: res.attributes.billing_country_code,
//       });
//     }

//     console.log(body);

//     axios
//       .patch(url, body, {
//         headers: { Authorization: `Bearer ${auth.access_token}` },
//         validateStatus: () => true,
//       })
//       .then((response) => {
//         console.log(response);
//       })
//       .catch((err) => {
//         if (err.response) {
//           console.log(err.response);
//           slackMessage({
//             text: "Error updating organization in Salesforce.",
//             attachments: [
//               {
//                 fallback: err.response.data[0].message,
//                 color: "#D18F2C",
//                 fields: [
//                   { title: "Message", value: err.response.data[0].message },
//                   {
//                     title: "Organization Name",
//                     value: res.attributes.name,
//                     short: true,
//                   },
//                   {
//                     title: "Organization ID",
//                     value: res.attributes.symbol,
//                     short: true,
//                   },
//                   {
//                     title: "Error Code",
//                     value: err.response.data[0].errorCode,
//                     short: true,
//                   },
//                   {
//                     title: "Fields",
//                     value: err.response.data[0].fields
//                       ? err.response.data[0].fields.join(", ")
//                       : null,
//                     short: true,
//                   },
//                 ],
//               },
//             ],
//           });
//         } else if (err.request) {
//           console.log(err.request);
//         } else {
//           console.log(err);
//         }
//       });
//   } else if (res.type === "contacts") {
//     console.log(event.Records[0].body);
//     url = `${
//       auth.instance_url
//     }/services/data/${apiVersion}/sobjects/Account/Fabrica__c/${res.attributes.provider_id.toUpperCase()}`;
//     organization = await axios
//       .get(url, {
//         headers: { Authorization: `Bearer ${auth.access_token}` },
//       })
//       .then((response) => {
//         return response.data;
//       })
//       .catch((err) => {
//         if (err.response) {
//           console.log(err.response);
//           slackMessage({
//             text: "Error updating contact in Salesforce.",
//             attachments: [
//               {
//                 fallback: err.response.data[0].message,
//                 color: "#D18F2C",
//                 fields: [
//                   { title: "Message", value: err.response.data[0].message },
//                   {
//                     title: "Contact Name",
//                     value: res.attributes.name,
//                     short: true,
//                   },
//                   {
//                     title: "Contact ID",
//                     value: res.id,
//                     short: true,
//                   },
//                   {
//                     title: "Error Code",
//                     value: err.response.data[0].errorCode,
//                     short: true,
//                   },
//                   {
//                     title: "Fields",
//                     value: err.response.data[0].fields
//                       ? err.response.data[0].fields.join(", ")
//                       : null,
//                     short: true,
//                   },
//                 ],
//               },
//             ],
//           });
//         } else if (err.request) {
//           console.log(err.request);
//         } else {
//           console.log(err);
//         }
//       });

//     if (!organization) {
//       console.log(`No organization found for contact ${res.id}.`);
//       return null;
//     }

//     url = `${auth.instance_url}/services/data/${apiVersion}/sobjects/Contact/Fabrica_ID__c/${res.attributes.fabrica_id}`;
//     body = {
//       Uid__c: res.id,
//       FirstName: res.attributes.given_name,
//       LastName: res.attributes.family_name
//         ? res.attributes.family_name
//         : res.attributes.email,
//       Email: res.attributes.email,
//       AccountId: organization.Id,
//       Type__c: res.attributes.role_name
//         ? res.attributes.role_name.join(";")
//         : null,
//       CreatedAt__c: res.attributes.created_at,
//       ModifiedAt__c: res.attributes.updated_at,
//       DeletedAt__c: res.attributes.deleted_at,
//       Active__c: !res.attributes.deleted_at,
//     };

//     console.log(body);

//     axios
//       .patch(url, body, {
//         headers: { Authorization: `Bearer ${auth.access_token}` },
//         validateStatus: () => true,
//       })
//       .then((response) => {
//         console.log(response);
//       })
//       .catch((err) => {
//         if (err.response) {
//           console.log(err.response);
//           slackMessage({
//             text: "Error updating contact in Salesforce.",
//             attachments: [
//               {
//                 fallback: err.response.data[0].message,
//                 color: "#D18F2C",
//                 fields: [
//                   { title: "Message", value: err.response.data[0].message },
//                   {
//                     title: "Contact Name",
//                     value: res.attributes.name,
//                     short: true,
//                   },
//                   {
//                     title: "Contact ID",
//                     value: res.id,
//                     short: true,
//                   },
//                   {
//                     title: "Error Code",
//                     value: err.response.data[0].errorCode,
//                     short: true,
//                   },
//                   {
//                     title: "Fields",
//                     value: err.response.data[0].fields
//                       ? err.response.data[0].fields.join(", ")
//                       : null,
//                     short: true,
//                   },
//                 ],
//               },
//             ],
//           });
//         } else if (err.request) {
//           console.log(err.request);
//         } else {
//           console.log(err);
//         }
//       });
//   } else if (res.type === "clients") {
//     console.log(event.Records[0].body);
//     url = `${
//       auth.instance_url
//     }/services/data/${apiVersion}/sobjects/Account/Fabrica__c/${res.attributes.provider_id.toUpperCase()}`;
//     organization = await axios
//       .get(url, {
//         headers: { Authorization: `Bearer ${auth.access_token}` },
//       })
//       .then((response) => {
//         return response.data;
//       })
//       .catch((err) => {
//         if (err.response) {
//           console.log(err.response);
//         } else if (err.request) {
//           console.log(err.request);
//         } else {
//           console.log(err);
//         }
//       });

//     if (!organization) {
//       console.log(`No organization found for repository ${res.id}.`);
//       return null;
//     }

//     url = `${auth.instance_url}/services/data/${apiVersion}/sobjects/Repositories__c/Repository_ID__c/${res.attributes.symbol}`;
//     body = {
//       Name: res.attributes.name.substring(0, 80),
//       Organization__c: organization.Id,
//       Repository_URL__c: res.attributes.url,
//       re3data_Record__c: res.attributes.re3data_id,
//       Description__c: res.attributes.description,
//       Service_Email__c: res.attributes.system_email,
//       dois_count_current_year__c: res.attributes.dois_current_year,
//       dois_count_previous_year__c: res.attributes.dois_last_year,
//       dois_count_total__c: res.attributes.dois_total,
//       Fabrica_creation_Date__c: res.attributes.created,
//       Fabrica_modified_Date__c: res.attributes.updated,
//       Fabrica_Deletion_Date__c: res.attributes.deleted_at,
//       IsActive__c: res.attributes.is_active,
//     };

//     axios
//       .patch(url, body, {
//         headers: { Authorization: `Bearer ${auth.access_token}` },
//         validateStatus: () => true,
//       })
//       .then((response) => {
//         console.log(response);
//       })
//       .catch((err) => {
//         if (err.response) {
//           console.log(err.response);
//           slackMessage({
//             text: "Error updating repository in Salesforce.",
//             attachments: [
//               {
//                 fallback: err.response.data[0].message,
//                 color: "#D18F2C",
//                 fields: [
//                   { title: "Message", value: err.response.data[0].message },
//                   {
//                     title: "Repository Name",
//                     value: res.attributes.name.substring(0, 80),
//                     short: true,
//                   },
//                   {
//                     title: "Repository ID",
//                     value: res.attributes.symbol,
//                     short: true,
//                   },
//                   {
//                     title: "Error Code",
//                     value: err.response.data[0].errorCode,
//                     short: true,
//                   },
//                   {
//                     title: "Fields",
//                     value: err.response.data[0].fields
//                       ? err.response.data[0].fields.join(", ")
//                       : null,
//                     short: true,
//                   },
//                 ],
//               },
//             ],
//           });
//         } else if (err.request) {
//           console.log(err.request);
//         } else {
//           console.log(err);
//         }
//       });
//   }
// };
