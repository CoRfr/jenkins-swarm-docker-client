FROM csanchez/jenkins-swarm-slave:latest

MAINTAINER Bertrand Roussel <broussel@sierrawireless.com>

USER root
RUN apt-get update && apt-get install -y docker.io
