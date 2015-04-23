FROM csanchez/jenkins-swarm-slave:latest

MAINTAINER Bertrand Roussel <broussel@sierrawireless.com>

ENV DOCKER_VERSION 1.5.0

USER root
RUN ( apt-get update && apt-get -y install git )
RUN ( cd /tmp && \
      wget -q -O /usr/bin/docker https://get.docker.com/builds/Linux/x86_64/docker-$DOCKER_VERSION && \
      chmod +x /usr/bin/docker )

RUN groupadd -g 233 docker
RUN chown root:docker /usr/bin/docker
RUN usermod -a -G docker jenkins-slave

# Docker encapsulation helpers
COPY encaps /usr/bin/encaps
COPY encaps-cleanup /usr/bin/encaps-cleanup

RUN chown -R jenkins-slave:jenkins-slave /home/jenkins-slave
USER jenkins-slave

