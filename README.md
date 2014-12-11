jenkins-swarm-docker-client
===========================

Based on csanchez/jenkins-swarm-slave

Also provides docker in order to control the docker host.

The idea behind this is to expose a jenkins-slave to a jenkins-master,
with jobs managing docker containers and volumes in order to acheive the expected goal.

There is very few assumption about the actual host, except that it runs docker.

