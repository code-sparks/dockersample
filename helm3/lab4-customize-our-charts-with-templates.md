# Customize our charts

in this lab you will customize  using templates the yaml files in the movies-watchlist application

## Introduction

to enable our application to be reusable , meaning to be able to create multiple releases without collisions
we need to use templates, and custom values.yaml files to embed different values for kubernetes resource names. 

## Exercise

### Overview

- customizing  the movies-watchlist application
- adding template logic in  yaml files
- adding values.yaml files for each sub chart
- install a release of that chart

### Step by step

First, let's copy all the starter files frokm the lab  .

- `cp -r lab4-customize-our-charts-with-templates/movies-watchlist movies-watchlist/`

#### **Change all the resource names in all subcharts yaml files to the  following template `{{.Release.Name}}-{{.Chart.Name}}`**

for example :

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{.Release.Name}}-{{.Chart.Name}}
spec:
	...
	...
```

#### Add the relevant template logic to match the following values from the value files 

using the starter lab you got value files under each subchart 

In  the **database**  chart -> add template code to support  the **secret.yaml** file with the username and password and add template code to support the **database.yaml** with the image name and tag 

```yaml
secret:
  username: bW90aQ== #moti
  password: cGFzczEyMzQ= #pass1234
image: 
   name: "mysql"
   tag: "5.7"
```

In the **frontend** chart add template code to support : **frontend-config.yaml**  file with the  BACKEND_SERVICE_URI and MOVIES_SERVICE_URI properties  add template code to support the **frontend.yaml** with the image name and tag 

```yaml
config:
    BACKEND_SERVICE_URI: "http://localhost/"
    MOVIES_SERVICE_URI: "http://localhost/"
image: 
   name: "codesparks/examples-movies-watchlist-frontend"
   tag: "1.0"
```

In the **movies** chart add template code to support  **movies.yaml** with the image name and tag 

```yaml
image: 
   name: "codesparks/examples-movies-watchlist-movies"
   tag: "1.0"
```

In  the **users**  chart -> add template code to support  the **secret.yaml** file with the username and password and add template code to support the **users.yaml** with the image name and tag 

```yaml
image: 
   name: "codesparks/examples-movies-watchlist-users"
   tag: "1.0"
data:
  username: bW90aQ== #moti
  password: cGFzczEyMzQ= #pass1234
```

#### To make the subchart's services loosley coupled , split the ingress resource from the frontend service to three ingress resources to : frontend ,movies,and users subchart.

##### for example after the change the frontend ingress  should look like the following :

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{.Release.Name}}-{{.Chart.Name}}-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
  - http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: {{.Release.Name}}-{{.Chart.Name}}
            port:
              number: 3000
```



#### **deploy a release from the newly created chart**

run the following:

run helm templates to make sure that you dont have any type mistake

- `helm templates movie-watchlist/`

dry run and debug to see the output before installing

- ``helm install --debug --dry-run movieslist movie-watchlist/``

```html
please note that the users service is using the database service and needs to have it's host name, but because the host nam is now dynamic there will be a problem...it will be solved in the next lab
```

install the application 

- ``helm install movieslist movie-watchlist/``

get the manifest for the files

- `helm get manifest movieslist`

Try to reach it again like we did with the raw kubernetes objects application to begin with.

- `open the browser and navigate to localhost`

## Cleanup

Uninstall the application release with Helm:

```shell
$ helm uninstall movieslist
```
