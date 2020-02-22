
FROM debian:buster AS rabcdasm_builder

RUN \
    apt-get update -y && \
    apt-get install -y \
      build-essential \
      tar \
      unzip \
      less \
      sed \
      jq \
      wget \
      git \
      nano \
      liblzma-dev && \
    wget https://netcologne.dl.sourceforge.net/project/d-apt/files/d-apt.list -O /etc/apt/sources.list.d/d-apt.list && \
    apt-get update --allow-insecure-repositories && apt-get -y --allow-unauthenticated install --reinstall d-apt-keyring && apt-get update && \
    apt-get install -y dmd-compiler && \
    git clone https://github.com/CyberShadow/RABCDAsm.git /rabcdasm && \
    cd /rabcdasm && \
    dmd -run build_rabcdasm.d -od=./bin/

FROM debian:buster AS swf_builder

WORKDIR /workdir
ENV GAME_NAME "GemCraft Frostborn Wrath"

COPY --from=rabcdasm_builder /rabcdasm/bin /usr/local/bin

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
      host \
      unzip \
      less \
      sed \
      jq \
      nano \
      git && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

COPY scripts/ /usr/local/bin/
