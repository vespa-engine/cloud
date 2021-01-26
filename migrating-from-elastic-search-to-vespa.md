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


### Generate Vespa documents and Application Package
Use [ES_Vespa_parser.py](https://github.com/vespa-engine/vespa/tree/master/config-model/src/main/python)
to generate documents and configuration:

 ```
$ curl 'https://raw.githubusercontent.com/vespa-engine/vespa/master/config-model/src/main/python/ES_Vespa_parser.py' \
  > ES_Vespa_parser.py

$ python3 ./ES_Vespa_parser.py --application_name application bank_data.json bank_mapping.json
 ```

The document ids in `documents.json` will be like `id:application:_doc::1`,
the directory has now an `application` folder:

```
/application
      │     
      ├── documents.json
      ├── hosts.xml
      ├── services.xml
      └── /schemas
            ├── _doc.sd
            └── ... 
```



#### Deploy to Vespa
This tutorial have been tested with a Docker container with 6GB RAM.
`application` is mapped to /app in the Docker container.
Start the Vespa container:
 
```bash
$ docker run -m 6G --detach --name vespa --hostname vespa-es-tutorial \
  --privileged --volume `pwd`:/app \
  --publish 8080:8080 --publish 19112:19112 vespaengine/vespa
```

Wait for the configuration server to start - wait for a 200 OK response:

```bash
$ docker exec vespa bash -c 'curl -s --head http://localhost:19071/ApplicationStatus'
```

[Deploy](https://docs.vespa.ai/en/cloudconfig/application-packages.html#deploy)
the `application` package:

```bash
$ docker exec vespa bash -c '/opt/vespa/bin/vespa-deploy prepare /app/application && \
  /opt/vespa/bin/vespa-deploy activate'
``` 


Ensure the application is active - wait for a 200 OK response:

```
$ curl -s --head http://localhost:8080/ApplicationStatus
```

The Vespa node is now configured and ready for use.



#### Feed documents
Use the [vespa-http-client](https://docs.vespa.ai/en/vespa-http-client.html):

```bash
$ docker exec vespa bash -c 'java -jar /opt/vespa/lib/jars/vespa-http-client-jar-with-dependencies.jar \
    --verbose --file /app/application/documents.json --host localhost --port 8080'
```


#### Get a document
Get documents using the [Document API](https://docs.vespa.ai/en/document-v1-api-guide.html):

```bash
$ curl -s http://localhost:8080/document/v1/application/_doc/docid/1
```


#### Query documents
Use the [Query API](https://docs.vespa.ai/en/query-api.html) to count documents,
find `"totalCount": 1000` in the output, and run a text query:

```
$ curl -H "Content-Type: application/json" \
  --data '{"yql" : "select * from sources * where sddocname contains \"_doc\";"}' \
  http://localhost:8080/search/

$ curl -H "Content-Type: application/json" \
  --data '{"yql" : "select * from sources * where firstname contains \"amber\";"}' \
  http://localhost:8080/search/
```