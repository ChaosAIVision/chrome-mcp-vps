#!/usr/bin/env bash
set -euo pipefail

DISPLAY_NUM="${DISPLAY_NUM:-99}"
SCREEN_WIDTH="${SCREEN_WIDTH:-1920}"
SCREEN_HEIGHT="${SCREEN_HEIGHT:-1080}"
SCREEN_DEPTH="${SCREEN_DEPTH:-24}"
SCREEN_RESOLUTION="${SCREEN_WIDTH}x${SCREEN_HEIGHT}x${SCREEN_DEPTH}"

MCP_PORT="${MCP_PORT:-3100}"
NOVNC_PORT="${NOVNC_PORT:-6080}"
VNC_PORT="${VNC_PORT:-5900}"
CHROME_DEBUG_PORT="${CHROME_DEBUG_PORT:-9222}"

CHROME_START_URL="${CHROME_START_URL:-about:blank}"
CHROME_USER_DATA_DIR="${CHROME_USER_DATA_DIR:-/data/chrome-profile}"
MCP_TRANSPORT="${MCP_TRANSPORT:-streamablehttp}"
MCP_EXTRA_ARGS="${MCP_EXTRA_ARGS:-}"

export DISPLAY=":${DISPLAY_NUM}"

mkdir -p "${CHROME_USER_DATA_DIR}" /tmp/.X11-unix /var/log
chmod 1777 /tmp/.X11-unix

echo "[startup] DISPLAY=${DISPLAY} resolution=${SCREEN_RESOLUTION}"
Xvfb "${DISPLAY}" -screen 0 "${SCREEN_RESOLUTION}" -ac +extension GLX +render -noreset >/var/log/xvfb.log 2>&1 &
sleep 1

fluxbox >/var/log/fluxbox.log 2>&1 &

x11vnc \
  -display "${DISPLAY}" \
  -rfbport "${VNC_PORT}" \
  -forever \
  -shared \
  -nopw \
  -listen 0.0.0.0 \
  >/var/log/x11vnc.log 2>&1 &

websockify --web=/usr/share/novnc "${NOVNC_PORT}" "127.0.0.1:${VNC_PORT}" >/var/log/novnc.log 2>&1 &

echo "[startup] Launching Chrome with remote debug port ${CHROME_DEBUG_PORT}"
google-chrome \
  --no-sandbox \
  --disable-dev-shm-usage \
  --no-first-run \
  --no-default-browser-check \
  --disable-gpu \
  --start-maximized \
  --window-size="${SCREEN_WIDTH},${SCREEN_HEIGHT}" \
  --remote-debugging-address=127.0.0.1 \
  --remote-debugging-port="${CHROME_DEBUG_PORT}" \
  --user-data-dir="${CHROME_USER_DATA_DIR}" \
  "${CHROME_START_URL}" \
  >/var/log/chrome.log 2>&1 &

sleep 2

MCP_CMD=(chrome-devtools-mcp "--browser-url=http://127.0.0.1:${CHROME_DEBUG_PORT}")
if [[ -n "${MCP_EXTRA_ARGS}" ]]; then
  # shellcheck disable=SC2206
  MCP_EXTRA_ARGS_ARR=(${MCP_EXTRA_ARGS})
  MCP_CMD+=("${MCP_EXTRA_ARGS_ARR[@]}")
fi

echo "[startup] MCP transport=${MCP_TRANSPORT} port=${MCP_PORT}"
echo "[startup] UI URL: http://<HOST_IP>:${NOVNC_PORT}/vnc.html?autoconnect=true&resize=scale"
echo "[startup] MCP URL: http://<HOST_IP>:${MCP_PORT}/sse"

if [[ "${MCP_TRANSPORT}" == "stdio" ]]; then
  exec "${MCP_CMD[@]}"
fi

exec mcp-proxy \
  --host 0.0.0.0 \
  --port "${MCP_PORT}" \
  --transport "${MCP_TRANSPORT}" \
  -- \
  "${MCP_CMD[@]}"
