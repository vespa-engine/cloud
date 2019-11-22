---
# Copyright 2019 Oath Inc. All rights reserved.
title: "Operational Use Cases"
---


## Elastic, resilient Content Engine
Many organizations use cloud services like [AWS](https://aws.amazon.com/),
[Google Cloud](https://cloud.google.com/) and [Azure](https://azure.microsoft.com/) to easily manage capacity.
Vespa enables seemless resizing and change of instance types.
Vespa has no shards, it uses buckets with dynamic number of bits for distribution.
Using [cloud.vespa.ai](https://cloud.vespa.ai/) this is just a config change -
self-hosted Vespa enables this by adding to _services/hosts.xml_ and some manual steps -
[read more](/documentation/elastic-vespa.html).

As Vespa applications can be very large, node failures are automated as well,
with configurable rebalancing to regenerate replicas.

**Highlighted features**
* No shards
* Auto data redistribution - flavor migration
* Auto node failure
* Scale up to 1000, down to 1


## High-performance Content Engine
Vespa is built for really large realtime serving, and supports "unlimited" content node (proton) size.
[Proton](/documentation/proton.html)  is a C++ component and does not have memory limitations other than restrictions on
[attributes](/documentation/attributes.html) - a common use case is running in 256G containers.
It has its own memory allocator called [vespa-malloc](https://github.com/vespa-engine/vespa/tree/master/vespamalloc).

Usages vary from applications with tens of billions of documents and a moderate query rate (example: image search)
to millions of documents with query rates in 100.000/second (example: ad serving).
Vespa supports [performance groups](/documentation/elastic-vespa.html#grouped-distribution)
for flexible replica placement to enable a wide range of use cases.
All cases support a sustained, high throughput for updating documents.

Vespa supports a wide range of ML models by transforming them to [tensors](/documentation/tensor-intro.html) -
and uses [LLVM](https://llvm.org) for high-performance ranking.

Read more in [Vespa Performance](/documentation/performance/).

**Highlighted features**
* Huge content node memory support, including vespa-malloc
* Tensor representation
* Performance groups
* Sustained throughput for document partial updates
* LLVM


## Auto-upgraded, CI/CD applications, with failover
Most teams use the Vespa [automated deployments](https://cloud.vespa.ai/automated-deployments)
to continuously develop, test and deploy changes to applications.
A Vespa-application is defined by its configuration and code -
maintained in the [application package](/documentation/cloudconfig/application-packages.html).

Applications are most often deployed in multiple zones,
with failover using a [global endpoint](https://cloud.vespa.ai/reference/deployment#endpoint).

Software upgrades take both calendar and work time.
Testing is required to identify and fix performance regressions.
With Vespa Cloud, this is automated and just happens several times a week

**Highlighted features**
* Automated deployments
* Application packages for code and configuration consistency
* Submit/deploy interfaces to production push, no humans involved
* Multi-zone deployments with failover
* Metrics-based propagation to production zones


## Security
All changes to Vespa Cloud is automated - 
operating system, containers, Vespa software and dependencies - 
as well as testing the application code and configuration at every change.
This is a prerequisite for strong security - there are no stale, exposed components.
Applications run the latest, and auto testing makes sure it keeps working.

All external and internal communications is secured with mutual TLS with application-specific certificates.

All applications run on in dedicated and network isolated containers.

**Highlighted features**
* Auto SW upgrades
* Auto reboots
* All communication is encrypted
* Encryption at rest
* Java 11