---
# Copyright Verizon Media. All rights reserved.
title: Monitoring
---

Metrics can be pulled in a
[native Vespa format](https://docs.vespa.ai/documentation/reference/metrics.html)
or Prometheus.
Also see [vespa.ai monitoring](https://docs.vespa.ai/documentation/monitoring.html)



## Vespa Metrics
Metrics are available at _$ENDPOINT/metrics/v2/values_:
```
$ curl -s --cert data-plane-public-cert.pem --key data-plane-private-key.pem \
  'https://vespacloud-docsearch.vespa-team.aws-us-east-1c.public.vespa.oath.cloud/metrics/v2/values'
...
{
  "nodes": [
    {
      "hostname": "h577a.prod.aws-us-east-1c.vespa-external.aws.oath.cloud",
      "role": "content/documentation/0/7",
      "node": {
        "timestamp": 1601997367,
        "metrics": [
          {
            "values": {
```

Example: use [jq](https://stedolan.github.io/jq/) to extract relevant metrics:
```
$ curl -s --cert data-plane-public-cert.pem --key data-plane-private-key.pem \
  'https://vespacloud-docsearch.vespa-team.aws-us-east-1c.public.vespa.oath.cloud/metrics/v2/values' | \
  jq -r -c '.nodes[] | .hostname as $h | select(.services[].metrics[].values."content.proton.documentdb.documents.total.last") |'\
  '.services[].metrics[] | select(.values."content.proton.documentdb.documents.total.last") |'\
  '[$h, .dimensions.documenttype, .values."content.proton.documentdb.documents.total.last"] | @tsv'
  
h576a.prod.aws-us-east-1c.vespa-external.aws.oath.cloud	doc	230
h577a.prod.aws-us-east-1c.vespa-external.aws.oath.cloud	doc	230
```



## Prometheus and Grafana
Prometheus metrics are found at _$ENDPOINT/prometheus/v1/values_:
```
$ curl -s --cert data-plane-public-cert.pem --key data-plane-private-key.pem \
  'https://vespacloud-docsearch.vespa-team.aws-us-east-1c.public.vespa.oath.cloud/prometheus/v1/values'
...
# HELP content_proton_documentdb_documents_total_last
# TYPE content_proton_documentdb_documents_total_last untyped
content_proton_documentdb_documents_total_last{documenttype="doc",zone="prod.aws-us-east-1c",applicationId="vespa-team.vespacloud-docsearch.default",serviceId="searchnode",clusterId="content/documentation",hostname="h577a.prod.aws-us-east-1c.vespa-external.aws.oath.cloud",vespa_service="vespa_searchnode",} 230.0 1601991719000
content_proton_documentdb_documents_total_last{documenttype="doc",zone="prod.aws-us-east-1c",applicationId="vespa-team.vespacloud-docsearch.default",serviceId="searchnode",clusterId="content/documentation",hostname="h576a.prod.aws-us-east-1c.vespa-external.aws.oath.cloud",vespa_service="vespa_searchnode",} 230.0 1601991719000
...
```

Quick setup:

<table class="table">
<tr>
<th style="white-space: nowrap">Prometheus</th>
<td>
<p>
Prometheus is configured using <code>prometheus.yml</code>, find sample config in
<a href="https://github.com/vespa-engine/sample-apps/tree/master/album-recommendation-monitoring/prometheus">prometheus</a>.
See <code>prometheus-cloud.yml</code>,
which is designed to be easy to set up with any Vespa Cloud instance.
Replace <code>&lt;Endpoint&gt;</code> and <code>&lt;SERVICE_NAME&gt;</code> with the endpoint
for the application and the service name, respectively.
In addition, the path to the private key and public cert
that is used for the data plane to the endpoint need to be provided -
refer to  <a href="/security-model">security</a>.
Then, configure the Prometheus instance to use this configuration file.
The Prometheus instance will now start retrieving the metrics from Vespa Cloud.
If the Prometheus instance is used for multiple services,
append the target configuration for Vespa to scrape_configs.
</p>
</td>
</tr>
<tr>
<th style="white-space: nowrap">Grafana Dashboard</th>
<td>
<p>
Use the
<a href="https://github.com/vespa-engine/sample-apps/tree/master/album-recommendation-monitoring/grafana/provisioning">provisioning folder</a>
as a baseline for further configuration.
</p><p>
In the provisioning folder there are a few different files that all help for configuring Grafana locally.
These work as good examples of default configurations,
but the most important is the file named <code>Vespa-Engine-Advanced-Metrics-External.json</code>.
This is a default dashboard, based upon the metrics the Vespa team use to monitor performance.
</p><p>
Click the + button on the side and go to import.
Upload the file to the Grafana instance.
This should automatically load in the dashboard for usage.
For now, it will not display any data as no data sources are configured yet.
</p>
</td>
</tr>
<tr>
<th style="white-space: nowrap">Grafana Data Source</th>
<td>
<p>
The Prometheus data source has to be added to the Grafana instance for the visualisation.
Click the cog on the left and then "Data Sources".
Click "Add data source" and choose Prometheus from the list.
Add the URL for the Prometheus instance with appropriate bindings for connecting.
The configuration for the bindings will depend on how the Prometheus instance is hosted.
Once the configuration details have been entered,
click Save &amp; Test at the bottom and ensure that Grafana says "Data source is working".
</p>
</td>
</tr>
</table>

To verify the data flow,
navigate back to the Vespa Metrics dashboard by clicking the dashboard symbol on the left (4 blocks)
and clicking manage and then click Vespa Metrics.
Data should now appear in the Grafana dashboard.
If no data shows up, edit one of the data sets and ensure that it has the right data source selected.
The name of the data source the dashboard is expecting might be different from what your data source is named.
If there is still no data appearing,
it either means that the Vespa instance is not being used
or that some part of the configuration is wrong.



## AWS Cloudwatch
Refer to the [metrics-emitter](https://github.com/vespa-engine/metrics-emitter).
