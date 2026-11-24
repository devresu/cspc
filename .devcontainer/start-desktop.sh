#!/usr/bin/env bash
set -euo pipefail

export DISPLAY="${DISPLAY:-:1}"
VNC_PORT="${VNC_PORT:-6901}"
VNC_PW="${VNC_PW:-vscode}"
VNC_ENABLE_AUTH="${VNC_ENABLE_AUTH:-0}"
RESOLUTION="${RESOLUTION:-1920x1080}"
VNC_DIR="$HOME/.vnc"

mkdir -p "$VNC_DIR"

# Load optional .env overrides from workspace if present
for env_file in ".env" "/workspaces/"*/.env; do
  if [ -f "$env_file" ]; then
    set -a
    # shellcheck disable=SC1090
    source "$env_file"
    set +a
    break
  fi
done

if [ ! -f "$VNC_DIR/kasmvnc.yaml" ] && [ -f /etc/kasmvnc/kasmvnc.yaml ]; then
  cp /etc/kasmvnc/kasmvnc.yaml "$VNC_DIR/kasmvnc.yaml"
fi

if [ ! -f "$VNC_DIR/xstartup" ]; then
  cat > "$VNC_DIR/xstartup" << 'EOF'
#!/usr/bin/env bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XDG_SESSION_TYPE=x11
export GDK_BACKEND=x11
exec dbus-launch --exit-with-session startxfce4
EOF
  chmod +x "$VNC_DIR/xstartup"
fi

# Ensure KasmVNC user credentials exist (and sync when VNC_ENABLE_AUTH=1)
if [ ! -f "$HOME/.kasmpasswd" ] || [ "$VNC_ENABLE_AUTH" = "1" ]; then
  printf '%s\n%s\n' "$VNC_PW" "$VNC_PW" | kasmvncpasswd -u "$USER" -wo >/dev/null 2>&1 || true
fi

# Start PulseAudio for browser audio streaming if available
if command -v pulseaudio >/dev/null 2>&1; then
  if ! pgrep -u "$USER" -x pulseaudio >/dev/null 2>&1; then
    pulseaudio --start --exit-idle-time=-1 --load="module-native-protocol-unix auth-anonymous=1 socket=/tmp/pulseaudio.socket" >/dev/null 2>&1 || true
  fi
fi

# Clean up stale X locks if container restarted without clean shutdown
if ! pgrep -u "$USER" -f "Xvnc.*${DISPLAY}" >/dev/null 2>&1; then
  rm -f "/tmp/.X1-lock" "/tmp/.X11-unix/X1" 2>/dev/null || true

  VNC_ARGS=(
    "$DISPLAY"
    "-select-de" "manual"
    "-geometry" "$RESOLUTION"
    "-depth" "24"
  )

  if [ "$VNC_ENABLE_AUTH" != "1" ]; then
    VNC_ARGS+=("-disableBasicAuth")
  fi

  vncserver "${VNC_ARGS[@]}"
fi

echo ""
echo "=========================================================="
echo " Linux Desktop PC is running on port ${VNC_PORT} (60 FPS)"
echo " Open the 'Ports' tab -> Port ${VNC_PORT} -> Open in Browser"
if [ "$VNC_ENABLE_AUTH" = "1" ]; then
  echo " Login: user=${USER} | password=${VNC_PW}"
else
  echo " Auth: Protected by GitHub Codespaces private port"
fi
echo "=========================================================="
