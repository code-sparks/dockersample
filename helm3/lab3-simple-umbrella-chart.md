# Create your first Helm umbrella Chart

Create a simple  umbrella chart for the `movies-watchlist`
application

## Introduction

This exercise will create a simple Helm umbrella chart for
the movie watchlist application. The chart will be
'simple' in the sense that it will not provide
support for customizing application parameters.

In the `lab3-simple-umbrella-chart/` folder
we have Kubernetes YAML definitions for the 
microservices that make up the movies watchlist
application 

## Exercise

### Overview

- Running the movies watchlist on Kubernetes
- Create a basic umbrella Helm chart
- Copy `movies watchlist` kubernetes yaml into the chart
- install a release of that chart

### Step by step

**Deploy the movies watchlist application to Kubernetes**

First, let's run the application in bare Kubernetes to see that our YAML is right.

- `kubectl apply -f lab3-simple-umbrella-chart/movie-watchlist-k8s-files`

This will create the microservice deployments
with a single POD instance each, and an ingress resource that expose the frontend

**Test the deployed application**

- `kubectl get pods`

To see the application up and running

- open the browser and navigate to localhost

**delete the application  **

`kubectl delete -f lab3-simple-umbrella-chart/movie-watchlist-k8s-files`



**Create a skeleton Helm chart**

First we create a new directory for our Helm chart, and then use the `helm create` command to create the chart skeleton:

- `mkdir movies-watchlist`
- `cd movies-watchlist`

1. create a **Chart.yaml** file and add it in the root of the **movie-watchlist** directory

   ```yaml
   apiVersion: v2
   name: movies-watchlist
   appVersion: "1.0"
   description: A Helm chart for Movie Watchlist 1.0
   version: 1.0.0
   type: application
   ```

2. create a **charts** directory under the movies-watchlist directory

3. Next,copy all folders from the `lab3-simple-umbrella-chart/subcharts` under the **movie-watchlist/charts** directory


you should get the following directory structure:

     movies-watchlist
    ├── Chart.yaml
    └── charts
        ├── database
        │   ├── Chart.yaml
        │   └── templates
        ├── frontend
        │   ├── Chart.yaml
        │   └── templates
        ├── movies
        │   ├── Chart.yaml
        │   └── templates
        └── users
            ├── Chart.yaml
            └── templates

apiVersion: v2
name: movies-watchlist
appVersion: "1.0"
description: A Helm chart for Movie Watchlist 1.0
version: 1.0.0
type: application

#### **deploy a releaset from the newly created chart**

run the following:

- `helm install movieslist movie-watchlist/`

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

- `helm get all movieslist`

In our case this will be identical to the YAML
files we copied previously since we haven't
provided any means of customizing the application
installation.

Try to reach it again like we did with the raw kubernetes objects application to begin with.

- `open the browser and navigate to localhost`

## Cleanup

Uninstall the application release with Helm:

```shell
$ helm uninstall movieslist
```
