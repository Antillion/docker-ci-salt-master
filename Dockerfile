FROM        ubuntu:14.04
MAINTAINER  Oliver Tupman "otupman@dts-workshop.com"
ENV REFRESHED_AT 2015-04-03
ENV SALT_VERSION 2014.7.4
ENV SALT_PASSWORD 59r{Y3*912
# Update system
RUN apt-get update && \
	apt-get install -y wget curl dnsutils python-pip python-dev python-apt software-properties-common dmidecode git

# Setup salt ppa
RUN echo deb http://ppa.launchpad.net/saltstack/salt/ubuntu `lsb_release -sc` main | tee /etc/apt/sources.list.d/saltstack.list && \
	wget -q -O- "http://keyserver.ubuntu.com:11371/pks/lookup?op=get&search=0x4759FA960E27C0A6" | apt-key add -

# Download & install Salt
WORKDIR /root
RUN git clone https://github.com/saltstack/salt
RUN	cd salt && \
	git checkout tags/v$SALT_VERSION && \
	pip install -r _requirements.txt && \
	pip install zmq && \
	apt-get install -y python-m2crypto && \
	./setup.py install && \
	mkdir -p /etc/salt && \
	cp conf/master /etc/salt/master

# Setup halite
RUN pip install cherrypy docker-py halite

# Fix for https://groups.google.com/forum/#!topic/salt-users/q2N2S2Y-g64
RUN pip install pycrypto

# Add salt config files
ADD etc/master /etc/salt/master
ADD etc/minion /etc/salt/minion
ADD etc/reactor /etc/salt/master.d/reactor

# Add service scripts
ADD etc/init/salt-api.conf /etc/init/salt-api.conf
ADD etc/init/salt-master.conf /etc/init/salt-master.conf
ADD etc/init.d/salt-api /etc/init.d/salt-api
ADD etc/init.d/salt-master /etc/init.d/salt-master
RUN chmod +x /etc/init.d/salt-api && \
	chmod +x /etc/init.d/salt-master

# FROM: https://registry.hub.docker.com/u/rastasheep/ubuntu-sshd/dockerfile/
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd

RUN echo "root:$SALT_PASSWORD" |chpasswd

RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

#ADD setup-ssh.sh /tmp/setup-ssh.sh
#RUN /tmp/setup-ssh.sh

# Our stuff
ADD sudoers /etc/sudoers
ADD create-user.sh /tmp/create-user.sh

RUN /tmp/create-user.sh

RUN ln -s /usr/local/bin/salt-key /usr/bin/salt-key

# Add and set start script
ADD start.sh /start.sh

# Expose volumes
VOLUME ["/etc/salt", "/var/cache/salt", "/srv/salt"]

RUN mkdir -p /var/log/salt && touch /var/log/salt/salt-master.log
RUN chown -R salt /var/log/salt

# Fix for https://groups.google.com/forum/#!topic/salt-users/q2N2S2Y-g64
# Re-running for "reasons"
RUN pip install pycrypto

# Exposing salt master and api ports
EXPOSE 4505 4506 8080 8081 22 8001 8002



CMD ["bash", "/start.sh"]
