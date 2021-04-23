//persistent storage between lambda invocations
let auth;

exports.handler = async function (event, context) {
  require("dotenv").config();

  const apiVersion = "v51.0";
  const axios = require("axios");
  const slack = require("slack-notify")(process.env.slack_webhook_url);
  const iconUrl = process.env.slack_icon_url;
  const authUrl = `https://${process.env.host}/services/oauth2/token`;

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

  let url, body, organization, result;

  // each message has a single record
  let res = JSON.parse(event.Records[0].body);
  if (res.type === "providers") {
    const regions = { AMER: "Americas", EMEA: "EMEA", APAC: "Asia Pacific" };
    if (res.attributes.parent_organization) {
      url = `${auth.instance_url}/services/data/${apiVersion}/sobjects/Account/Fabrica__c/${res.attributes.parent_organization}`;
      try {
        organization = await axios.get(url, {
          headers: { Authorization: `Bearer ${auth.access_token}` },
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
        console.log(`No parent organization found for provider ${res.id}.`);
        return null;
      }
    }

    url = `${auth.instance_url}/services/data/${apiVersion}/sobjects/Account/Fabrica__c/${res.id}`;
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
      Region__c: res.attributes.region ? regions[res.attributes.region] : null,
      Assign_DOIs__c: [
        "Direct Member",
        "Consortium",
        "Consortium Organization",
      ].includes(res.attributes.member_type),
      Date_Joined__c: res.attributes.joined,
      Fabrica_Creation_Date__c: res.attributes.created,
      Fabrica_Modification_Date__c: res.attributes.updated,
      Fabrica_Deletion_Date__c: res.attributes.deleted_at,
      Is_Active__c: !res.attributes.deleted_at,
    };

    // consortium organizations have a parent organization
    if ("Consortium Organization" === res.attributes.member_type) {
      body = Object.assign(body, {
        ParentId: organization ? organization.Id : null,
      });
    }

    // some member types support billing information
    if (
      ["Direct Member", "Consortium Organization", "Member Only"].includes(
        res.attributes.member_type
      )
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
    }

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
          text: "Error updating organization in Salesforce.",
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
    url = `${
      auth.instance_url
    }/services/data/${apiVersion}/sobjects/Account/Fabrica__c/${res.attributes.provider_id.toUpperCase()}`;
    try {
      organization = await axios.get(url, {
        headers: { Authorization: `Bearer ${auth.access_token}` },
      });
    } catch (error) {
      console.log(error);
      if (error.response) {
        slackMessage({
          text: "Error updating contact in Salesforce.",
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

    url = `${auth.instance_url}/services/data/${apiVersion}/sobjects/Contact/Uid__c/${res.id}`;
    body = {
      FirstName: res.attributes.given_name,
      LastName: res.attributes.family_name
        ? res.attributes.family_name
        : res.attributes.email,
      Email: res.attributes.email,
      Fabrica_ID__c: res.attributes.fabrica_id,
      AccountId: organization.Id,
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
          text: "Error updating contact in Salesforce.",
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
    url = `${
      auth.instance_url
    }/services/data/${apiVersion}/sobjects/Account/Fabrica__c/${res.attributes.provider_id.toUpperCase()}`;
    try {
      organization = await axios.get(url, {
        headers: { Authorization: `Bearer ${auth.access_token}` },
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

    url = `${auth.instance_url}/services/data/${apiVersion}/sobjects/Repositories__c/Repository_ID__c/${res.attributes.symbol}`;
    body = {
      Name: res.attributes.name.substring(0, 80),
      Organization__c: organization.Id,
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
          text: "Error updating repository in Salesforce.",
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
