Docker Containers
=================

Part1: Create 2 Containers in a VM 
-----------------------------------

###Virtual Machine
	(1) Set up a Virtual machine with the base image of Ubuntu 14.04 with 2048 	   MB of RAM and 10GB of hard disk space using Virtual Box. 
	(2) Install Docker on it:
		https://docs.docker.com/engine/installation/linux/ubuntulinux/

###Container Images
	(1)Create the Container Image:
>	     docker build  --tag mongo/img . 

	(2) List Docker Images
>	     docker images

###Creating Containers  
	(1) Create Container 1 (Primary Mongo Node):
>	    docker run –p 28001:27017 --name cntr1 --hostname="mongo1.server" -d 
		mongo/img --replSet mset --noprealloc –smallfiles

	(2) Create Container 2 (Secondary Mongo Node):
>		docker run –p 28002:27017 --name cntr2 --hostname="mongo2.server" -d 		 mongo/img --replSet mset --noprealloc –smallfiles



Part2: Create the MongoDB ReplicaSet
------------------------------------

###Run mongoscript.sh
    /bin/bash myscript.sh 

###What does this script do? 
	(1) In order for the secondary mongodb instance to sync up with the 		primary mongodb instance, it is required to update the /etc/hosts 		files on each of the two containers 
	(2) ‘mongoscript.sh’ is used to update the /etc/hosts files and also to 	run the mongodb steps of initialization. This script creates a text 	file, addr.txt which is populated after inspecting the docker 			containers and getting their IP addresses
	(3) It also creates another shell script, which is copied and run on each 	  of the containers to change their /etc/hosts file and add the required 	 entries

###Test Steps
	(1) Check /etc/hosts on both the containers
>		(a) docker exec -it cntr1 /bin/bash
			cat /etc/hosts
		(b) docker exec -it cntr2 /bin/bash
			cat /etc/hosts
		You will see that these entries have been added to the /etc/hosts files of both the containers: 
		    <ip of primary> mongo1.server 
		    <ip of secomdary> mongo2.server
	(2) Check the member status of Primary and Secondary on each of the 		containers:
			rs.status().members
	(3) On Primary: 
			db.testdata.save({test1:"TestDataAdditionOnPrimary"})
		Data is added successfully to the DB 
	(4) On Secondary: 
			db.testdata.save({test2:"TestDataAdditionOnSecondary"})
		Unsuccessful as Data addition is not possible on the Secondary Mongo Node
	(5) On Secondary: 
			db.testdata.find()
		Value of 'test1' set on the Primary shows up --> Replica Set creation successful

NOTE: 'addr.txt' and 'addhost.sh' are automatically created. They are both created on the VM and then copied to the Docker containers. 'addhost.sh' is run in the docker containers from within the 'mongoscript.sh'

