---
# Copyright 2020 Oath Inc. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
title: "Migrating from Elasticsearch to Vespa"
---

This is a guide for how to move data from Elasticsearch to Vespa.
By the end of this guide you will have generated a deployable Vespa application package
from an Elasticsearch cluster.
To consider whether Vespa is a better choice for your use case,
take a look at the [comparison](elastic-search-comparison.html)



#### 1. Get all documents from Elasticsearch with ElasticDump
It is possible to use [ElasticDump](https://github.com/taskrabbit/elasticsearch-dump)
to get all documents from Elasticsearch in a JSON-file. Assuming starting in a empty folder.

```
$ git clone --depth 1 https://github.com/taskrabbit/elasticsearch-dump.git
```
 
Then get all documents and mapping from your cluster(s) with:

```bash
$ `pwd`/elasticsearch-dump/bin/elasticdump \
  --input=http://localhost:9200/my_index \
  --output=/path/to/empty/folder/my_index.json \
  --type=data

$ `pwd`/elasticsearch-dump/bin/elasticdump \
  --input=http://localhost:9200/my_index \
  --output=/path/to/empty/folder/my_index_mapping.json \
  --type=mapping
``` 

 * `--input` should be the url to your Elasticsearch index
 * `--output` should be the path to your intially empty folder



#### 2. Parse the ES-documents to Vespa-documents and generate an Application Package
Download [ES_Vespa_parser.py](https://github.com/vespa-engine/vespa/tree/master/config-model/src/main/python),
and place it in your intitially empty directory. Usage:

 ```
$ ES_Vespa_parser.py [-h] [--application_name APPLICATION_NAME] documents_path mappings_path
 ```

Run this command in your folder to parse the documents, so that it can be fed to Vespa:

```
$ python ES_Vespa_parser.py my_index.json my_index_mapping.json
```

* `--application_name` defaults to "application_name" - just change if you want
  * The document ids will become *id:`application_name`:`doc_name`::`elasticsearch_id`*

The directory has now a folder `application`:

```
/application
      │     
      ├── documents.json
      ├── hosts.xml
      ├── services.xml
      └── /searchdefinitions
            ├── sd1.sd
            └── ... 
```
Which contains the converted documents, their search definitions, a hosts.xml and a services.xml -
a whole application package.



#### 3. Deploying Vespa
Go into the initially empty folder. This tutorial have been tested with a Docker container with 10GB RAM.
We will map the this directory into the /app directory inside the Docker container.
Start the Vespa container:
 
```bash
$ docker run -m 10G --detach --name vespa --hostname vespa-es-tutorial \
    --privileged --volume `pwd`:/app \
    --publish 8080:8080 --publish 19112:19112 vespaengine/vespa
```

Make sure that the configuration server is running:

```bash
$ docker exec vespa bash -c 'curl -s --head http://localhost:19071/ApplicationStatus'
```

Deploy the `application` package:

```bash
$ docker exec vespa bash -c '/opt/vespa/bin/vespa-deploy prepare /app/application && \
    /opt/vespa/bin/vespa-deploy activate'
``` 

(or alternatively, run the equivalent commands inside the docker container).
After a short while, pointing a browser to _http://localhost:8080/ApplicationStatus_
returns JSON-formatted information about the active application.
The Vespa node is now configured and ready for use.

More details for
[deploying application packages](https://docs.vespa.ai/documentation/cloudconfig/application-packages.html#deploy).



#### 4. Feeding the parsed documents to Vespa
Send this to Vespa using one of the tools Vespa provides for feeding.
In this part of the tutorial, the [Java feeding API](https://docs.vespa.ai/documentation/vespa-http-client.html) is used:

```bash
$ docker exec vespa bash -c 'java -jar /opt/vespa/lib/jars/vespa-http-client-jar-with-dependencies.jar \
    --verbose --file /app/application/documents.json --host localhost --port 8080'
```

Inspect the search node state using:
`$ docker exec vespa bash -c '/opt/vespa/bin/vespa-proton-cmd --local getState'`



#### 5. Fetching documents
Fetch documents by document id using the [Document API](https://docs.vespa.ai/documentation/document-api-guide.html):

```bash
$ curl -s http://localhost:8080/document/v1/application_name/doc_name/docid/elasticsearch_id
```



#### 6. The first query
Use the GUI for building queries at _http://localhost:8080/querybuilder_
(with Vespa-container running) which can help you building queries with e.g. autocompletion of YQL.
Also take a look at the [query API](https://docs.vespa.ai/documentation/search-api.html).



## Feeding
Vespa can be fed with either [Vespa Http Feeding Client](https://docs.vespa.ai/documentation/vespa-http-client.html)
or using [Hadoop, Pig, Oozie](https://docs.vespa.ai/documentation/feed-using-hadoop-pig-oozie.html).

The Vespa Http Feeding Client is a Java API and command line tool to feed document operations to Vespa.
The Vespa feedig client allows you to combine high throughput with feedig over HTTP.

Add the `<document-api>` to a container cluster to enable it to receive documents:

```
<?xml version="1.0" encoding="utf-8" ?>
<services version="1.0">

  <container version="1.0" id="default">
     <document-api/>
  </container>

</services>
```

Use the [Vespa HTTP Client](https://docs.vespa.ai/documentation/vespa-http-client.html) API / binary.
It supports feeding document operations and is installed with Vespa -
found at `$VESPA_HOME/lib/jars/vespa-http-client-jar-with-dependencies.jar`. Example: 

```
$ java -jar $VESPA_HOME/lib/jars/vespa-http-client-jar-with-dependencies.jar \
  --file file.json --endpoint http://document-api-host:8080
```
