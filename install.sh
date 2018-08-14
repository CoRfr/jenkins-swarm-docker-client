#!/bin/bash -xe

# Install swarm-client
groupadd -g ${gid} ${group}
useradd -d "${JENKINS_AGENT_HOME}" -u "${uid}" -g "${gid}" -m -s /bin/bash "${user}"
mkdir -p /usr/share/jenkins
wget -O /usr/share/jenkins/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar $SWARM_PLUGIN_URL
chmod -R 755 /usr/share/jenkins

# Install few tools, including git from backports
echo "deb http://ftp.debian.org/debian stretch-backports main" >> /etc/apt/sources.list
apt-get update
apt-get -y install -t stretch-backports git
apt-get -y install net-tools python bzip2 lbzip2 jq netcat-openbsd rsync \
                 apt-transport-https ca-certificates curl software-properties-common

# Install docker from official repos
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
apt-get update
apt-get -y install docker-ce

# Create symlinks to use lbzip2
cd /usr/local/bin
ln -s /usr/bin/lbzip2 bzip2
ln -s /usr/bin/lbzip2 bunzip2

# Provide docker group and make the executable accessible (ids from CoreOS & Debian)
#groupadd -g 999 docker2
#usermod -a -G docker,docker2 "${user}"

# Set bash as default shell
echo "dash dash/sh boolean false" | debconf-set-selections
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

# Add Tini
TINI_VERSION="v0.18.0"
mkdir -p "/opt/tini"
wget -O /opt/tini/tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static
chmod +x /opt/tini/tini

# Install encaps
cd /tmp
wget https://github.com/swi-infra/jenkins-docker-encaps/archive/master.zip
unzip master.zip
mv jenkins-docker-encaps-master/encaps* /usr/bin
rm -rf master.zip jenkins-docker-encaps-master

chown -R ${uid}:${gid} ${JENKINS_AGENT_HOME}

# Install clean-up
rm -rf /var/lib/apt/lists/*
