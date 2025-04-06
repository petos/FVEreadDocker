FROM debian:bullseye-slim

LABEL maintainer="petos@petos.eu"
LABEL description="Simple FVE toolkit"
LABEL version="1.0"

# Instalace nezbytných nástrojů, minimalizace image
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    bc \
    ca-certificates \
    curl \
    jq \
    libnss-wrapper \
    python3 \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Smazání zbytečného uživatele (jen pokud existuje)
RUN userdel -r ubuntu 2>/dev/null || true

# Vytvoření adresářů a stažení FVE skriptů
RUN mkdir -p /opt/fve/{data,config,scripts,api}

WORKDIR /opt/fve

# Pokud je repo veřejné, ADD není ideální (kvůli cache), ale ok pro jednoduchost:
ADD https://github.com/petos/FVEread.git /opt/fve/scripts

COPY entrypoint.sh /opt/fve/entrypoint.sh
RUN chmod +x /opt/fve/entrypoint.sh \
 && chmod -R a+rwX /opt/fve \
 && touch /etc/tellstick.conf && chmod a+r /etc/tellstick.conf \
 && rm -rf /usr/share/doc /usr/share/man /usr/share/info /usr/share/locale/* 

EXPOSE 80 443

ENTRYPOINT ["/opt/fve/entrypoint.sh"]
CMD ["FVEloop"]
