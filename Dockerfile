FROM ubuntu

# Labels definition
LABEL maintainer="petos@petos.eu"
LABEL description="Simple FVE toolkit"
LABEL version=1.0

# Add important components to the base image

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    jq \
    curl \
    bc \
    vim \
    python3  \
    ca-certificates \
    libnss-wrapper \
 && rm -rf /var/lib/apt/lists/* 

RUN userdel -r ubuntu || true
EXPOSE 80
EXPOSE 443


## Setup the actual FVE tooling
WORKDIR /opt/fve/data
WORKDIR /opt/fve/config
WORKDIR /opt/fve/scripts

ADD https://github.com/petos/FVEread.git /opt/fve/scripts
COPY entrypoint.sh /opt/fve/entrypoint.sh

#RUN chown -R fve:fve /opt/fve/
RUN chmod +x /opt/fve/entrypoint.sh && \
#    mkdir -m 0777 -p /opt/fve/api && \
    chmod o+rwx /opt/fve&& \
    touch /etc/tellstick.conf && \
    chmod a+r /etc/tellstick.conf && \
    chmod a+rwx /opt/fve/scripts/*


ENTRYPOINT ["/opt/fve/entrypoint.sh"]
CMD ["FVEloop"]

