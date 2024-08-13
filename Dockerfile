FROM debian:bookworm

#ENV TERM xterm-256color

RUN apt-get update && apt-get install -y \
    sudo \
    curl

EXPOSE 4369 15672