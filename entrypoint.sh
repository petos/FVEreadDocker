#!/bin/bash
set -e

trap stop SIGTERM SIGINT SIGQUIT SIGHUP ERR

function stop() {
  echo "END signal received, quitting"
  exit 0
}

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

python3 /opt/fve/scripts/FVctl.py
