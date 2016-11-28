FROM openjdk:8-jre

MAINTAINER Bertrand Roussel <broussel@sierrawireless.com>

# Release
ENV JENKINS_SWARM_VERSION 2.3
#ENV SWARM_PLUGIN_URL https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar

# Snapshot
#ENV JENKINS_BUILD lastStableBuild
#ENV JENKINS_SWARM_VERSION 2.1-SNAPSHOT
#ENV SWARM_PLUGIN_URL https://jenkins.ci.cloudbees.com/job/plugins/job/swarm-plugin/org.jenkins-ci.plugins\$swarm-client/$JENKINS_BUILD/artifact/org.jenkins-ci.plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar

# Dev build
ENV SWARM_PLUGIN_URL https://github.com/CoRfr/swarm-plugin/releases/download/swarm-plugin-$JENKINS_SWARM_VERSION/swarm-client-jar-with-dependencies.jar

# Docker version follows stable from CoreOS
ENV DOCKER_VERSION 1.10.3
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

# Provide docker group and make the executable accessible (ids from CoreOS & Debian)
RUN groupadd -g 233 docker
RUN groupadd -g 999 docker2
RUN usermod -a -G docker,docker2 jenkins-slave
RUN chown root:docker /usr/bin/docker

# bash as default shell
RUN ( \
        echo "dash dash/sh boolean false" | debconf-set-selections && \
        DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash \
    )

# Add Tini
ENV TINI_VERSION v0.10.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static /home/jenkins-slave/tini
RUN chmod +x /home/jenkins-slave/tini
ENTRYPOINT ["/home/jenkins-slave/tini", "--", "/usr/local/bin/jenkins-slave.sh"]

# Docker encapsulation helpers
COPY encaps /usr/bin/encaps
COPY encaps-cleanup /usr/bin/encaps-cleanup

RUN chown -R jenkins-slave:jenkins-slave /home/jenkins-slave

USER jenkins-slave
VOLUME /home/jenkins-slave

