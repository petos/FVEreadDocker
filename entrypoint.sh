#!/bin/bash
set -e

export USER_ID=$(id -u)
export GROUP_ID=$(id -g)

# Vytvoř fejkované passwd/skupiny pro nss_wrapper
export NSS_WRAPPER_PASSWD=/tmp/passwd
export NSS_WRAPPER_GROUP=/tmp/group

echo "fve:x:$USER_ID:$GROUP_ID::/opt/fve:/bin/bash" > "$NSS_WRAPPER_PASSWD"
echo "fve:x:$GROUP_ID:" > "$NSS_WRAPPER_GROUP"

# Aktivuj knihovnu nss_wrapper
export LD_PRELOAD=libnss_wrapper.so
export PATH=$PATH:/opt/fve/scripts/
# Spusť jako 'fve' (fiktivní jméno)

FILE="/opt/fve/api/api.json"

if [ ! -f "$FILE" ]; then
    echo "Error: Soubor $FILE neexistuje!" >&2
    mkdir -p "$(dirname $FILE)"
    touch "$FILE"
fi

if [ -f /etc/letsencrypt/live/fvechecker.petos.eu/fullchain.pem ] && [ -f /etc/letsencrypt/live/fvechecker.petos.eu/privkey.pem ]; then
    echo '[server] SSL certifikaty nalezeny, spoustim HTTPS server...';
    exec python3 -m http.server 443 \
      --bind 0.0.0.0 \
      --directory /opt/fve/api \
      --certfile /etc/letsencrypt/live/fvechecker.petos.eu/fullchain.pem \
      --keyfile /etc/letsencrypt/live/fvechecker.petos.eu/privkey.pem &
#      --no-index
else
    echo '[server] SSL certifikaty NEBYLY nenalezeny, spoustim HTTP server...';
    exec python3 -m http.server 80 \
      --bind 0.0.0.0 \
      --directory /opt/fve/api &
#      --no-index
fi

exec "$@"
