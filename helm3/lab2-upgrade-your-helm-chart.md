# Upgrade your  Helm Chart

Create a new revision for **moviessuggestion** the  of the Helm chart  `movies-suggestion`
you created in the previous lab

## Introduction

This exercise will create a new revision for the simple Helm chart you created

In the `lab2-upgrade-your-helm-chart/` folder
we added more Kubernetes YAML definitions for the 
upgraded version of the movies suggestion
application 

## Exercise

### Overview

- Upgrade your a basic Helm chart

### Step by step

**update your chart folder with the new files**

Add the additional files from the `upgrade-your-helm-chart/` folder into your movie-suggestion/ chart folder

update your Chart.yaml file to reflect the new appVersion and chart Version

```yaml
apiVersion: v2
name: moviessuggestion
appVersion: "2.0"
description: A Helm chart for Movie Suggestion 2.0
version: 0.2.0
type: application
```

#### **upgrade the releaset from the newly created chart**

run the following:

- `helm upgrade moviesuggestion movie-suggestion/`

Running this command produces the following output:

```shell
NAME: moviesuggestion
LAST DEPLOYED: Wed Apr 21 10:43:55 2021
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

To see all the different objects that Helm has
created, use:

```shell
$ kubectl get pods,services,deployments
```

To see the applications installed with Helm use
the `helm ls` operation:

- `helm ls`

To see the Kubernetes YAML which Helm used to
install the application use the `helm get`
operation:

- `helm get all moviesuggestion`

In our case this will be identical to the YAML
files we copied previously since we haven't
provided any means of customizing the application
installation.

Try to reach it again like we did with the raw kubernetes objects application to begin with.

- `open the browser and navigate to localhost`

**watch all release revisions** 

- `helm history movissuggesion`

## Cleanup

Uninstall the application release with Helm:

```shell
$ helm uninstall moviesuggestion
```
