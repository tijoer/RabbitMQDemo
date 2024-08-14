#!/bin/bash -x

# Create a network for the three containers to communicate with each other.
docker network create rabbits

# Build a Docker image that will be used to run the tests. It is a basic Debian image with a
# few dependencies installed.
docker build -t debian-rabbitmqdemo-runner $(dirname "$0")

# Force any running containers to stop, if this test was run before and did not finish properly.
# || true is used to prevent the script from exiting if the container does not exist.
# The 2>/dev/null is used to prevent the script from printing an error message.
docker rm rabbit-1 --force 2>/dev/null || true
docker rm rabbit-2 --force 2>/dev/null || true
docker rm rabbit-3 --force 2>/dev/null || true

# Start three empty Docker containers. Use --init as we want to install multiple services in the
# container and we do not have asingle process yet that should run as  PID1. Use --tty and 
# --interactive to keep the containers running and to be able to interact with them.
# Mount the "sharedMount" folder from this project to /RabbitMqDemoMount in the created containers,
# so that we have am easy way do get this install script into the container.
docker run --detach --interactive --init --tty --rm --net rabbits --hostname rabbit-1 --name rabbit-1 --publish 8081:15672 -v /workspaces/RabbitMqDemo/sharedMount:/RabbitMqDemoMount debian-rabbitmqdemo-runner
docker run --detach --interactive --init --tty --rm --net rabbits --hostname rabbit-2 --name rabbit-2 --publish 8082:15672 -v /workspaces/RabbitMqDemo/sharedMount:/RabbitMqDemoMount debian-rabbitmqdemo-runner
docker run --detach --interactive --init --tty --rm --net rabbits --hostname rabbit-3 --name rabbit-3 --publish 8083:15672 -v /workspaces/RabbitMqDemo/sharedMount:/RabbitMqDemoMount debian-rabbitmqdemo-runner

# Install RabbitMq in the first container. For this we use the script that we provided with the
# mounted shared folder.
docker exec -it rabbit-1 ./RabbitMqDemoMount/create_cluster.sh

# As RabbitMQ Cluster discorvery works with a shared password called ERLANG_COOKIE, we need to
# extract the data from the first node and pass it do the other nodes.
ERLANG_COOKIE=$(docker exec rabbit-1 cat /var/lib/rabbitmq/.erlang.cookie)

# Now we pass this cookie to the next node and install Rabbit MQ with the provided cookie.
# The new node will then discover the existing Rabbit MQ server and form a cluster.
docker exec -it rabbit-2 ./RabbitMqDemoMount/join_cluster.sh --cluster-key $ERLANG_COOKIE
docker exec -it rabbit-3 ./RabbitMqDemoMount/join_cluster.sh --cluster-key $ERLANG_COOKIE
