FROM rust:1.67-bullseye

ARG USERNAME=ownia
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# # Create the user
# RUN groupadd --gid $USER_GID $USERNAME \
#     && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
#     #
#     # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
#     && apt-get update \
#     && apt-get install -y sudo \
#     && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
#     && chmod 0440 /etc/sudoers.d/$USERNAME


WORKDIR /usr/src/myapp
COPY . .

ADD https://github.com/cargo-bins/cargo-binstall/releases/latest/download/cargo-binstall-x86_64-unknown-linux-musl.tgz /home/
RUN tar -zxvf /home/cargo-binstall-x86_64-unknown-linux-musl.tgz -C /usr/local/cargo/bin/

RUN apt-get update
RUN apt-get install \
    vim \
    sudo \
    zsh \
    build-essential \
    shellcheck \
    -y

RUN rustup component add clippy
RUN rustup component add rustfmt

RUN cargo install \
    cargo-deb 
#    cargo-edit \
#    cargo-watch

EXPOSE 4369 15672

ENV SHELL /bin/zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

## Setup cross compilation
#RUN rustup target add armv7-unknown-linux-gnueabihf #Raspberry Pi 2/3/4
#RUN apt install gcc-arm-linux-gnueabihf -y#
#
#RUN bash -x ./setup.sh