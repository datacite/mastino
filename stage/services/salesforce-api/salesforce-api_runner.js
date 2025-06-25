/*
function hasBillingInfo(res = new Object({})) {
  return (
    res && res.attributes && (
      res.attributes.billing_organization ||
      res.attributes.billing_department ||
      res.attributes.billing_street ||
      res.attributes.billing_city ||
      res.attributes.billing_state_code ||
      res.attributes.billing_postal_code ||
      res.attributes.billing_country_code
    )
  ) ? true : false;
}
*/

function hasJoinedDate(res = new Object({})) {
  return (
    res && res.attributes && (
      res.attributes.joined
    )
  ) ? true : false;
}

//persistent storage between lambda invocations
let auth;

exports.handler = async function (event, context) {
  require("dotenv").config();

  const apiVersion = "v51.0";
  const axios = require("axios");
  const axiosRetry = require('axios-retry').default;
  const slack = require("slack-notify")(process.env.slack_webhook_url);
  const iconUrl = process.env.slack_icon_url;
  const authUrl = `https://${process.env.host}/services/oauth2/token`;
  const datacite_username = process.env.datacite_username;
  const datacite_password = process.env.datacite_password;
  const datacite_api_url = process.env.datacite_api_url;
  const providerUrl = `${datacite_api_url}/providers`;

  // 3 retries on locked record
  axiosRetry(axios, {
    retries: 3, // number of retries
    retryDelay: (retryCount) => {
      console.log(`(DEBUG SALESFORCE API): Salesforce API retry attempt: ${retryCount}`);
      return retryCount * 2000; // time interval between retries
    },
    retryCondition: (error) => {
      // if retry condition is not specified, by default idempotent requests are retried
      // console.log("(DEBUG SALESFORCE API): error.response.data = " + error.response.data);
      // console.log("(DEBUG SALESFORCE API): error.response.headers = " + error.response.headers);
      console.log("(DEBUG SALESFORCE API): retryCondition");
      console.log("(DEBUG SALESFORCE API): error.response.status = " + error.response.status);
      console.log("(DEBUG SALESFORCE API): error.response.data stringified = " + JSON.stringify(error.response.data));

      return ((error.response.status === 400) && (error.response.data[0].errorCode == 'UNABLE_TO_LOCK_ROW'));
    },
  });

  var slackMessage = slack.extend({
    channel: "#ops",
    icon_url: iconUrl,
    username: "Fabrica",
  });

  // check if no token or token older than 20 min
  if (
    auth == null ||
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
      .catch((error) => {
        if (error.response) {
          console.log(error.response);
        } else if (error.request) {
          console.log(error.request);
        } else {
          console.log(error);
        }
      });
  }

  if (!auth) {
    console.log("Authentication error.");
    return null;
  }

  let url, body, organization, accountId, result;

  // each message has a single record
  let res = JSON.parse(event.Records[0].body);
  if (res.type === "providers") {
    // const regions = { AMER: "Americas", EMEA: "EMEA", APAC: "Asia Pacific" };
    // const regions = { AMER: "AMER", EMEA: "EMEA", APAC: "APAC" };

    accountId = res.attributes.consortium_salesforce_id;

    if (!accountId && res.attributes.parent_organization) {
      url = `${
        auth.instance_url
      }/services/data/${apiVersion}/sobjects/Account/Fabrica__c/${res.attributes.parent_organization.toUpperCase()}`;
      try {
        organization = await axios
          .get(url, {
            headers: { Authorization: `Bearer ${auth.access_token}` },
          })
          .then((response) => {
            return response.data;
          });
      } catch (error) {
        if (error.response) {
          console.log(error.response);
        } else if (error.request) {
          console.log(error.request);
        } else {
          console.log(error);
        }
      }

      if (!organization) {
        console.log(
          `No parent organization found for provider ${res.id.toUpperCase()}.`
        );
        return null;
      }

      accountId = organization.Id;

      await axios
        .patch(
          providerUrl +
            `/${res.attributes.parent_organization.toLowerCase()}?include-deleted=true`,
          {
            data: {
              type: "providers",
              attributes: { salesforceId: accountId },
            },
          },
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
        .catch((error) => {
          console.log(error);
        });
    }

    url = `${
      auth.instance_url
    }/services/data/${apiVersion}/sobjects/Account/Fabrica__c/${res.id.toUpperCase()}`;
    body = {
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
      // Region__c: res.attributes.region ? regions[res.attributes.region] : null,
      Region__c: res.attributes.region ? res.attributes.region : null,
      Assign_DOIs__c: [
        "Direct Member",
        "Consortium",
        "Consortium Organization",
      ].includes(res.attributes.member_type),
      //Date_Joined__c: res.attributes.joined,
      Fabrica_Creation_Date__c: res.attributes.created,
      Fabrica_Modification_Date__c: res.attributes.updated,
      Fabrica_Deletion_Date__c: res.attributes.deleted_at,
      Is_Active__c: !res.attributes.deleted_at,
    };
    
    console.log("***SETTING THE ORGANIZATION REGION:");
    console.log(body.Name);
    console.log(body.Region__c);

    if (hasJoinedDate(res)) {
      body.Date_Joined__c = res.attributes.joined;
    }

    // consortium organizations have a parent organization
    if ("Consortium Organization" === res.attributes.member_type) {
      body = Object.assign(body, {
        ParentId: accountId,
        DOI_Estimate_Year_1__c: res.attributes.doi_estimate,
      });
    }

    // some member types support billing information
    /*
    if (
      ["Direct Member", "Consortium Organization", "Member Only"].includes(res.attributes.member_type) &&
      hasBillingInfo(res)
    ) {
      body = Object.assign(body, {
        Billing_Organization__c: res.attributes.billing_organization,
        Billing_Department__c: res.attributes.billing_department,
        BillingStreet: res.attributes.billing_street,
        BillingCity: res.attributes.billing_city,
        BillingStateCode: res.attributes.billing_state_code,
        BillingPostalCode: res.attributes.billing_postal_code,
        BillingCountryCode: res.attributes.billing_country_code,
      });
      console.log(`Forwarding nonnull billing info for organization: ${res.id}.`);
    } else {
      console.log(`Not forwarding null billing info for organization: ${res.id}.`);
    }
    */

    try {
      result = await axios.patch(url, body, {
        headers: { Authorization: `Bearer ${auth.access_token}` },
        validateStatus: () => true,
      });
      if (res.attributes.slack_message) {
        slackMessage({
          text: "An organization was updated in the Salesforce Sandbox.",
          attachments: [
            {
              fallback: result.data,
              color: "#2AAD73",
              fields: [
                {
                  title: "Organization Name",
                  value: res.attributes.name,
                  short: true,
                },
                {
                  title: "Errors",
                  value: result.data.errors.length > 0 ? "true" : "none",
                  short: true,
                },
                {
                  title: "Organization Fabrica ID",
                  value: res.id.toUpperCase(),
                  short: true,
                },
                {
                  title: "Organization Salesforce ID",
                  value: result.data.id,
                  short: true,
                },
                {
                  title: "Success",
                  value: result.data.success ? "true" : "false",
                  short: true,
                },
                {
                  title: "Created",
                  value: result.data.created ? "true" : "false",
                  short: true,
                },
              ],
            },
          ],
        });
      }
      console.log(
        Object.assign(result.data, { fabricaId: res.id, type: "organizations" })
      );
    } catch (error) {
      console.log(error);
      if (error.response) {
        slackMessage({
          text: "Error updating organization in Salesforce Sandbox.",
          attachments: [
            {
              fallback: error.response.data[0].message,
              color: "#D18F2C",
              fields: [
                { title: "Message", value: error.response.data[0].message },
                {
                  title: "Organization Name",
                  value: res.attributes.name,
                  short: true,
                },
                {
                  title: "Organization ID",
                  value: res.attributes.symbol,
                  short: true,
                },
                {
                  title: "Error Code",
                  value: error.response.data[0].errorCode,
                  short: true,
                },
                {
                  title: "Fields",
                  value: error.response.data[0].fields
                    ? error.response.data[0].fields.join(", ")
                    : null,
                  short: true,
                },
              ],
            },
          ],
        });
      }
    }
  } else if (res.type === "contacts") {
    accountId = res.attributes.provider_salesforce_id;

    if (!accountId) {
      url = `${
        auth.instance_url
      }/services/data/${apiVersion}/sobjects/Account/Fabrica__c/${res.attributes.provider_id.toUpperCase()}`;
      try {
        organization = await axios
          .get(url, {
            headers: { Authorization: `Bearer ${auth.access_token}` },
          })
          .then((response) => {
            return response.data;
          });
      } catch (error) {
        if (error.response) {
          slackMessage({
            text: "Error updating contact in Salesforce Sandbox.",
            attachments: [
              {
                fallback: error.response.data[0].message,
                color: "#D18F2C",
                fields: [
                  { title: "Message", value: error.response.data[0].message },
                  {
                    title: "Contact Name",
                    value: res.attributes.name,
                    short: true,
                  },
                  {
                    title: "Contact ID",
                    value: res.id,
                    short: true,
                  },
                  {
                    title: "Error Code",
                    value: error.response.data[0].errorCode,
                    short: true,
                  },
                  {
                    title: "Fields",
                    value: error.response.data[0].fields
                      ? error.response.data[0].fields.join(", ")
                      : null,
                    short: true,
                  },
                ],
              },
            ],
          });
        }
      }

      if (!organization) {
        console.log(`No organization found for contact ${res.id}.`);
        return null;
      }

      accountId = organization.Id;

      await axios
        .patch(
          providerUrl +
            `/${res.attributes.provider_id.toLowerCase()}?include-deleted=true`,
          {
            data: {
              type: "providers",
              attributes: { salesforceId: accountId },
            },
          },
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
        .catch((error) => {
          console.log(error);
        });
    }

    url = `${auth.instance_url}/services/data/${apiVersion}/sobjects/Contact/Uid__c/${res.id}`;
    body = {
      FirstName: res.attributes.given_name,
      LastName: res.attributes.family_name
        ? res.attributes.family_name
        : res.attributes.email,
      Email: res.attributes.email,
      AccountId: accountId,
      Type__c: res.attributes.role_name
        ? res.attributes.role_name.join(";")
        : null,
      Fabrica_Creation_Date__c: res.attributes.created_at,
      Fabrica_Modification_Date__c: res.attributes.updated_at,
      Fabrica_Deletion_Date__c: res.attributes.deleted_at,
      Active__c: !res.attributes.deleted_at,
    };

    try {
      result = await axios.patch(url, body, {
        headers: { Authorization: `Bearer ${auth.access_token}` },
      });
      if (res.attributes.slack_message) {
        slackMessage({
          text: "A contact was updated in the Salesforce Sandbox.",
          attachments: [
            {
              fallback: result.data,
              color: "#2AAD73",
              fields: [
                {
                  title: "Contact Name",
                  value: res.attributes.name,
                  short: true,
                },
                {
                  title: "Errors",
                  value: result.data.errors.length > 0 ? "true" : "none",
                  short: true,
                },
                {
                  title: "Contact Fabrica ID",
                  value: res.id,
                  short: true,
                },
                {
                  title: "Contact Salesforce ID",
                  value: result.data.id,
                  short: true,
                },
                {
                  title: "Success",
                  value: result.data.success ? "true" : "false",
                  short: true,
                },
                {
                  title: "Created",
                  value: result.data.created ? "true" : "false",
                  short: true,
                },
              ],
            },
          ],
        });
      }
      console.log(
        Object.assign(result.data, {
          fabricaId: res.attributes.fabrica_id,
          type: "contacts",
        })
      );
    } catch (error) {
      console.log(error);
      if (error.response) {
        slackMessage({
          text: "Error updating contact in Salesforce Sandbox.",
          attachments: [
            {
              fallback: error.response.data[0].message,
              color: "#D18F2C",
              fields: [
                { title: "Message", value: error.response.data[0].message },
                {
                  title: "Contact Name",
                  value: res.attributes.name,
                  short: true,
                },
                {
                  title: "Contact ID",
                  value: res.id,
                  short: true,
                },
                {
                  title: "Error Code",
                  value: error.response.data[0].errorCode,
                  short: true,
                },
                {
                  title: "Fields",
                  value: error.response.data[0].fields
                    ? error.response.data[0].fields.join(", ")
                    : null,
                  short: true,
                },
              ],
            },
          ],
        });
      }
    }
  } else if (res.type === "clients") {
    accountId = res.attributes.provider_salesforce_id;

    if (!accountId) {
      url = `${
        auth.instance_url
      }/services/data/${apiVersion}/sobjects/Account/Fabrica__c/${res.attributes.provider_id.toUpperCase()}`;
      try {
        organization = await axios
          .get(url, {
            headers: { Authorization: `Bearer ${auth.access_token}` },
          })
          .then((response) => {
            return response.data;
          });
      } catch (error) {
        if (error.response) {
          console.log(error.response);
        } else if (error.request) {
          console.log(error.request);
        } else {
          console.log(error);
        }
      }

      if (!organization) {
        console.log(`No organization found for repository ${res.id}.`);
        return null;
      }
      accountId = organization.Id;

      await axios
        .patch(
          providerUrl +
            `/${res.attributes.provider_id.toLowerCase()}?include-deleted=true`,
          {
            data: {
              type: "providers",
              attributes: { salesforceId: accountId },
            },
          },
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
        .catch((error) => {
          console.log(error);
        });
    }

    url = `${auth.instance_url}/services/data/${apiVersion}/sobjects/Repositories__c/Repository_ID__c/${res.attributes.symbol}`;
    body = {
      Name: res.attributes.name.substring(0, 80),
      Organization__c: accountId,
      Repository_URL__c: res.attributes.url,
      re3data_Record__c: res.attributes.re3data_id,
      Description__c: res.attributes.description,
      Service_Email__c: res.attributes.system_email,
      dois_count_current_year__c: res.attributes.dois_current_year,
      dois_count_previous_year__c: res.attributes.dois_last_year,
      dois_count_total__c: res.attributes.dois_total,
      Fabrica_creation_date__c: res.attributes.created,
      Fabrica_modified_date__c: res.attributes.updated,
      Fabrica_Deletion_Date__c: res.attributes.deleted_at,
      IsActive__c: !res.attributes.deleted_at,
    };

    console.log("(DEBUG SALESFORCE API): UPDATING REPOSITORIES - BEGIN");
    console.log(url);
    console.log(body);
    console.log("(DEBUG SALESFORCE API): UPDATING REPOSITORIES - END");

    try {
      result = await axios.patch(url, body, {
        headers: { Authorization: `Bearer ${auth.access_token}` },
      });
      if (res.attributes.slack_message) {
        slackMessage({
          text: "A repository was updated in the Salesforce Sandbox.",
          attachments: [
            {
              fallback: result.data,
              color: "#2AAD73",
              fields: [
                {
                  title: "Repository Name",
                  value: res.attributes.name,
                  short: true,
                },
                {
                  title: "Errors",
                  value: result.data.errors.length > 0 ? "true" : "none",
                  short: true,
                },
                {
                  title: "Repository Fabrica ID",
                  value: res.id.toUpperCase(),
                  short: true,
                },
                {
                  title: "Repository Salesforce ID",
                  value: result.data.id,
                  short: true,
                },
                {
                  title: "Success",
                  value: result.data.success ? "true" : "false",
                  short: true,
                },
                {
                  title: "Created",
                  value: result.data.created ? "true" : "false",
                  short: true,
                },
              ],
            },
          ],
        });
      }
      console.log(
        Object.assign(result.data, { fabricaId: res.id, type: "repositories" })
      );
    } catch (error) {
      console.log(error);
      if (error.response) {
        slackMessage({
          text: "Error updating repository in Salesforce Sandbox.",
          attachments: [
            {
              fallback: error.response.data[0].message,
              color: "#D18F2C",
              fields: [
                { title: "Message", value: error.response.data[0].message },
                {
                  title: "Repository Name",
                  value: res.attributes.name.substring(0, 80),
                  short: true,
                },
                {
                  title: "Repository ID",
                  value: res.attributes.symbol,
                  short: true,
                },
                {
                  title: "Error Code",
                  value: error.response.data[0].errorCode,
                  short: true,
                },
                {
                  title: "Fields",
                  value: error.response.data[0].fields
                    ? error.response.data[0].fields.join(", ")
                    : null,
                  short: true,
                },
              ],
            },
          ],
        });
      }
    }
  }
};
