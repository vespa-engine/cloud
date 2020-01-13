---
# Copyright 2020 Oath Inc. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
title: "Comparison to Elasticsearch"
---

<div style="text-align:left">
<img src="img/Vespa-ES.png" style="width: 50%; margin-right: 1%; margin-bottom: 0.8em;" alt="Venn diagram">
</div>

With focus on big data serving, Vespa is optimized for **low millisecond response**,
**high write and query load**, **Machine Learning integration** and **automated high availability operations**.
Vespa support true realtime writes, and true partial updates, and is also easy to operate at large scale.
Read more on Vespa's [features](https://docs.vespa.ai/documentation/features.html).

Vespa is the only open source platform optimized for such big data serving.



## Analytics vs. Big Data Serving
To decide whether Elasticsearch or Vespa is the right choice for a use case,
consider if it needs to be optimized for analytics or serving.

<table class="table table-striped" style="text-align:center">
<tr><td><b>Analytics</b></td><td><b>Big data serving</b></td></tr>
<tr><td>Response time in low seconds</td><td>Response time in low milliseconds</td></tr>
<tr><td>Low query rate</td><td>High query rate</td></tr>
<tr><td>Time series, append only</td><td>Random writes</td></tr>
<tr><td>Down time, data loss acceptable</td><td>High availability, no data loss, online redistribution</td></tr>
<tr><td>Massive data sets (trillion of docs) are cheap</td><td>Massive data sets are more expensive</td></tr>
<tr><td>Analytics GUI integration</td><td>Machine learning integration</td></tr>
</table>



## Scaling
The fundamental unit of scale in Elasticsearch is the shard.
Sharding allows scale out by partitioning the data into smaller chunks that can be distributed across a cluster of nodes.
The challenge is to figure out the right number of shards, because you only get to make the decision once per index.
And it impacts both performance, storage and scale, since queries are sent to all shards.
So how many shards are the right number of shards?

In Vespa you do not have to worry about the number of shards and re-sharding. Vespa will take care of that.
You have a cluster of nodes, and you can add or remove nodes without resharding,
which means no downtime for resharding. 

Vespa allows applications to grow (and shrink) their hardware while serving queries and accepting writes as normal.
Data is automatically redistributed in the background using the minimal amount of data movement.
No restarts or other operations are needed,
just change the hardware listed in the configuration and redeploy the application.

For a detailed guide on how to set up a multinode Vespa system see
[Multi-Node Quick Start](https://docs.vespa.ai/documentation/vespa-quick-start-multinode-aws.html).

Other relevant sources:

* [Vespa Elasticity](https://docs.vespa.ai/documentation/elastic-vespa.html)
* [Vespa sizing guide](https://docs.vespa.ai/documentation/performance/sizing-search.html)
* [Migrating from Elasticsearch to Vespa](migrating-from-elastic-search-to-vespa.html)
