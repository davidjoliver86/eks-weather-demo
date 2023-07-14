FROM ubuntu:jammy
RUN apt update && apt install -y git unzip curl

WORKDIR /tmp
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && ./aws/install && rm -rf *
RUN apt-get autoclean && apt-get autoremove --yes

RUN curl -LO https://dl.k8s.io/release/v1.27.3/bin/linux/amd64/kubectl && chmod +x kubectl && mv kubectl /usr/local/bin/

RUN useradd ci-user -u 1000 && mkdir /home/ci-user && chown ci-user:ci-user /home/ci-user
WORKDIR /home/ci-user
USER 1000