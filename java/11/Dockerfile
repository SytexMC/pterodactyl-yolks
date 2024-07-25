# ----------------------------------
# SytexMC's Custom Docker Image
# Image: ghcr.io/sytexmc/pterodactyl-yolks:java_11
# ----------------------------------

FROM        --platform=$TARGETOS/$TARGETARCH eclipse-temurin:11.0.13_8-jdk-focal

LABEL       author="SytexMC" maintainer="sytex@duck.com"

LABEL       org.opencontainers.image.source="https://github.com/sytexmc/pterodactyl-yolks"
LABEL       org.opencontainers.image.licenses=GPL-3.0

RUN 		apt-get update -y \
 			&& apt-get install -y jq lsof curl ca-certificates openssl git tar sqlite3 fontconfig libfreetype6 tzdata iproute2 libstdc++6 \
 			&& useradd -d /home/container -m container

RUN rm -rf /usr/bin/dd \
			&& rm -rf /usr/bin/fallocate \
			&& rm -rf /usr/bin/truncate \
			&& rm -rf /usr/bin/xfs_mkfile

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./../entrypoint.sh /entrypoint.sh
CMD         [ "/bin/bash", "/entrypoint.sh" ]
