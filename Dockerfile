FROM ubuntu:20.04
LABEL maintainer="bluet@bluet.org"

ENV JOTTA_TOKEN="**None**" \
    JOTTA_DEVICE="**docker-jottacloud**" \
    JOTTA_SCANINTERVAL="12h"\
    PUID=101 \
    PGID=101 \
    LOCALTIME="Asia/Taipei" \
    JOTTAD_USER="jottad" \
    JOTTAD_GROUP="jottad" \
    STARTUP_TIMEOUT=15

RUN apt-get update -y &&\
	apt-get upgrade -y &&\
	apt-get -y install wget gnupg apt-transport-https ca-certificates expect &&\
	wget -O - https://repo.jotta.us/public.gpg | apt-key add - &&\
	echo "deb https://repo.jotta.us/debian debian main" | tee /etc/apt/sources.list.d/jotta-cli.list &&\
	apt-get update -y &&\
	apt-get install jotta-cli -y &&\
	apt-get autoremove -y --purge &&\
	apt-get clean &&\
	rm -rf /var/lib/lists/*


COPY entrypoint.sh /src/
WORKDIR /src
RUN chmod +x entrypoint.sh

EXPOSE 14443

ENTRYPOINT [ "/src/entrypoint.sh" ]
