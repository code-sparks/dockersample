
## create a couple of VMs using docker-machine, using the VirtualBox driver
	docker-machine create --driver virtualbox myvm1
	docker-machine create --driver virtualbox myvm2
	
	#list the machines
	docker-machine ls


## INITIALIZE THE SWARM AND ADD NODES 
	#get the ip of the machine
	$docker-machine ip myvm1
	
	#join myvm1 as a manager
	$ docker-machine ssh myvm1 "docker swarm init --advertise-addr <myvm1 ip>"
	Swarm initialized: current node <node ID> is now a manager.	
	
## add  NODE2 (Linux)
	#get the ip of the machine
        $docker-machine ip myvm2
	#join myvm2 as a worker
	$ docker-machine ssh myvm2 "docker swarm join --token <token><ip>:2377"	

# The following commands can be used to obtain a copy of the stackfile. 
	curl -o stackfile.yml https://raw.githubusercontent.com/dockersamples/example-voting-app/master/docker-stack.yml

# Verify that the stack file (stackfile.yml) is present in your working directory
ls -l

# point your docker cli to the myvm1 manager deamon
	eval $(docker-machine env myvm1)	

# Deploy a new stack from the stack file (Stackfile.yml
	docker stack deploy -c stackfile.yml voter

# List running stacks and list individual services in the stack	
	docker stack ls
	docker stack ps voter
	docker stack services voter
    
# View the app (stack) in a browser
	Open a new browser tab and enter the IP address of any node in you Swarm cluster.
	Append :5000 to the end of the IP address. This will load the voting page of the app.
	Change to port :5001 and the then to :8080
	################################
	# A few things to note:
	# - You will need to use an IP address of a Swarm node that you can reach (ping)
	# - If you are using plat-with-docker.com you can click on the port-number links that appear at the top of the page. There
	#    will be links for for :5000, :5001, and :8080. Clicking these will open new browser tabs.
	################################


# Imperatively scale the "vote" service from 2 to 20
	docker service scale voter_vote=20

# Verify the operation succeeded
	docker stack services voter

# Verify that the new desired state of 20 replicas for the voter_vote service is recorded on the Swarm
	docker service inspect voter_vote --pretty

# See if the new desired state of 20 replicas of the voter_vote service is recorded in the stack file (stackfile.yml). It will not be.
	vim stackfile.yml
	
# Alter the desired state in the stack file (Stackfile.yml) to be 10 replicas for the voter_vote service  To do this, change the "replicas" property to "10" as shown in the last line of config file below and then save the file
	  vote:
		image: dockersamples/examplevotingapp_vote:before
		ports:
			- 5000:80
		networks:
			- frontend
		depends_on:
			- redis
		deploy:
			replicas: 10
			
# Update the stack using the same "docker stack deploy..." command used to initially deploy the stack.
	docker stack deploy -c stackfile.yml voter

# Verify the current observed state of the Swarm. It will show as 10 (or it may be part way through making the change)
	docker stack services voter

# Verify the new desired state of 10 replicas is stored in the Swarm
	docker service inspect voter_vote --pretty

# Verify that at least one replica of the voter_vote service is running on each node in the Swarm
	docker service ps voter_vote

# Shutdown one of the Swarm nodes (one with a service replica running on it
	How you do this will depend on your lab configuration
	
# Verify that Swarm has recovered the app (there should still be 10 replicas running for the voter_vote service)
	docker stack services voter
	



