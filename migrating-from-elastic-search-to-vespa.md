---
# Copyright Verizon Media. All rights reserved.
title: Migrating from Elasticsearch
---

This is a guide for how to move data from Elasticsearch (ES) to Vespa.
By the end of this guide you will have generated a deployable Vespa application package.
To consider whether Vespa is a better choice for your use case,
take a look at the [comparison](elastic-search-comparison.html)

Vespa provides a helper conversion script for basic conversion of ES data and mappings
to Vespa data and configuration.
<!-- ToDo: more details on what is in an app package and a link ...  -->


### Feed a sample ES index
Set up an index with 1,000 sample documents using
[getting-started-index](https://www.elastic.co/guide/en/elasticsearch/reference/7.9/getting-started-index.html)
or skip this part if you have an index:

```
$ docker network create --driver bridge esnet

$ docker run --rm --name esnode --network esnet -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" \
  docker.elastic.co/elasticsearch/elasticsearch:7.10.2

$ curl 'https://raw.githubusercontent.com/elastic/elasticsearch/master/docs/src/test/resources/accounts.json' \
  > accounts.json

$ curl -H "Content-Type:application/json" --data-binary @accounts.json 'localhost:9200/bank/_bulk?pretty&refresh'

$ curl 'localhost:9200/_cat/indices?v'
```
The last command should indicate 1,000 documents in the index.


### Dump documents from ES
Refer to [ElasticDump](https://github.com/elasticsearch-dump/elasticsearch-dump) for details.

```
$ cat > dumpit.sh << EOF
npm install elasticdump
/dump/node_modules/.bin/elasticdump --input=http://esnode:9200/bank --output=bank_data.json    --type=data
/dump/node_modules/.bin/elasticdump --input=http://esnode:9200/bank --output=bank_mapping.json --type=mapping
EOF

$ docker run --rm --name esdump --network esnet -v "$PWD":/dump -w /dump node:alpine sh dumpit.sh

$ docker network remove esnet
```


### Parse the ES-documents to Vespa-documents and generate an Application Package
Download [ES_Vespa_parser.py](https://github.com/vespa-engine/vespa/tree/master/config-model/src/main/python),
and place it in your intitially empty directory. Usage:

 ```
$ curl 'https://raw.githubusercontent.com/vespa-engine/vespa/master/config-model/src/main/python/ES_Vespa_parser.py' \
  > ES_Vespa_parser.py

$ python3 ./ES_Vespa_parser.py --application_name application bank_data.json bank_mapping.json
 ```

The document ids will become *id:`application_name`:`doc_name`::`elasticsearch_id`*

The directory has now a folder `application`:

```
/application
      │     
      ├── documents.json
      ├── hosts.xml
      ├── services.xml
      └── /schemas
            ├── sd1.sd
            └── ... 
```
Which contains the converted documents, their schemas, a hosts.xml and a services.xml -
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
[deploying application packages](https://docs.vespa.ai/en/cloudconfig/application-packages.html#deploy).



#### 4. Feeding the parsed documents to Vespa
Send this to Vespa using one of the tools Vespa provides for feeding.
In this part of the tutorial, the [Java feeding API](https://docs.vespa.ai/en/vespa-http-client.html) is used:

```bash
$ docker exec vespa bash -c 'java -jar /opt/vespa/lib/jars/vespa-http-client-jar-with-dependencies.jar \
    --verbose --file /app/application/documents.json --host localhost --port 8080'
```

Inspect the search node state using:
`$ docker exec vespa bash -c '/opt/vespa/bin/vespa-proton-cmd --local getState'`



#### 5. Fetching documents
Fetch documents by document id using the [Document API](https://docs.vespa.ai/en/document-api-guide.html):

```bash
$ curl -s http://localhost:8080/document/v1/application_name/doc_name/docid/elasticsearch_id
```



#### 6. The first query
Use the GUI for building queries at _http://localhost:8080/querybuilder_
(with Vespa-container running) which can help you building queries with e.g. autocompletion of YQL.
Also take a look at the [query API](https://docs.vespa.ai/en/query-api.html).



## Feeding
Vespa can be fed with either [Vespa Http Feeding Client](https://docs.vespa.ai/en/vespa-http-client.html)
or using [Hadoop, Pig, Oozie](https://docs.vespa.ai/en/feed-using-hadoop-pig-oozie.html).

The Vespa Http Feeding Client is a Java API and command line tool to feed document operations to Vespa.
The Vespa feedig client allows you to combine high throughput with feeding over HTTP.

Add the `<document-api>` to a container cluster to set up a feed endpoint:

```
<?xml version="1.0" encoding="utf-8" ?>
<services version="1.0">

  <container version="1.0" id="default">
     <document-api/>
  </container>

</services>
```

Use the [Vespa HTTP Client](https://docs.vespa.ai/en/vespa-http-client.html) API / binary.
It supports feeding document operations and is installed with Vespa -
found at `$VESPA_HOME/lib/jars/vespa-http-client-jar-with-dependencies.jar`. Example: 

```
$ java -jar $VESPA_HOME/lib/jars/vespa-http-client-jar-with-dependencies.jar \
  --file file.json --endpoint http://document-api-host:8080
```
