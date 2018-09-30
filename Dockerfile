########################################################################
# Moloch WISE container
########################################################################
# Base Image #
FROM ubuntu:16.04

#####################
# Labels
#####################
LABEL Maintainer.email="silvertear33@yahoo.com" \
      Maintainer.name="Taylor Ashworth" \
      Version="2.5"

#####################
# Enviromental variables
#####################
ENV DEBIAN_FRONTEND noninteractive
## Java love/Hate
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

#####################
# Setup
#####################
### Install Moloch dependencies ###
RUN apt-get update \
        && apt-get install -y software-properties-common \
        && apt-get update \
        && apt-get install -y wget \
        npm \
        curl \
        libwww-perl \
        libjson-perl \
        ethtool \
        libyaml-dev

## Install Java ##
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections \
        && add-apt-repository -y ppa:webupd8team/java \
        && apt-get update \
        && apt-get install -y oracle-java8-installer \
        && rm -rf /var/lib/apt/lists/* \
        && rm -rf /var/cache/oracle-jdk8-installer

## Install Moloch ##
RUN apt-get -y upgrade \
        && apt-get -y dist-upgrade \
        && wget https://files.molo.ch/moloch-master_ubuntu16_amd64.deb \
        && apt-get -f -y install \
        && dpkg -i moloch-master_ubuntu16_amd64.deb
RUN rm moloch-master_ubuntu16_amd64.deb

### Installing WISE ###

## setting path for NPM and NODE that comes with moloch ##
ENV PATH /data/moloch/bin:$PATH

## installing WISE ##
RUN cd /data/moloch/wiseService \
        && npm install

#####################
# Files
#####################
### Adding start script ###
COPY /startscript/start_wise.sh /data/moloch/bin/
RUN chmod 755 /data/moloch/bin/start_wise.sh

#####################
# Ports
#####################
## Set container to listen on port 8081 for WISE queries ##
EXPOSE 8081

#####################
# Entrypoint
#####################
### Entrypoint for wise script
CMD /data/moloch/bin/start_wise.sh
