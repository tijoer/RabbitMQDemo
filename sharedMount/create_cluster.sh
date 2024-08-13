#!/bin/bash

source "$(dirname "$0")/bash_helpers.sh"

if tty -s; then
    trap ctrl_c INT # trap ctrl-c and call ctrl_c()
    trap ctrl_c SIGTERM
fi

clear_next_lines_to_scroll_down
printf "💻 Installing RabbitMQ cluster.\n"
printf "\n"
printf "${YELLOW}💡${NC}  This command will install a new RabbitMq cluster on the current machine and provide you with the necessary credentials to join\n"
printf "    other nodes to the cluster."
printf "\n"
printf "${LIGHT_GRAY}🔎${NC}  The installation log and any error messages can be found in the log files located at /var/log/."
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

printf "\n"
printf "${LIGHT_GRAY}💻${NC}  RabbitMQ is running in the background and a management dashboard is available at port 15672. The username is 'tim'\n"
printf "    and the password is the erlang cookie below.\n"
printf "\n"
printf "${YELLOW}🔑${NC} The private erlang cookie is used to join the RabbitMQ cluster. The following is your erlang cookie: \n"
printf "\n"

sudo cat /var/lib/rabbitmq/.erlang.cookie
printf "     ${RED}   <---- KEEP THIS KEY IN A SECURE PLACE. YOU WILL NEED IT TO JOIN THE CLUSTER.${NC}\n"

printf "\n"
printf "${LIGHT_GRAY}⚠️${NC}  It is important to have a backup plan for the cluster, as everything can break. If the erlang cookie is lost, it may not be possible to access the cluster or recover encrypted files 🔒.\n"
printf "\n"
printf "${GREEN}✅${NC}  RabbitMq has been succefully installed and is now running. Enjoy!\n"
exit 0