---
# Copyright 2020 Oath Inc. All rights reserved.
title: "Benchmarking"
---

This guide describes how to benchmark using Vespa Cloud

Pointers:
* [Vespa performance](https://docs.vespa.ai/documentation/performance/)


## Security
Refer to the [Vespa security model](/security-model#data-plane).
To access the endpoint, the data plane certificate and private key is required -
obtain this from the application owner and store in XXX

Run a test query to test credentials - count all documents using schema "music" - using POST:

    $ curl --cert data-plane-public-cert.pem --key data-plane-private-key.pem \
      -H "Content-Type: application/json" \
      --data '{"yql" : "select * from sources * where sddocname contains \"music\";"}' \
      https://myapp.mytenant.aws-us-east-1c.public.vespa.oath.cloud/search/

Equivalent, using GET:

    $ curl --cert data-plane-public-cert.pem --key data-plane-private-key.pem \
      https://myapp.mytenant.aws-us-east-1c.public.vespa.oath.cloud/search/?yql=select%20%2A%20from%20sources%20%2A%20where%20sddocname%20contains%20%22music%22%3B%0A


## Generate test queries
If using logs, refer to [access logging](https://docs.vespa.ai/documentation/access-logging.html) - extract uri like 

    gunzip -c files*.gz | jq -r .uri

    /search/?yql=select%20%2A%20from%20sources%20%2A%20where%20sddocname%20contains%20%22music%22%3B


## Run queries from source data center
EC2 instance

copy query files there

run fbench same way

-C <str> : client certificate file name.
-K <str> : client private key file name.
