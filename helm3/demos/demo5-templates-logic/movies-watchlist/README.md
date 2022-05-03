welcome to the movies watchlist application

This application use nginx ingress  as an api gateway

1. it is important to make sure that nginx ingress is installed first you can install nginx by running:

​		helm upgrade --install ingress-nginx ingress-nginx  --repo https://kubernetes.github.io/ingress-nginx  --namespace ingress-nginx --create-namespace

2. you need to set up the host you are runing on for two properties:
   1. frontend.config.BACKEND_SERVICE_URI
   2. frontend.config.MOVIES_SERVICE_URI

the default host the gateway is  http://localhost/

if you wish to change the hosts and paths

use a yaml file like that :

database:
  secret:
    username: moti
    password: pass1234

frontend:
  ingress: 
    enabled: false

users:
  secret:
    username: moti
    password: pass1234
    databaseChart: database
  ingress: 
    enabled: false

movies:
  ingress: 
    enabled: false

ingress:
  - host:
      domain: localhost
      paths:  
        - path: "/"
          chart: frontend
          port: 3000
        - path: "/movies"
          chart: movies
          port: 8088
        - path: "/auth"
          chart: users
          port: 8080
        - path: "/watchlist"
          chart: users
          port: 8080



Helm install [release] [chart] -f file.yaml

important note is that if you change the host values you will need to restart to application because the properties are stored in a ConfigMap, and their changed value will not be considered until a restart