# Create your first Helm Chart

Create a basic Helm chart for the `movies-suggestion`
application

## Introduction

This exercise will create a simple Helm chart for
the movie suggestion application. The chart will be
'simple' in the sense that it will not provide
support for customizing application parameters.

In the `lab1-movies-suggestion-app/` folder
we have Kubernetes YAML definitions for the 
microservices that make up the movies suggestion
application 

## Exercise

### Overview

- Running the movies suggestion on Kubernetes
- Create a basic Helm chart
- Copy `movies suggestion` kubernetes yaml into the chart
- install a release of that chart

### Step by step

**Deploy the movies suggestion application to Kubernetes**

first make sure the ingress-nginx.yaml is installed

`kubectl apply -f lab1-simple-helm-chart/ingress-nginx.yaml`

First, let's run the application in bare Kubernetes to see that our YAML is right.

- `kubectl apply -f ab1-simple-helm-chart/movie-suggestion/k8s/`

This will create the microservice deployments
with a single POD instance each, and an ingress resource that expose the frontend

**Test the deployed application**

- `kubectl get pods`

To get a movie suggestion movie suggestion
application, use curl with the localost as the host that the ingress is listening on

- open the browser and navigate to localhost

**Create a skeleton Helm chart**

First we create a new directory for our Helm chart, and then use the `helm create` command to create the chart skeleton:

- `mkdir movie-suggestion`
- `cd movie-suggestion`

1. create a **Chart.yaml** file and add it in the root of the **movie-suggestion** directory

   ```yaml
   apiVersion: v1
   name: movies-suggestion
   appVersion: "1.0"
   description: Movie Suggestion 1.0
   version: 1.1.0
   type: application
   ```

2. create a **templates** directory under the movie-suggestion-helm

3. Next, we copy the original Kubernetes YAML files to the templates folder

   

#### **deploy a releaset from the newly created chart**

run the following:

- `helm install moviesuggestion movie-suggestion/`

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

## Cleanup

Uninstall the application release with Helm:

```shell
$ helm uninstall moviesuggestion
```
