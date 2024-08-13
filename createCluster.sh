#!/bin/bash -x

# # As the install scripts are currently calling hardcoded scripts in the /var/ownia directory,
# # we need to build the project and install the deb package in the current system first.
# # This is not ideal, but it works for now.
# cd ..
# . createAndInstallDeb.sh
# cd tests

# We create a network for the three containers to communicate with each other.
docker network create rabbits

# Build a Docker image that will be used to run the tests. It is a basic Debian image with a
# few dependencies installed to speed this test up. However it is not a full Ownia installation, as
# we want to test the installation scripts with this integration test.
docker build -t debian-ownia-runner $(dirname "$0")

# Force any running containers to stop, if this test was run before and did not finish properly.
# || true is used to prevent the script from exiting if the container does not exist.
# The 2>/dev/null is used to prevent the script from printing an error message.
docker rm rabbit-1 --force 2>/dev/null || true
docker rm rabbit-2 --force 2>/dev/null || true
docker rm rabbit-3 --force 2>/dev/null || true

# Start three empty Docker containers. Use --init as we want to install multiple services in the
# container and Ownia is not a sole service that should run as PID1. Use --tty and --interactive
# to keep the containers running and to be able to interact with them.
docker run --detach --interactive --init --tty --rm --net rabbits --hostname rabbit-1 --name rabbit-1 --publish 8081:15672 #-v /workspaces/RabbitMqDemo/sharedMount:/RabbitMqDemoMount debian-RabbitMqDemo-runner
docker run --detach --interactive --init --tty --rm --net rabbits --hostname rabbit-2 --name rabbit-2 --publish 8082:15672 #-v /workspaces/RabbitMqDemo/sharedMount:/RabbitMqDemoMount debian-RabbitMqDemo-runner
docker run --detach --interactive --init --tty --rm --net rabbits --hostname rabbit-3 --name rabbit-3 --publish 8083:15672 #-v /workspaces/RabbitMqDemo/sharedMount:/RabbitMqDemoMount debian-RabbitMqDemo-runner

# # Install ownia in the first container, using the create-cluster command and get the erlang_cookie
# # docker exec rabbit-1 apt-get install ./owniaMount/ownia_0.0.1_amd64.deb
# # docker exec rabbit-1 ownia install create-cluster
# ERLANG_COOKIE=$(docker exec rabbit-1 cat /var/lib/rabbitmq/.erlang.cookie)

# # Install ownia in the second and third container, using the join-cluster command and the erlang_cookie we fetched before
# docker exec rabbit-2 apt-get install ./owniaMount/ownia_0.0.1_amd64.deb
# docker exec rabbit-2 bash -c "ownia install join-cluster --cluster-key $ERLANG_COOKIE"
# docker exec rabbit-3 apt-get install ./owniaMount/ownia_0.0.1_amd64.deb
# docker exec rabbit-3 bash -c "ownia install join-cluster --cluster-key $ERLANG_COOKIE"