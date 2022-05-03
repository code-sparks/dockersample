welcome to the movies watchlist application

This application use nginx ingress  as an api gateway

1. it is important to make sure that nginx ingress is installed first you can install nginx by running:

​		helm upgrade --install ingress-nginx ingress-nginx  --repo https://kubernetes.github.io/ingress-nginx  --namespace ingress-nginx --create-namespace

2. you need to set up the host you are runing on for two properties:
   1. frontend.config.BACKEND_SERVICE_URI
   2. frontend.config.MOVIES_SERVICE_URI

the default host the gateway is  http://localhost/

if you wish to change it you can --set the following value:

helm install --set frontend.config.BACKEND_SERVICE_URI=http://yourdomain/ --set frontend.config.MOVIES_SERVICE_URI=http://yourdomain/ mymovies movies-watchlist/

or use a yaml file like that :

frontend:

​		config:

​				MOVIES_SERVICE_URI: http://yourdomain/

​				BACKEND_SERVICE_URI: http://yourdomain/



Helm install [release] [chart] -f file.yaml

important note is that if you change the host values you will need to restart to application because the properties are stored in a ConfigMap, and their changed value will not be considered until a restart