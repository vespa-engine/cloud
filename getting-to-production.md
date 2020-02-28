---
title: Getting to Production
---

This guide assumes you have gone through the [Getting Started](/getting-started) guide and deployed
your application to the `dev` environment.  To complete this guide you need to have Maven 3.6.1
and Java 11 installed.

### Adding Java and Maven
To be able to deploy your application to the `prod` environment, your applications needs tests that
validate your application.  These tests are executed automatically on each deployment.  See
[Automated Deployments](/automated-deployments) for more information.

Below we are using the files that fit with [album-recommendation](https://github.com/vespa-engine/sample-apps/tree/master/vespa-cloud/album-recommendation),
the application used in the Getting Started guide.

1. Add a `pom.xml` file to the root of your application.  This is the Maven project configuration,
   and is needed to build with the Vespa Cloud test framework.  See this [example](https://github.com/vespa-engine/sample-apps/tree/master/vespa-cloud/album-recommendation-prod).

1. Add the tests that build the test framework.  These tests reside in the `src/test/java` directory
   of your application.  You can copy the sample tests that are in [this directory](https://github.com/vespa-engine/sample-apps/tree/master/vespa-cloud/album-recommendation-prod/src/test/java/ai/vespa/example).


### Adding deployment files
Vespa Cloud uses a file called `deployment.xml` to tell where your production deployments reside.
To get your application into the `prod.aws-us-east-1c` zone add `deployment.xml` at the root of
your application directory.

```xml
<deployment version="1.0">
    <prod>
        <region active="true">aws-us-east-1c</region>
    </prod>
</deployment>
```

### Deploying your application
Now you are ready to build the application and get it deployed.

1. Add the compile version information to your package:
   ```sh
   $ mvn clean vespa:compileVersion -DapiKeyFile=$HOME/Downloads/TENANTNAME.pem
   ```

1. Compile the applicaiton package with test artifacts:
   ```sh
   $ mvn -P fat-test-application package \
     -Dvespa.compile.version="$(cat target/vespa.compile.version)"
   ```

1. Submit the application package to Vespa Cloud for deployment:
   ```sh
   $ mvn vespa:submit -DapiKeyFile=$HOME/Downloads/TENANTNAME.pem
   ```

The application is now being deployed, and you can go to your applicaiton in the Console
and follow the progress of the deployment job running.

### Next steps
Now you have a running Vespa Cloud application running in a production zone.  Congratulations!  After this you can further enhance
your production application:

* Create a CI/CD pipeline (e.g. using GitHub Actions).
* Get BCP for your application by deploying in multiple zones and use a [global endpoint](/reference/deployment#endpoints).


### Removing your production deployment
**WARNING!** Following this guide will remove your production deployments and all data within them.  Your data is unrecoverable.

To safe-guard against accidentally removing your production applications, there are multiple steps involved in deprovisioning
your application.

1. Remove the deployment from your `deployment.xml` configuration file:
   ```xml
   <deployment version="1.0" />
   ```

1. Add a [`validation-overrides.xml`](https://docs.vespa.ai/documentation/reference/validation-overrides.html) file telling Vespa Cloud
   you intend to remove production deployments.
   ```xml
   <validation-overrides>
     <allow until="2020-02-28" comment="Removing aws-us-east-1c">deployment-removal</allow>
   </validation-overrides>

1. Build the application package and submit it as you would any deployment.
