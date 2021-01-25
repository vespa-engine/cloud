---
# Copyright Verizon Media. All rights reserved.
title: Overload Handling
---

Handling overload comes down to two things:
* what to do prior to a load surge
* how to handle a current load surge

Checklist:
* Having a proper [Benchmark report](/benchmarking) is always helpful
  to understand expected behavior for different levels of load, i.e. where is the hockey stick.
* Some applications are updated from batch applications like Hadoop / Spark.
  It is easy to overload the Vespa instance by running too many clients / using too many connections.
  In these cases, tune parallelism down for correct utilization.
* Pre-define a light-weight rank profile for emergency use, enabled using a query profile -
  test this before it is used, update the benchmark report
* Run through a case where capacity is increased, then decreased, and get a sense of time constants.
  Test this regularly. This is done as part of regular operations, so easy to do   



## Configuration
Pre-configuring Vespa for overload handling makes handling load surge events easier.

<table class="table">
<tr><th style="white-space: nowrap">Rate limiting</th>
<td><p>This guide does not cover how to handle DOS-attacks,
    however such an attack can also be addressed by using
    <a href="https://docs.vespa.ai/en/performance/rate-limiting-searcher.html">Rate limiting</a>.
    Rate limiting assumes clients are separated by ID in requests.
    If the application does not use this, one can modify the 
    <a href="https://github.com/vespa-engine/vespa/blob/master/container-search/src/main/java/com/yahoo/search/searchers/RateLimitingSearcher.java">
    RateLimitingSearcher</a> for the use case.</p></td></tr>
<tr><th style="white-space: nowrap">Quality degradation</th>
<td><p>Many Vespa applications are resource-intensive,
    using <a href="https://docs.vespa.ai/en/ranking.html">two-phased ranking</a>
    to assign most resources to the best result candidates.
    A load surge can make queries time out -
    in such cases, returning results with less coverage can be a good tradeoff.
    </p><p>
    Some times, some results are better than no results.
    <a href="https://docs.vespa.ai/en/reference/query-api-reference.html#ranking.softtimeout">Softtimeout</a>
    returns the current result set at timeout, and the balance between first and second phase ranking is both 
    adaptive and configurable.
    </p><p>    
    Refer to <a href="https://docs.vespa.ai/en/graceful-degradation.html">Graceful degradation</a>
    for a description of how to use these features.
    </p><p>
    It is also a good idea to have an inexpensive rank profile pre-defined,
    and use <a href="https://docs.vespa.ai/en/query-profiles.html">query profiles</a>
    to define the default rank profile.
    By doing this, there is no need to change queries,
    just deploy a new application package with the light-weight rank profile as default.</p></td>
</tr>
</table>



## Addressing overload
Overload manifests in increased query latency and/or timeouts.
There are some hints in the
[open documentation](https://docs.vespa.ai/en/operations/admin-procedures.html#overload).
The key is to find which cluster is the bottleneck - a container or content cluster.
For this, use [CPU metrics](/monitoring).

<table class="table">
<tr><th style="white-space: nowrap">Container</th>
<td><p>Container clusters do not have state, and are easily scaled by adding
    <a href="/reference/services#resources">resources</a>.
    </p><p>
    The resource change is deployed as any other change,
    and production rollout can be managed in the console (e.g. skip tests, deploy in parallel)
    </p></td></tr>
<tr><th style="white-space: nowrap">Content</th>
<td><p>Content nodes have state (i.e document data and index),
    changes to resource allocations are hence more complex.
    Data is migrated using Vespa's
    <a href="https://docs.vespa.ai/en/elastic-vespa.html">elasticity</a> features.
    </p><p>
    A key observation is that during elastic operations,
    load <span style="text-decoration: underline;">increases</span> temporarily,
    as data migrate between nodes.
    </p><p>
    To get a feel for timing, it is advised to add a content node during normal operations,
    to see how long it takes for data to complete migration (use metrics as described in 
    <a href="https://docs.vespa.ai/en/elastic-vespa.html">elastic Vespa</a>).     
    </p></td></tr>
</table>

The Vespa Console lets users control where to route load,
useful if the overload is confined to a subset of zones.
This way, one can serve while building more capacity in other zones.
