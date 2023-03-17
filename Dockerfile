FROM debian:bullseye-slim

LABEL Description="Dockerized MiKTeX, Debian Bullseye (11.6)" Vendor="Christian Schenk" Version="23.1"

ARG DEBIAN_FRONTEND=noninteractive

ARG GPG_KEY=D6BC243565B2087BC3F897C9277A7293F59E4889
# pub   rsa2048 2017-06-23 [SC] [expires: 2023-04-29]
#       D6BC243565B2087BC3F897C9277A7293F59E4889
# uid           [ unknown] MiKTeX Packager <packager@miktex.org>
# sub   rsa2048 2017-06-23 [E] [expires: 2023-04-29]

RUN    apt-get update \
    && apt-get install -y --no-install-recommends \
           apt-transport-https \
           ca-certificates \
           dirmngr \
           ghostscript \
           gnupg \
           make \
           perl

RUN set -eux; \
    gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys ${GPG_KEY}; \
    gpg --export --armor -o /usr/share/keyrings/miktex.asc; \
    echo "deb [signed-by=/usr/share/keyrings/miktex.asc] https://miktex.org/download/debian bullseye universe" \
        >> /etc/apt/sources.list.d/miktex.list

RUN    apt-get update -y \
    && apt-get install -y --no-install-recommends \
           miktex

RUN    miktexsetup finish \
    && initexmf --admin --set-config-value=[MPM]AutoInstall=1 \
    && mpm --admin --update-db \
    && mpm --admin \
           --install amsfonts \
           --install biber-linux-x86_64 \
    && initexmf --admin --update-fndb

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

ENV MIKTEX_USERCONFIG=/miktex/.miktex/texmfs/config
ENV MIKTEX_USERDATA=/miktex/.miktex/texmfs/data
ENV MIKTEX_USERINSTALL=/miktex/.miktex/texmfs/install

WORKDIR /miktex/work

CMD ["bash"]
