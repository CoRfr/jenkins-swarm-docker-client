FROM java:7-jre

MAINTAINER Bertrand Roussel <broussel@sierrawireless.com>

#ENV JENKINS_SWARM_VERSION 2.0
#ENV SWARM_PLUGIN_URL http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar

ENV JENKINS_BUILD 133
ENV JENKINS_SWARM_VERSION 2.1-SNAPSHOT
ENV SWARM_PLUGIN_URL https://jenkins.ci.cloudbees.com/job/plugins/job/swarm-plugin/org.jenkins-ci.plugins\$swarm-client/$JENKINS_BUILD/artifact/org.jenkins-ci.plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar

# Docker version follows stable from CoreOS
ENV DOCKER_VERSION 1.8.3
ENV HOME /home/jenkins-slave

RUN useradd -c "Jenkins Slave user" -d $HOME -m jenkins-slave
RUN ( \
      mkdir -p /usr/share/jenkins && \
      wget -O /usr/share/jenkins/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar $SWARM_PLUGIN_URL && \
      chmod -R 755 /usr/share/jenkins )

COPY jenkins-slave.sh /usr/local/bin/jenkins-slave.sh

RUN ( apt-get update && \
      apt-get -y install net-tools git python bzip2 jq && \
      rm -rf /var/lib/apt/lists/* )

RUN ( cd /tmp && \
      wget -q -O /usr/bin/docker https://get.docker.com/builds/Linux/x86_64/docker-$DOCKER_VERSION && \
      chmod +x /usr/bin/docker )

# Provide docker group and make the executable accessible (ids from CoreOS)
RUN groupadd -g 233 docker
RUN chown root:docker /usr/bin/docker
RUN usermod -a -G docker jenkins-slave

# bash as default shell
RUN ( \
        echo "dash dash/sh boolean false" | debconf-set-selections && \
        DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash \
    )

# Docker encapsulation helpers
COPY encaps /usr/bin/encaps
COPY encaps-cleanup /usr/bin/encaps-cleanup

RUN chown -R jenkins-slave:jenkins-slave /home/jenkins-slave

USER jenkins-slave
VOLUME /home/jenkins-slave

ENTRYPOINT ["/usr/local/bin/jenkins-slave.sh"]

