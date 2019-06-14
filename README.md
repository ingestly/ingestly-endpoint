# Ingestly Endpoint

- [Japanese Document available here / 日本語ドキュメントはこちら](./README-JP.md)
- [Column Reference is here](https://github.com/ingestly/ingestly-docs/blob/master/COLUMNS.md)

## What's Ingestly?

**Ingestly** is a simple tool for ingesting beacons to Google BigQuery. Digital Marketers and Front-end Developers often want to measure user's activities on their service without limitations and/or sampling, in real-time, having ownership of data, within reasonable cost. There are huge variety of web analytics tools in the market but those tools are expensive, large footprint, less flexibility, fixed UI, and you will be forced to use SDKs including legacy technologies like `document.write`.

Ingestly is focusing on Data Ingestion from the front-end to Google BigQuery by leveraging Fastly's features.
Also, Ingestly can be implemented seamlessly into your existing web site with in the same Fastly service, so you can own your analytics solution and ITP does not matter.

**Ingestly provides:**

- Completely server-less. Fastly and Google manages all of your infrastructure for Ingestly. No maintenance resource required.
- Near real-time data in Google BigQuery. You can get the latest data in less than seconds just after user's activity.
- Fastest response time for beacons. The endpoint is Fastly's global edge nodes, no backend, response is HTTP 204 and SDK uses ASYNC request.
- Direct ingestion into Google BigQuery. You don't need to configure any complicated integrations, no need to export/import by batches.
- Easy to start. You can start using Ingestly within 2 minutes for free if you already have a trial account on Fastly and GCP.
- WebKit's ITP friendly. The endpoint issues 1st party cookie with secure flags.

## Setup

### Prerequisites
- A [Google Cloud Platform](https://cloud.google.com/) account, and a project used for Ingestly.
- A [Fastly](https://www.fastly.com/signup) account, and a service used for Ingestly.
- This endpoint issues a cookie named `ingestlyId` under your specified domain name.

*Note that a GCP project and a Fastly service can be created for Ingestly or you can use your existing one.*

### Google Cloud Platform

#### Create a service account for Fastly
1. Go to the GCP console, then open `IAM & admin` > `service accounts`.
2. Create a service account like `ingestly` and grant a `BigQuery` > `BigQuery Data Owner` permission.
3. Create a key and download it as JSON format.
4. Open the JSON you just downloaded and note `private_key` and `client_email`.

#### Create a table for the log data on BigQuery
1. Go to the GCP console, then open `BigQuery`.
2. Create a dataset like `Ingestly` if you haven't have.
3. Create a table with your preferred table name like `logs`, then enable `Edit as text` in Schema section. (note your table name)
4. Open `table_schema` file in this repository, copy the content and paste it to the schema text box of table creation modal.
5. In the `Partition and cluster settings` section, Select `timestamp` column for partitioning.
6. Finish creating the table.

### Fastly

#### Custom VCL
1. Open `ingestly.vcl` file in this repository and change a value for `cookie_domain` to make a cookie compatible with your domain, then save the file.
2. Open `Custom VCL` in CONFIGURE page under your service.
3. Click `Upload a VCL file` button, then set preferred name like `Ingestly`, select `ingestly.vcl` and upload the file.

#### Integrate with Google BigQuery
1. Open `Logging` in CONFIGURE page.
2. Click `CREATE ENDPOINT` button and select `Google BigQuery`.
3. Open `attach a condition.` link near highlighted `CONDITION`, and select `CREATE A NEW RESPONSE CONDITION`.
4. Enter a name like `Data Ingestion` and set `resp.status == 204 && req.url ~ "^/ingestly-ingest/(.*?)/\?.*"` into `Apply if…` field.
5. Fill information into fields:
    - `Name` : anything you want.
    - `Log format` : copy and paste the content of `log_format` file in this repository.
    - `Email` : a value from `client_email` field of GCP credential JSON file.
    - `Secret key` : a value from `private_key` field of GCP credential JSON file.
    - `Project ID` : your project ID of GCP.
    - `Dataset` : a dataset name you created for Ingestly. (eg. `Ingestly`)
    - `Table` : a table name you created for Ingestly. (eg. `logs`)
    - `Template` : this field can be empty but you can configure time-sliced tables if you enter like `%Y%m%d`.
6. Click `CREATE` to finish the setup process.

## Next Step
- Now you are ready to receive beacons. You can install [Ingestly Client JS](https://github.com/ingestly/ingestly-client-js) to your website.
