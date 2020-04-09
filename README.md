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
- WebKit's ITP friendly. The endpoint issues 1st party cookies with Secure and httpOnly flags.

## Setup

You can use one of BigQuery and Elasticsearch, or both as a database for logging. Fastly support multiple log-streaming in the same configuration.
BigQuery support SQL and faster query speed with massive logs. Elasticsearch supports super flexible schema-less data structure.
If you are going to use custom data (`*_attr` variables) frequently, or you wish to utilize Kibana's great visualization features, Elasticearch is better choice.
If you will get huge records from the giant website, or you wish to use Data Studio, BigQuery gives you better performance within reasonable cost.

### Prerequisites
- A [Google Cloud Platform](https://cloud.google.com/) account, and a project used for Ingestly.
- A [Fastly](https://www.fastly.com/signup) account, and a service used for Ingestly.
- This endpoint may use cookies named `ingestlyId`, `ingestlySes` and `ingestlyConsent` under your specified domain name.

*Note that a GCP project and a Fastly service can be created for Ingestly or you can use your existing one.*

### Google Cloud Platform

#### Create a service account for Fastly
1. Go to the GCP console, then open `IAM & admin` > `service accounts`.
2. Create a service account like `ingestly` and grant a `BigQuery` > `BigQuery Data Owner` permission.
3. Create a key and download it as JSON format.
4. Open the JSON you just downloaded and note `private_key` and `client_email`.

#### Create a table for the log data on BigQuery
1. Go to the GCP console, then open `BigQuery`.
2. Create a dataset like `Ingestly` if you haven't had.
3. Create a table with your preferred table name like `logs`, then enable `Edit as text` in Schema section. (note your table name)
4. Open `BigQuery/table_schema` file in this repository, copy the content and paste it to the schema text box of table creation modal.
5. In the `Partition and cluster settings` section, Select `timestamp` column for partitioning.
6. Finish creating the table.

### Elasticsearch

#### Create a user for Fastly
1. Open Kibana UI.
2. Go to `Management > Security > Roles`.
3. Click top-right `Create role` button.
4. Name this role as `Ingestly`
5. Type `ingestly-#{%F}` into `Index` field manually. (an index name will be generated dynamically by [strftime](http://man7.org/linux/man-pages/man3/strftime.3.html). in this case, an index is daily basis with YYYY-MM-DD formatted date.)
6. Select `create_index`, `create`, `index`, `read`, `write` and `monitor` in `Privileges` field, then save.
7. Go to `Management > Security > Users`
8. Click top-right `Create user` button.
9. Name this role as `Ingestly` and fill each field as you like.
10. Select `Ingestly` from a role list, then save.

#### Put a mapping template to Elasticsearch
1. Go to `Dev Tools`.
2. Type `PUT _template/ingestly` into the first line of Dev Tools console.
3. Open `Elasticsearch/mapping_template.json` file and copy & paste the content to the second line of Dev Tools console.
4. Click the triangle icon on the first line (execute the command)

If you see `Custom Analyzer` related error message when you executed above process, you should choose one of the following selections.

A. Add Natural Language Analysis plugins to Elasticsearch. `analysis-kuromoji` and `analysis-icu` are recommended.
B. Remove `analysis` section (from line 22 to line 40) from `Elasticsearch/mapping_template.json` to deactivate Analyzer.

#### Create an index pattern
1. Go to `Management > Kibana > Index Patterns`.
2. Click top-right `Create index pattern` button.
3. Fill `ingestly` into `Index Pattern` field, then click `Next step`.
4. Select `timestamp` from `Time Filter field name` pulldown, then click `Create index pattern`.


### Fastly

#### Custom VCL
1. Open `ingestly.vcl` file in this repository and change a value for `cookie_domain` to make a cookie compatible with your domain, then save the file.
2. Open `Custom VCL` in CONFIGURE page under your service.
3. Click `Upload a VCL file` button, then set preferred name like `Ingestly`, select `ingestly.vcl` and upload the file.

#### Integrate with Google BigQuery
1. Open `Logging` in CONFIGURE page.
2. Click `CREATE ENDPOINT` button and select `Google BigQuery`.
3. Open `attach a condition.` link near highlighted `CONDITION` and select `CREATE A NEW RESPONSE CONDITION`.
4. Enter a name like `Data Ingestion` and set `(resp.status == 204 && req.url ~ "^/ingestly-ingest/(.*?)/\?.*")` into `Apply if…` field.
5. Fill information into fields:
    - `Name` : anything you want.
    - `Log format` : copy and paste the content of `BigQuery/log_format` file in this repository.
    - `Email` : a value from `client_email` field of GCP credential JSON file.
    - `Secret key` : a value from `private_key` field of GCP credential JSON file.
    - `Project ID` : your project ID of GCP.
    - `Dataset` : a dataset name you created for Ingestly. (e.g. `Ingestly`)
    - `Table` : a table name you created for Ingestly. (e.g. `logs`)
    - `Template` : this field can be empty but you can configure time-sliced tables if you enter like `%Y%m%d`.
6. Click `CREATE` to finish the setup process.

#### Integrate with Elasticsearch
1. Open `Logging` in CONFIGURE page.
2. Click `CREATE ENDPOINT` button and select `Elasticsearch`.
3. Open `attach a condition.` link near highlighted `CONDITION` and select `CREATE A NEW RESPONSE CONDITION`.
4. Enter a name like `Data Ingestion` and set `(resp.status == 204 && req.url ~ "^/ingestly-ingest/(.*?)/\?.*")` into `Apply if…` field.
5. Fill information into fields:
    - `Name` : anything you want.
    - `Log format` : copy and paste the content of `Elasticsearch/log_format` file in this repository.
    - `URL` : An endpoint URL of Elasticsearch cluster.
    - `Index` : An index name for Elasticsearch. Set `ingestly`.
    - `BasicAuth user` : An username for Elasticsearch authentication. Set `Ingestly`.
    - `BasicAuth password` : Set a password for user `Ingestly` on Elasticsearch cluster.
6. Click `CREATE` to finish the setup process.

#### Integrate with Amazon S3
1. Open `Logging` in CONFIGURE page.
2. Click `CREATE ENDPOINT` button and select `Amazon S3`.
3. Open `attach a condition.` link near highlighted `CONDITION` and select `CREATE A NEW RESPONSE CONDITION`.
4. Enter a name like `Data Ingestion` and set `(resp.status == 204 && req.url ~ "^/ingestly-ingest/(.*?)/\?.*")` into `Apply if…` field.
5. Fill information into fields:
    - `Name` : anything you want.
    - `Log format` : copy and paste the content of `S3/log_format` file in this repository. You can specify not only CSV but JSON format here (`{ ... }` form).
    - `Timestamp format` : (not necessary)
    - `Bucket name` : The name of the bucket in which to store the logs.
    - `Access key` : An access key of the service account that can write into the bucket above.
    - `Secret key` : An secret key of the service account that can write into the bucket above.
    - `Period` : Log rotation interval(seconds). e.g. 600 means 10 minutes.
    - Advanced options
        - `Path` : The path within the bucket for placing files. You may specify dynamic variables in strftime format. In order to use Athena's partitioning feature by date, the path name must include `/date=%Y-%m-%d/` format.
        - `Domain` : The endpoint domain of your S3 bucket region (outside of US Standard region). e.g. Tokyo is `s3.ap-northeast-1.amazonaws.com`
        - `Select a log line format` : Blank. Otherwise the JSON format will be corrupted.
        - `Gzip level` : 9. The best compression to save the storage size.
6. Click `CREATE` to finish the setup process.


## Next Step
- Now you are ready to receive beacons. You can install [Ingestly Client JS](https://github.com/ingestly/ingestly-client-js) to your website.
