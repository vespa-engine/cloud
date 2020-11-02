---
# Copyright Verizon Media. All rights reserved.
title: Developer Guide
---

Using the Developer Cloud is easy - deploy to it, and use the endpoints:

<img alt="Deploy and test using Developer Cloud" src="img/dev-guide-overview.svg" width="420" height="230" />

1. Build and deploy (e.g. using the [vespa-documentation-search](https://github.com/vespa-engine/sample-apps/tree/master/vespa-cloud/vespa-documentation-search)
sample application):

        $ mvn clean install package vespa:deploy -DapiKeyFile=/path-to/uname.tname.pem
        ...
        [INFO]     [11:18:30]  Found endpoints:
        [INFO]     [11:18:30]  - dev.aws-us-east-1c
        [INFO]     [11:18:30]  |-- https://uname.vespacloud-docsearch.tname.aws-us-east-1c.dev.public.vespa.oath.cloud/ (cluster 'default')
        [INFO]     [11:18:31]  Installation succeeded!

2. Query the endpoint(s):

        $ ENDPOINT=https://uname.vespacloud-docsearch.tname.aws-us-east-1c.dev.public.vespa.oath.cloud/
        $ curl --cert ./data-plane-public-cert.pem --key ./data-plane-private-key.pem ${ENDPOINT}document/v1/open/doc/docid/
    
Notes:
* The _User API key_ used to deploy the application to the Developer Cloud can be downloaded from the Console
  \- [key details](/security-model).
* The _Vespa API Certificate_ key/cert pair is used to access the endpoint(s).
  See the sample applications in [getting started](/getting-started) for how to generate key pairs.
  Endpoint(s) are printed by `vespa:deploy` and also found in the console in the _Devs_ section
* The [Vespa Cloud Sample Applications](https://github.com/vespa-engine/sample-apps/tree/master/vespa-cloud/)
  can be deployed as-is to your own Developer Cloud, and is a great starting point for application development.

Vespa Team recommends using a System Test to write code to access and test the endpoint,
in order to develop the application, like
[VespaDocSystemTest](https://github.com/vespa-engine/sample-apps/blob/master/vespa-cloud/vespa-documentation-search/src/test/java/ai/vespa/cloud/docsearch/VespaDocSystemTest.java).
This gets you started by feeding to and reading from an endpoint.
[Endpoint](https://github.com/vespa-engine/vespa/blob/master/tenant-cd-api/src/main/java/ai/vespa/hosted/cd/Endpoint.java)
is a class that defaults to a Developer Cloud Endpoint.
To submit applications to Production environments, use [automated deployments](/automated-deployments).
This means writing [System and Staging Tests](/reference/testing), so getting started with a System Test saves works.


## Deploying Applications to the Dev Cloud
Example (tenant name in this case is _mytenant_):

    $ cd github/vespa-engine/sample-apps/vespa-cloud/vespa-documentation-search/
    $ openssl req -x509 -nodes -days 14 -newkey rsa:4096 -subj "/CN=cloud.vespa.example" \
      -keyout data-plane-private-key.pem -out data-plane-public-cert.pem
    $ mkdir -p src/main/application/security && cp data-plane-public-cert.pem src/main/application/security/clients.pem
    $ mvn clean package vespa:deploy -DapiKeyFile=/tmp/myuser.mytenant.pem 

An instance can now be found at
_https://console.vespa.oath.cloud/tenant/mytenant/application/vespacloud-docsearch/devs_.
Here, no change is required to deploy an application to the private Dev Cloud -
only temporary credentials are added enabling access to the endpoints.
Deployment is using the [User API key](/security-model).


### Instances
To fully understand the flexibility in the Dev cloud, consider the deploy command:

    $ mvn clean package vespa:deploy -DapiKeyFile=/path-to/uname.tname.pem \
      -Denvironment=dev \
      -Dregion=aws-us-east-1c \
      -Dtenant=mytenant \
      -Dapplication=vespacloud-docsearch \
      -Dinstance=myuser

This is equivalent to the `vespa:deploy` at the start of the article:
* _environment_ and _region_ defaults to the Vespa Cloud [Dev zone](/reference/zones)
* _tenant_ and _application_ is normally set in `pom.xml`
* _instance_ defaults to local username

Hence, to deploy to more than one instance, either create a new application or deploy to a new instance.
Using multiple _instances_ is normally the easiest options as these are found in the same console views.


### Auto Downsizing
Deploying to the Dev Cloud is optimized for cost and simplicity -
it is for testing and development, and should normally be small.
Deploys are hence minimized by default, and deploying from a production config is safe.
Example - a production instance is using 5 nodes:

![prod](/img/resources-prod.png)

Deploying the application to the Dev Cloud (above) with no other changes gives:

![dev](/img/resources-dev.png)

Observe that there is only one of each node - the application is downsized -
no need to change node counts in [services.xml](/reference/services).


### Downsize override
It is possible to override the auto-downsize.
Set the [resources](reference/services#resources) and `require` them:

    <nodes count="10">
        <resources vcpu="10" memory="32Gb" disk="500Gb"/>
    </nodes>
    <nodes count="2" required="true" deploy:environment="dev" deploy:region="aws-us-east-1c" deploy:instance="myuser-test">
        <resources vcpu="0.5" memory="16Gb" disk="100Gb"/>
    </nodes>

This examples also illustrates use of
[zone-specific configuration](/reference/services#instance-environment-and-region-variants).
Instead of modifying the nodes element, add a new one specifically for the Dev Cloud instance.
One can hence keep both Production and Dev Cloud settings in the same file with no risk of deploying too much.


### Availability
The Dev Cloud is not built for production serving, as it has no uptime guarantees.
It is in fact optimized for rapid upgrades to latest Vespa version -
this to fast-track new features in Vespa - and will restart during upgrades.

An automated Vespa software upgrade can occur during `vespa:deploy` -
this pulls the latest - to override, deploy using:

    -Dvespa.runtime.version=<current deployed version>

Use with care, it is best practise to track the releases.



## Performance testing
When performance testing, one tests specific combinations of data, app configuration, node resources and load.
Use the `required`-attribute and zone-specific configuration to control the deployment and set up a test instance.

Read more in [benchmarking](/benchmarking).


## Pro tips / troubleshooting
* As Vespa Cloud upgrades daily, a deploy will some times pull the latest Vespa Version.
  This takes minutes as opposed to the seconds it normally takes.
  Start the day by deploying to avoid the wait!
* A common mistake is `pom.xml` mismatch. `tenant` and `application` is normally pulled from the pom -
  [details](/reference/vespa-cloud-api).
  Errors here cause a 401 when deploying
* Likewise for data plane -
  remember to copy the public sertificate to `src/main/application/security/clients.pem` before building and deploying.
* Set all keys in the IDE:
    
        -Dtest.categories=system
        -DapiKeyFile=/path-to/uname.tname.pem
        -DdataPlaneCertificateFile=/path-to/data-plane-public-cert.pem
        -DdataPlaneKeyFile=/path-to/data-plane-private-key.pem

  

## Vespa Cloud Console
![Dev Console](/img/console-dev.png)
