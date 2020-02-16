## Removing All Unused Objects
The docker system prune command will remove all stopped containers, all dangling images, and all unused networks:

`docker system prune` 

You’ll be prompted to continue, use the -f or --force flag to bypass the prompt.
WARNING! This will remove:
        - all stopped containers
        - all networks not used by at least one container
        - all dangling images
        - all build cache
Are you sure you want to continue? [y/N]
If you also want to remove all unused volumes, pass the --volumes flag:

``docker system prune --volumes `` 

## Removing Docker Containers

To remove all stopped containers use the docker container prune command:
``docker container prune``  

stop all running containers  
`docker container stop $(docker container ls -aq)`  

remove all containers  
`docker container rm $(docker container ls -aq)`

A dangling image is an image that is not tagged and is not used by any container.
To remove dangling images type:

`` docker image prune``

To remove all images which are not referenced by any existing container, not just the dangling ones, use the prune command with the -a flag:  
``docker image prune -a``

## Removing Docker Volumes
Remove one or more volumes
To remove one or more Docker volumes use the docker volume ls command to find the ID of the volumes you want to remove.

docker volume ls
The output should look something like this:

DRIVER              VOLUME NAME
local               4e12af8913af888ba67243dec78419bf18adddc3c7a4b2345754b6db64293163
local               terano
Once you’ve found the VOLUME NAME of the volumes you want to remove, pass them to the docker volume rm command. For example, to remove the first volume listed in the output above, run:

docker volume rm 4e12af8913af888ba67243dec78419bf18adddc3c7a4b2345754b6db64293163
If you get an error similar to the one shown below, it means that an existing container uses the volume. To remove the volume, you will have to remove the container first.

Error response from daemon: remove 4e12af8913af888ba67243dec78419bf18adddc3c7a4b2345754b6db64293163: volume is in use - [c7188935a38a6c3f9f11297f8c98ce9996ef5ddad6e6187be62bad3001a66c8e]
Copy
Remove all unused volumes
To remove all unused volumes use the docker image prune command:

docker volume prune
You’ll be prompted to continue, use the -f or --force flag to bypass the prompt.

WARNING! This will remove all local volumes not used by at least one container.
Are you sure you want to continue? [y/N]
Removing Docker Networks
Remove one or more networks
To remove one or more Docker networks use the docker network ls command to find the ID of the networks you want to remove.

docker network ls
The output should look something like this:

NETWORK ID          NAME                DRIVER              SCOPE
107b8ac977e3        bridge              bridge              local
ab998267377d        host                host                local
c520032c3d31        my-bridge-network   bridge              local
9bc81b63f740        none                null                local
Once you’ve located the networks you want to remove, pass their NETWORK ID to the docker network rm command. For example to remove the network with the name my-bridge-network run:

docker network rm c520032c3d31
If you get an error similar to the one shown below, it means that an existing container uses the network. To remove the network you will have to remove the container first.

Error response from daemon: network my-bridge-network id 6f5293268bb91ad2498b38b0bca970083af87237784017be24ea208d2233c5aa has active endpoints
Copy
Remove all unused network
Use the docker network prune command to remove all unused networks.

docker network prune
You’ll be prompted to continue, use the -f or --force flag to bypass the prompt.

WARNING! This will remove all networks not used by at least one container.
Are you sure you want to continue? [y/N] 
Remove networks using filters
With the docker network prune command you can remove networks based on condition using the filtering flag --filter.

At the time of the writing of this article, the currently supported filters are until and label. You can use more than one filter by using multiple --filter flags.

For example, to remove all networks that are created more than 12 hours ago, run:

docker network prune -a --filter "until=12h"

