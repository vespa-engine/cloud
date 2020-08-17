---
# Copyright Verizon Media. All rights reserved.
title: "Monitoring"
---

Metrics are available at _$ENDPOINT/metrics/v2/values_, e.g.:
```
$ curl -s --cert data-plane-public-cert.pem --key data-plane-private-key.pem \
    'https://cord-19.vespa-team.aws-us-east-1c.public.vespa.oath.cloud/metrics/v2/values' 
```

Use [jq](https://stedolan.github.io/jq/) to extract relevant metrics::
```
$ curl -s --cert data-plane-public-cert.pem --key data-plane-private-key.pem \
    'https://cord-19.vespa-team.aws-us-east-1c.public.vespa.oath.cloud/metrics/v2/values' | \
    jq -r -c '.nodes[] | .hostname as $h | select(.services[].metrics[].values."content.proton.documentdb.documents.total.last") |'\
'.services[].metrics[] | select(.values."content.proton.documentdb.documents.total.last") |'\
'[$h, .dimensions.documenttype, .values."content.proton.documentdb.documents.total.last"] | @tsv'
  
h123a.prod.aws-us-east-1c.vespa-external.aws.oath.cloud	doc	127518
h456a.prod.aws-us-east-1c.vespa-external.aws.oath.cloud	doc	127518
```

See [vespa.ai monitoring](https://docs.vespa.ai/documentation/monitoring.html) and 
[vespa.ai metrics](https://docs.vespa.ai/documentation/reference/metrics.html) for details.



## AWS Cloudwatch
Refer to the [metrics-emitter](https://github.com/vespa-engine/metrics-emitter).



## Monitoring with Prometheus and Grafana
This section describes how to set up monitoring with Prometheus and Grafana.
This guide assumes access to a Vespa Cloud instance, as well as a Prometheus and Grafana instance.
It is recommended to use Grafana Cloud, but any Grafana instance that is capable of reaching the Prometheus
instance should be sufficient for the task. Prerequisites:
* A Vespa Cloud instance
* A Grafana instance
* A Prometheus instance


### Configuring Prometheus
Prometheus is configured using _prometheus.yml_.
Download it from the
[prometheus](https://github.com/vespa-engine/sample-apps/tree/master/album-recommendation-monitoring/prometheus)
folder.
We are interested in the prometheus-cloud.yml file,
which is designed to be easy to set up with any Vespa Cloud instance.
Replace \< Endpoint \> and \< SERVICE_NAME \> with the endpoint
for the application and the service name, respectively.
In addition, the path to the private key and public cert
that is used for the data plane to your endpoint need to be provided.
See [security model](https://cloud.vespa.ai/security-model.html)
for more information about accessing the data plane.
Then, configure the Prometheus instance to use this configuration file.
The Prometheus instance will now start retrieving the metrics from Vespa Cloud.
If the Prometheus instance is used for multiple services,
append the target configuration for Vespa to scrape_configs.


### Configuring Grafana Dashboard
To start configuring Grafana, download the
[provisioning folder](href="https://github.com/vespa-engine/sample-apps/tree/master/album-recommendation-monitoring/grafana/provisioning).
This serves as a baseline for further configuration.

In the provisioning folder there are a few different files that all help for configuring Grafana locally.
These work as good examples of default configurations,
but the most important is the file named _Vespa-Engine-Advanced-Metrics-External.json_.
This is a default dashboard, based upon the metrics the Vespa team use to monitor performance.

Click the + button on the side and go to import.
Upload the file to the Grafana instance.
This should automatically load in the dashboard for usage.
For now, it will not display any data as no data sources are configured yet.


### Configuring Grafana Data source
The Prometheus data source has to be added to the Grafana instance for the visualisation.
Click the cog on the left and then "Data Sources".
Click "Add data source" and choose Prometheus from the list.
Add the URL for the Prometheus instance with appropriate bindings for connecting.
The configuration for the bindings will depend on how the Prometheus instance is hosted.
Once the configuration details have been entered,
click Save & Test at the bottom and ensure that Grafana says "Data source is working".


### Verifying Data Flow
Navigate back to the Vespa Metrics dashboard by clicking the dashboard symbol on the left (4 blocks)
and clicking manage and then click Vespa Metrics.
Data should now appear in the Grafana dashboard.
If no data shows up, edit one of the data sets and ensure that it has the right data source selected.
The name of the data source the dashboard is expecting might be different from what your data source is named.
If there is still no data appearing,
it either means that the Vespa instance is not being used
or that some part of the configuration is wrong.
