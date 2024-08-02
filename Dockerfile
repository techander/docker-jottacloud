# Name: jottacloud
# Description: This dockerfile is used to build the docker image for a containerized jotta backup client, with the latest version of official jotta-cli preloaded at the time of build.
# Author: BlueT - Matthew Lien - 練喆明

FROM ubuntu:22.04
LABEL org.opencontainers.image.authors="bluet@bluet.org"

VOLUME [ "/data" ]

ENV JOTTA_TOKEN="**None**" \
	JOTTA_DEVICE="**docker-jottacloud**" \
	JOTTA_SCANINTERVAL="12h"\
	LOCALTIME="Asia/Taipei" \
	STARTUP_TIMEOUT=15 \
	JOTTAD_SYSTEMD=0

RUN apt-get update -y &&\
	apt-get upgrade -y &&\
	apt-get -y install wget gnupg apt-transport-https ca-certificates expect &&\
	wget -O - https://repo.jotta.us/public.gpg | apt-key add - &&\
	echo "deb https://repo.jotta.us/debian debian main" | tee /etc/apt/sources.list.d/jotta-cli.list &&\
	apt-get update -y &&\
	apt-get install jotta-cli psmisc -y &&\
	apt-get autoremove -y --purge &&\
	apt-get clean &&\
	rm -rf /var/lib/lists/*

COPY entrypoint.sh /src/
WORKDIR /src
RUN chmod +x entrypoint.sh

EXPOSE 14443

ENTRYPOINT [ "/src/entrypoint.sh" ]
