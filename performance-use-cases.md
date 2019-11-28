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
