---
# Copyright 2019 Oath Inc. All rights reserved.
title: "Performance Use Cases"
---

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

Vespa supports a wide range of ML models by transforming them to [tensors](https://docs.vespa.ai/documentation/tensor-user-guide.html) -
and uses [LLVM](https://llvm.org) for high-performance ranking.

Read more in [Vespa Performance](https://docs.vespa.ai/documentation/performance/).

**Highlighted features**
* Huge content node memory support, including vespa-malloc
* Tensor representation
* Performance groups
* Sustained throughput for document partial updates
* Data structures uses chunked memory - low peak-to-average gives better utilization, lower costs and small compaction footprint
* LLVM



## Graceful peak load handling
It is hard to size an application for the highest possible load peak.
Unexpected things happen.
Instead of allocating idle resources for peak loads that almost never happen,
a good tradeoff is degrading relevance quality, requiring less coverage.
This keeps cost under control, still serving useful results during high peaks.

**Highlighted features**
* [Coverage / Ranking degradation](https://docs.vespa.ai/documentation/graceful-degradation.html)
* Soft timeout returns results at timeout - _some_ results are better than none



## Multithread search
Most engines are multi-threaded to fully utilize the computing resources.
In Vespa, the data layout on disk is fully orthogonal to threads used per query.
It is hence easy to increase number of threads used per query without having to redistribute data.
Balance capacity requirements, query latency and throughput by tuning
[num-threads-per-search](https://docs.vespa.ai/documentation/reference/search-definitions-reference.html#num-threads-per-search).

**Highlighted features**
* True multi-thread queries
