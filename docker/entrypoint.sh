#!/usr/bin/env bash
set -euo pipefail

mkdir -p /root/.chat2api

if [ ! -f /root/.chat2api/data.json ]; then
  cp /app/docker/default-data.json /root/.chat2api/data.json
fi

Xvfb :99 -screen 0 1280x720x24 >/tmp/xvfb.log 2>&1 &

exec npx electron . --no-sandbox
