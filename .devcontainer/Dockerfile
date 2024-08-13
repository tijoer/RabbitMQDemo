FROM rust:bookworm

ARG USERNAME=ownia
ARG USER_UID=1000
ARG USER_GID=$USER_UID


WORKDIR /usr/src/myapp
COPY . .

RUN apt-get update
RUN apt-get install \
    vim \
    sudo \
    zsh \
    build-essential \
    shellcheck \
    -y

EXPOSE 4369 15672

# ENV SHELL /bin/zsh
# RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended