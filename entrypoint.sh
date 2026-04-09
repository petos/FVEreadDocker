#!/bin/bash
set -e

trap stop SIGTERM SIGINT SIGQUIT SIGHUP ERR

function stop() {
  echo "END signal received, quitting"
  exit 0
}

python3 /opt/fve/scripts/FVctl.py
