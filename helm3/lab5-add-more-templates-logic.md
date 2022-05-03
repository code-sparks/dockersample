# Adding Templates Logic

in this lab you will enahance and improove the movies-watchlist application by adding more fine tuned template logic to be able to control the values in the yaml files in a more generic way  and solve the name dependency problems between charts.

## Introduction

in the previous lab we added the {{.Release.Name}}-{{.Chart.Name}} template for every kubernetes resource name, this code duplication can be a limitation, especially if at some point we need to change it .

to overcome that issue we will create template logic as functions in a centeral place to the chart , and will reuse that functions in the yaml files.

sometimes having multiple ingress resources is not desirable,especially when you need to pay for every load balancer that is created for each ingress.

another change that we will add, is to control the ingress resources in a conditional way.

we will be able to choose multiple ingress for each service subchart, or one main ingress for all subchart controlled in the main chart.

## Exercise

### Overview

- Add  _helpers.tpl file for each subchart of the  movies-watchlist application
- create reusable template functions to be used on the yaml files
- Create a general ingress file as the main ingress for the application
- fix the database name issue from previous lab
- install a release of that chart

### Step by step

First, let's copy all the starter files frokm the lab  .

- `cp -r lab5-simple-umbrella-chart/movies-watchlist movies-watchlist/`

#### Add helpers file containing template functions 

1. for every templates directory of the subcharts , add an _helpers.tpl file with a template function that wraps the logic for the name of the resources in the chart for example for the frontend add the following template function in it's _helpers.tpl file:

```yaml
{{- define "frontend.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
```

to the same for each subchart just make sure to change the name of the function for example for the database subchart it will be `database.fullname ` for users subchart it will be `users.fullname`and for movies it will be `movies.fullname`

change **in all** **subcharts** the template logic to use that function for example the movies service should look like that now:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ include "movies.fullname" .}}
  labels:
    app: {{ include "movies.fullname" .}}
spec:
  ports:
    - port: 8088
      name: http
  selector:
    app: {{ include "movies.fullname" .}}
```

  

2 . to solve the problem of getting to the database host name from the users service,  add the following to the users _helpers.tpl file

```yaml
{{- define "users.database" -}}
{{- if .Values.databaseOverride -}}
{{- .Values.databaseOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name .Values.secret.databaseChart | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
```

 now update the logic in the **users secret.yaml** file to use the `users.database` function and also update the logic to base64 the username and password

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "users.fullname" .}}-auth
type: Opaque
data:
  username: {{.Values.secret.username | b64enc | quote }}
  password: {{.Values.secret.password | b64enc | quote}}
  sqlhost: {{ (include "users.database" .) | b64enc | quote}}
```

3. update the logic to base64 the username and password for in database subchart's **secret.yaml** file as well

   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: {{ include "database.fullname" .}}-auth
   type: Opaque
   data:
     username: {{.Values.secret.username | b64enc | quote}}
     password: {{.Values.secret.password | b64enc | quote}}
   
   ```

   

#### Add a a ingress  

under the main chart's templates directory (movies-watchlist/templates) , add an an ingress.yaml file with the following logic

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
{{- range .Values.ingress }}
  - host: {{ .host.domain }}
    http:
      paths:
      {{- range .host.paths }}
      - pathType: Prefix
        path: {{.path}}
        backend:
          service:
            name: {{ $.Release.Name}}-{{ .chart }}
            port: 
              number: {{.port}}
      {{- end }}
{{- end }}
```

in the users,database and frontend subchart update the logic to include the ingress resource only if the ingress.enabled value is true

```yaml
{{- if .Values.ingress.enabled}}
...
...
{{- end}}
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
