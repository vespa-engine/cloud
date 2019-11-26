---
# Copyright 2019 Oath Inc. All rights reserved.
title: "Operational Use Cases"
---


## Elastic, Content Engine
Many organizations use cloud services like [AWS](https://aws.amazon.com/),
[Google Cloud](https://cloud.google.com/) and [Azure](https://azure.microsoft.com/) to easily manage capacity.
Vespa enables seemless resizing and change of instance types.
Vespa has no shards, it uses buckets with dynamic number of bits for distribution.
Using [cloud.vespa.ai](/) this is just a config change -
self-hosted Vespa enables this by adding to _services/hosts.xml_ and some manual steps -
read more in [elastic Vespa](https://docs.vespa.ai/documentation/elastic-vespa.html).

Equally important, Vespa applications scale down to 1 - developers can deploy the full application to to own laptop or development environment _with no configuration changes_. This lowers the bar for making changes, and also enables easy support, as the application can run anywhere (Vespa runs in a [Docker container](https://www.docker.com/)).

**Highlighted features**
* No shards - no need for manual operations for data copy when resizing
* Auto data redistribution
* Scale up to 1000, down to 1


## Resilient Content Engine
As Vespa applications can be very large, node failures are automated as well,
with configurable rebalancing speed to regenerate replicas.
Within configured data redundancy, the application keeps serving while new instances are auto provisioned.
Failed instances are kept for some time offline to preserve data in catastrophic events.

**Highlighted features**
* Auto node failure and provisioning


## Flexible Content Engine for optimized costs
The elastic features of Vespa cloud makes it easy to add or remove nodes by just a configuration change and some wait time for auto data migration.
However, it is hard to get the node specifications right from the start -
applications change with new features and changing load patterns.
Trying to get everything right before launch will also push the launch date out,
and requires must testing.

Instead, launch with enough capacity, monitor, and then change both node count and node specifications
based on real production load.
Changing specifications, like double CPU or cut memory is a configuration change and subsequent auto data migration - read more about [resources](/reference/services-hosted#resources).
Using this flexibility, teams migrating from self-hosted to Vespa Cloud:
* cuts cost in half on average
* launches with little risk using overcapacity first days
* accelerates schedules as load test requirements are cut

**Highlighted features**
* Auto node capacity migration - move from one spec to another
* Independent stateful/stateless node scaling


## High-performance Content Engine
Vespa is built for really large realtime serving, and supports "unlimited" content node (proton) size.
[Proton](https://docs.vespa.ai/documentation/proton.html)  is a C++ component and does not have memory limitations other than restrictions on
[attributes](https://docs.vespa.ai/documentation/attributes.html) - a common use case is running in 256G containers.
It has its own memory allocator called [vespa-malloc](https://github.com/vespa-engine/vespa/tree/master/vespamalloc).

Usages vary from applications with tens of billions of documents and a moderate query rate (example: image search)
to millions of documents with query rates in 100.000/second (example: ad serving).
Vespa supports [performance groups](https://docs.vespa.ai/documentation/elastic-vespa.html#grouped-distribution)
for flexible replica placement to enable a wide range of use cases.
All cases support a sustained, high throughput for updating documents.

Vespa supports a wide range of ML models by transforming them to [tensors](https://docs.vespa.ai/documentation/tensor-intro.html) -
and uses [LLVM](https://llvm.org) for high-performance ranking.

Read more in [Vespa Performance](https://docs.vespa.ai/documentation/performance/).

**Highlighted features**
* Huge content node memory support, including vespa-malloc
* Tensor representation
* Performance groups
* Sustained throughput for document partial updates
* Data structures uses chunked memory - low peak-to-average gives better utilization, lower costs and small compaction footprint
* LLVM


## Auto-upgraded, CI/CD applications, with failover
Most teams use the Vespa [automated deployments](/automated-deployments)
to continuously develop, test and deploy changes to applications.
A Vespa-application is defined by its configuration and code -
maintained in the [application package](https://docs.vespa.ai/documentation/cloudconfig/application-packages.html).

Applications are most often deployed in multiple zones,
with failover using a [global endpoint](/reference/deployment#endpoint).

Software upgrades take both calendar and work time.
Testing is required to identify and fix performance regressions.
With Vespa Cloud, this is automated and just happens several times a week

**Highlighted features**
* Automated deployments
* Application packages for code and configuration consistency
* Submit/deploy interfaces to production push, no humans involved
* Multi-zone deployments with failover
* Metrics-based propagation to production zones


<!--
ToDo: BCP as a separate section here later
-->


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
