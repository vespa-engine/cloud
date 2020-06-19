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

<!-- ToDo: Prometheus / Grafana integration doc here -->
