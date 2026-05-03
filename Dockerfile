FROM alpine:latest

LABEL maintainer="https://github.com/petos/FVEreadDocker/issues"
LABEL description="Simple FVE toolkit"
LABEL version="3.0"

# Instalace nezbytných nástrojů, minimalizace image
RUN apk add --no-cache \
    bash \
    #pro pristup k HTTPS endpointum v HA:
    ca-certificates \
    python3 \
    py3-requests \
    py3-yaml \
&& update-ca-certificates

# Vytvoření adresářů a stažení FVE skriptů
RUN mkdir -p /opt/fve/config && mkdir -p /opt/fve/scripts && addgroup -S fvegroup && adduser -S fveuser -G fvegroup

WORKDIR /opt/fve
VOLUME /opt/fve/config

# Pokud je repo veřejné, ADD není ideální (kvůli cache), ale ok pro jednoduchost:
#ADD https://github.com/petos/pyFVE.git /opt/fve/scripts
COPY scripts/ /opt/fve/scripts/

RUN if [ "$PUBLISH" = "true" ]; then \
        echo ">>> Using remote repo"; \
        rm -rf /opt/fve/scripts/* && \
        apk add --no-cache git && \
        git clone --depth=1 https://github.com/petos/pyFVE.git /opt/fve/scripts && \
        apk del git; \
    else \
        echo ">>> Using local scripts"; \
    fi

COPY entrypoint.sh /opt/fve/entrypoint.sh

RUN chmod +x /opt/fve/entrypoint.sh \
 && chmod -R a+rwX /opt/fve

USER fveuser
ENTRYPOINT ["/opt/fve/entrypoint.sh"]
