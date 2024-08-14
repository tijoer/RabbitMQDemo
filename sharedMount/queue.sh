#!/bin/bash

# Set RabbitMQ credentials and host
RABBITMQ_USER="tim"
RABBITMQ_PASSWORD="SAZQZUWFBEMYBJKHFZIZ"
RABBITMQ_HOST="localhost"

# Declare a queue named "my_queue"
rabbitmqadmin -u $RABBITMQ_USER -p $RABBITMQ_PASSWORD -H $RABBITMQ_HOST -V "/" declare queue name=my_queue durable=true

# Publish a message to the queue
rabbitmqadmin -u $RABBITMQ_USER -p $RABBITMQ_PASSWORD -H $RABBITMQ_HOST -V "/" publish routing_key=my_queue payload="Hello, RabbitMQ!"

# Get the message from the queue
rabbitmqadmin -u $RABBITMQ_USER -p $RABBITMQ_PASSWORD -H $RABBITMQ_HOST -V "/" get queue=my_queue requeue=false
