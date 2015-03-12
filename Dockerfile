FROM csanchez/jenkins-swarm-slave:latest

MAINTAINER Bertrand Roussel <broussel@sierrawireless.com>

USER root
RUN apt-get update && apt-get install -y docker.io

RUN groupmod -g 233 docker
RUN usermod -a -G docker jenkins-slave

# Docker encapsulation helpers
COPY encaps /usr/bin/encaps
COPY encaps-cleanup /usr/bin/encaps-cleanup

