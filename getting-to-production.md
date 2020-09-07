---
title: Getting to Production
---

This guide assumes you have gone through the [Quick Start](/vespa-cloud-quick-start) 
and deployed an application to the `dev` environment.
To complete this guide you need to have Maven 3.6.1 and Java 11 installed.

Also try the [album-recommendation-searcher](/album-recommendation-searcher) guide -
this is a complete production deployment guide.


### Adding Java and Maven
To be able to deploy an application to the `prod` environment,
the application needs tests that validate it.
These tests are executed automatically on each deployment -
see [Automated Deployments](/automated-deployments).

Below we are using the files that fit with [album-recommendation](https://github.com/vespa-engine/sample-apps/tree/master/vespa-cloud/album-recommendation),
the application used in the Getting Started guide.

1. Add a `pom.xml` file to the application root.
    This is the Maven project configuration, and is needed to build with the Vespa Cloud test framework.
    See this [example](https://github.com/vespa-engine/sample-apps/tree/master/vespa-cloud/album-recommendation-prod).

1. Update the `tenant` and `application` properties in `pom.xml` to match the names for your tenant and application.
   ```xml
   ...
   <properties>
     ...
     <tenant>MYTENANT</tenant>
     <application>MYAPP</tenant>
   </properties>
   ...
   ```

1. Add the tests that build the test framework.
    These tests reside in the `src/test/java` directory of the application.
    You can copy the sample tests that are in
    [this directory](https://github.com/vespa-engine/sample-apps/tree/master/vespa-cloud/album-recommendation-prod/src/test/java/ai/vespa/example).


### Adding deployment files
Use [`deployment.xml`](/reference/deployment)  to configure production deployments.
To deploy the application to the `prod.aws-us-east-1c` zone, add `deployment.xml`,
together with [`services.xml`](/reference/services) in `src/main/application`.

```xml
<deployment version="1.0">
    <prod>
        <region active="true">aws-us-east-1c</region>
    </prod>
</deployment>
```

### Deploying the application
Now you are ready to build and deploy the application:

1. Add the compile version information to the application package:
   ```sh
   $ mvn clean vespa:compileVersion -DapiKeyFile=$HOME/Downloads/TENANTNAME.pem
   ```

1. Compile the application package with test artifacts:
   ```sh
   $ mvn package \
     -Dvespa.compile.version="$(cat target/vespa.compile.version)"
   ```

1. Submit the application package to Vespa Cloud for deployment:
   ```sh
   $ mvn vespa:submit -DapiKeyFile=$HOME/Downloads/TENANTNAME.pem
   ```

The application is now being deployed -
track progress of the deployment job in the Vespa Cloud Console.


### Next steps
The Vespa Cloud application is now running in a production zone.  Congratulations!
After this you can further enhance the production application:

* Create a CI/CD pipeline (e.g. [using GitHub Actions](https://github.com/vespa-engine/sample-apps/blob/master/.github/workflows/deploy-vespa-documentation-search.yaml))
* For failover, deploy in multiple zones and use a [global endpoint](/reference/deployment#endpoints)


### Removing a production instance
**WARNING!** Following this guide will remove production instances and all data within them.
The data is unrecoverable.

To safe-guard against accidentally removing production applications,
there are multiple steps involved in deprovisioning an application:

1. Remove the deployment from `deployment.xml`:
   ```xml
   <deployment version="1.0" />
   ```

1. Add a [`validation-overrides.xml`](https://docs.vespa.ai/documentation/reference/validation-overrides.html) file.
   This will allow Vespa Cloud to remove production deployments:
   ```xml
   <validation-overrides>
     <allow until="2020-02-28" comment="Removing aws-us-east-1c">deployment-removal</allow>
   </validation-overrides>
   ```

1. Build the application package and submit as normal
