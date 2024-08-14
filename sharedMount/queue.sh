#!/bin/bash

rabbitmqctl add_vhost vhost1
rabbitmqctl set_permissions -p vhost1 tim ".*" ".*" ".*"

# Use curl to create a new queue called 'test_queue' on the RabbitMQ server.
curl -i -u tim:$(sudo cat /var/lib/rabbitmq/.erlang.cookie) \
    -H "content-type:application/json" \
    -XPUT -d'{"type":"classic","durable":true,"auto_delete":false,"arguments":{}}' \
    http://localhost:15672/api/queues/vhost1/test_queue

# Publish a message to the 'test_queue' queue.
curl -i -u tim:$(sudo cat /var/lib/rabbitmq/.erlang.cookie) \
    -H "content-type:application/json" \
    -XPOST -d'{"properties":{},"routing_key":"test_queue","payload":"Hello World!","payload_encoding":"string"}' \
    http://localhost:15672/api/exchanges/vhost1/amq.default/publish

# Use curl to get the message from the 'test_queue' queue.
# Also set ackmod to 'ack_requeue_true' to requeue the message after it has been read.
# Also set encoding to 'auto' to automatically detect the encoding of the message.
curl -i -u tim:$(sudo cat /var/lib/rabbitmq/.erlang.cookie) \
    -H "content-type:application/json" \
    -XPOST -d'{"count":1,"ackmode":"ack_requeue_true","encoding":"auto"}' \
    http://localhost:15672/api/queues/vhost1/test_queue/get

exit 0