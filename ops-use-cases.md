---
# Copyright 2019 Oath Inc. All rights reserved.
title: "Operational Use Cases"
---


## Elastic Content Engine
Many organizations use cloud services like [AWS](https://aws.amazon.com/),
[Google Cloud](https://cloud.google.com/) and [Azure](https://azure.microsoft.com/) to easily manage capacity.
Vespa enables seemless resizing and change of instance types.
Vespa has no shards, it uses buckets with dynamic number of bits for distribution.
Using [cloud.vespa.ai](/) this is just a config change -
self-hosted Vespa enables this by adding to _services/hosts.xml_ and some manual steps -
read more in [elastic Vespa](https://docs.vespa.ai/documentation/elastic-vespa.html).

Equally important, Vespa applications scale down to 1 - developers can deploy the full application to to own laptop or development environment _with no configuration changes_. This lowers the bar for making changes, and also enables easy support, as the application can run anywhere (Vespa runs in a [Docker container](https://www.docker.com/)).

**Highlighted features**
* Change node count or node resource in config - deploy and just wait for auto data redistribution
* No shards, no index management. No need for manual operations for data copy when resizing
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
Changing specifications, like double CPU or cut memory is a configuration change and subsequent auto data migration - read more about [resources](/reference/services#resources):

    <nodes count="4">
        <resources vcpu="8" memory="32Gb" disk="100Gb"/>
    </nodes>

Using this flexibility, teams migrating from self-hosted to Vespa Cloud:
* cuts cost in half on average
* launches with little risk using overcapacity first days
* accelerates schedules as load test requirements are cut

**Highlighted features**
* Auto node capacity migration - move from one resource specification to another
* Independent stateful/stateless node scaling
* Support for multiple clusters within an application - scale different content clusters based on size and read/write characteristics



## Automated, Secure Deployments - no humans involved
A Vespa-application is defined by its configuration and code,
maintained in the [application package](https://docs.vespa.ai/documentation/cloudconfig/application-packages.html).
This changes over time as schemas change, code is modified.
To deploy changes safely to production, an explicit [validation](https://docs.vespa.ai/documentation/reference/validation-overrides.html) is required for potentially destructive changes.

This makes changes to production safe, most teams deploy daily or more often.
This makes changes smaller, with less risk and easier roll-forward.
Use [github actions](https://github.com/features/actions) or other automation
to build a pipeline that automatically rolls out changes committed to the code repository.

**Highlighted features**
* [Deployments](/automated-deployments) with automated tests
    * System tests
    * Staging tests
    * Production validation tests
* [Safe changes](https://docs.vespa.ai/documentation/reference/search-definitions-reference.html#modify-search-definitions) -
    potentially destructive changes are blocked



## Multi-Datacenter deployments with failover
Applications are most often deployed in multiple zones,
with failover using a [global endpoint](/reference/deployment#endpoint).

**Highlighted features**
* Multi-zone deployments with failover
* Metrics-based propagation to production zones when deploying changes



## Automated Software upgrades
Software upgrades take both calendar and work time.
Testing is required to identify and fix performance regressions.
With Vespa Cloud, this is automated and just happens several times a week

**Highlighted features**
* Auto SW upgrades - zero time spent testing for regressions
* Auto reboots with auto OS upgrades
* Orchestrated restarts - no need for cold standby



## Security
All changes to Vespa Cloud is automated - 
operating system, containers, Vespa software and dependencies - 
as well as testing the application code and configuration at every change.
This is a prerequisite for strong security - there are no stale, exposed components.
Applications run the latest, and auto testing makes sure it keeps working.

All external and internal communications is secured with mutual TLS with application-specific certificates.

All applications run on in dedicated and network isolated containers.

**Highlighted features**
* All communication is encrypted
* Encryption at rest
* Java 11
