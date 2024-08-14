#!/bin/bash

source "$(dirname "$0")/bash_helpers.sh"

if tty -s; then
    trap ctrl_c INT # trap ctrl-c and call ctrl_c()
    trap ctrl_c SIGTERM
fi

# The cluster key 🔑 is the first argument and gets passed from install.rs when this script is run as
# a child process. It is passed as the --cluster-key argument to the join-cluster command.
CLUSTER_KEY=$1
echo CLUSTER KEY CLUSTER KEY CLUSTER KEY CLUSTER KEY CLUSTER KEY CLUSTER KEY 
echo $1
echo $2
echo $3
echo $CLUSTER_KEY
echo CLUSTER KEY CLUSTER KEY CLUSTER KEY CLUSTER KEY CLUSTER KEY CLUSTER KEY 
sudo mkdir -p /var/lib/rabbitmq/
sudo echo $CLUSTER_KEY >/var/lib/rabbitmq/.erlang.cookie
sudo chmod 700 /var/lib/rabbitmq/.erlang.cookie # RabbitMQ will check the permissions of the cookie file and will not start if the permissions are not correct.

sudo cat /var/lib/rabbitmq/.erlang.cookie

clear_next_lines_to_scroll_down
printf "💻 Joining RabbitMQ cluster and installing on this machine.\n"
printf "\n"
printf "${YELLOW}💡${NC}  This command will join an existing RabbitMQ cluster with the current machine \n"
printf "\n"
printf "${LIGHT_BLUE}⏳${NC} Starting installation... \n"
printf "${LIGHT_BLUE}⏳${NC} Installing RabbitMQ...\n"

clear_next_lines_to_scroll_down
scroll_window_start
# Call the RabbitMQ installation script. This is copied from the RabbitMQ documentation and will get the latest version of RabbitMQ, instead
# of the version that is available in the package manager.
source "$(dirname "$0")/install_rabbitmq.sh"
scroll_window_stop

printf "${LIGHT_BLUE}🔧${NC} Configuring RabbitMQ.\n"
clear_next_lines_to_scroll_down
scroll_window_start
sudo rabbitmq-plugins enable rabbitmq_management
sudo service rabbitmq-server restart

# Add a user called tim to the RabbitMQ Dashboard.
sudo rabbitmqctl add_user tim $(sudo cat /var/lib/rabbitmq/.erlang.cookie)
sudo rabbitmqctl set_user_tags tim administrator
scroll_window_stop

# Join the cluster
printf "${LIGHT_BLUE}🔧${NC} Joining the RabbitMQ cluster.\n"
scroll_window_start
rabbitmqctl stop_app
rabbitmqctl reset
rabbitmqctl join_cluster rabbit@rabbit-1 # TODO FIX THIS LINE, THIS IS HARDCODED FOR THE DEMO
rabbitmqctl start_app
rabbitmqctl cluster_status
scroll_window_stop

printf "\n"
printf "${LIGHT_GRAY}💻${NC}  RabbitMQ is running in the background and a management dashboard is available at port 15672. The username is 'tim'\n"
printf "    and the password is the erlang cookie that you provided.\n"
printf "\n"

sudo cat /var/lib/rabbitmq/.erlang.cookie
printf "     ${RED}   <---- KEEP THIS KEY IN A SECURE PLACE. YOU WILL NEED IT TO JOIN THE CLUSTER.${NC}\n"

printf "\n"
printf "${LIGHT_GRAY}⚠️${NC}  It is important to have a backup plan for the cluster, as everything can break. If the key is lost, it may not be possible to access the cluster or recover encrypted files.\n"
printf "\n"
printf "${GREEN}✅${NC}  RabbitMq has been succefully installed and is now running. Enjoy!\n"
exit 0