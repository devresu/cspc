FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:1 \
    VNC_PORT=6901 \
    VNC_PW=vscode \
    VNC_ENABLE_AUTH=0 \
    RESOLUTION=1920x1080 \
    PULSE_SERVER=unix:/tmp/pulseaudio.socket

# Install lightweight XFCE4 desktop, audio, fonts, and essential tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    xfce4 \
    xfce4-terminal \
    xfce4-whiskermenu-plugin \
    thunar \
    mousepad \
    dbus-x11 \
    x11-xserver-utils \
    xdg-utils \
    pulseaudio \
    pavucontrol \
    mesa-utils \
    libgl1 \
    libglu1-mesa \
    fonts-liberation \
    fonts-noto-color-emoji \
    htop \
    curl \
    wget \
    ca-certificates \
    jq \
    unzip \
    sudo \
    ssl-cert \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Google Chrome (amd64) or Chromium fallback (arm64)
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then \
        curl -fsSL "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" -o /tmp/chrome.deb && \
        apt-get update && apt-get install -y --no-install-recommends /tmp/chrome.deb && \
        rm -f /tmp/chrome.deb; \
    else \
        apt-get update && apt-get install -y --no-install-recommends chromium-browser; \
    fi && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install latest KasmVNC for Ubuntu 24.04 (Noble), with pinned fallback
RUN ARCH=$(dpkg --print-architecture) && \
    KASMVNC_URL=$(curl -fsSL "https://api.github.com/repos/kasmtech/KasmVNC/releases/latest" \
        | jq -r --arg arch "$ARCH" '.assets[] | select(.name | test("kasmvncserver_noble_.*_" + $arch + "\\.deb$")) | .browser_download_url' \
        | head -n 1 || true) && \
    if [ -z "$KASMVNC_URL" ] || [ "$KASMVNC_URL" = "null" ]; then \
        KASMVNC_URL="https://github.com/kasmtech/KasmVNC/releases/download/v1.4.0/kasmvncserver_noble_1.4.0_${ARCH}.deb"; \
    fi && \
    echo "Downloading KasmVNC from: $KASMVNC_URL" && \
    curl -fsSL "$KASMVNC_URL" -o /tmp/kasmvncserver.deb && \
    apt-get update && apt-get install -y --no-install-recommends /tmp/kasmvncserver.deb && \
    rm -f /tmp/kasmvncserver.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Ensure vscode user has required groups for KasmVNC & audio
RUN usermod -aG ssl-cert,audio,video vscode

# Copy KasmVNC config, xstartup, Chrome launcher, and desktop startup script
COPY kasmvnc.yaml /etc/kasmvnc/kasmvnc.yaml
COPY xstartup /home/vscode/.vnc/xstartup
COPY launch-chrome.sh /usr/local/bin/launch-chrome
COPY start-desktop.sh /usr/local/bin/start-desktop.sh

# Normalize line endings and set permissions
RUN sed -i 's/\r$//' /etc/kasmvnc/kasmvnc.yaml /home/vscode/.vnc/xstartup /usr/local/bin/launch-chrome /usr/local/bin/start-desktop.sh && \
    chmod +x /home/vscode/.vnc/xstartup /usr/local/bin/launch-chrome /usr/local/bin/start-desktop.sh && \
    cp /etc/kasmvnc/kasmvnc.yaml /home/vscode/.vnc/kasmvnc.yaml && \
    mkdir -p /home/vscode/Desktop /home/vscode/.config/xfce4/xfconf/xfce-perchannel-xml && \
    printf 'WebBrowser=google-chrome\n' > /home/vscode/.config/xfce4/helpers.rc && \
    chown -R vscode:vscode /home/vscode/.vnc /home/vscode/Desktop /home/vscode/.config

# Disable XFCE window compositor for lowest latency and highest FPS
RUN printf '%s\n' \
    '<?xml version="1.0" encoding="UTF-8"?>' \
    '<channel name="xfwm4" version="1.0">' \
    '  <property name="general" type="empty">' \
    '    <property name="use_compositing" type="bool" value="false"/>' \
    '    <property name="vblank_mode" type="string" value="off"/>' \
    '  </property>' \
    '</channel>' \
    > /home/vscode/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml && \
    printf '%s\n' \
    '<?xml version="1.0" encoding="UTF-8"?>' \
    '<channel name="xsettings" version="1.0">' \
    '  <property name="Net" type="empty">' \
    '    <property name="ThemeName" type="string" value="Adwaita-dark"/>' \
    '    <property name="EnableEventSounds" type="bool" value="false"/>' \
    '  </property>' \
    '</channel>' \
    > /home/vscode/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml && \
    chown -R vscode:vscode /home/vscode/.config

# Add Google Chrome desktop shortcut, wrap PATH commands, and set as default browser
RUN ln -sf /usr/local/bin/launch-chrome /usr/local/bin/google-chrome && \
    ln -sf /usr/local/bin/launch-chrome /usr/local/bin/google-chrome-stable && \
    printf '%s\n' \
    '[Desktop Entry]' \
    'Version=1.0' \
    'Name=Google Chrome' \
    'Comment=Fast Web Browser' \
    'Exec=/usr/local/bin/launch-chrome %U' \
    'Terminal=false' \
    'Icon=google-chrome' \
    'Type=Application' \
    'Categories=Network;WebBrowser;' \
    > /home/vscode/Desktop/google-chrome.desktop && \
    cp /home/vscode/Desktop/google-chrome.desktop /usr/share/applications/google-chrome-codespace.desktop && \
    if [ -f /usr/share/applications/google-chrome.desktop ]; then \
        sed -i 's|^Exec=/usr/bin/google-chrome-stable|Exec=/usr/local/bin/launch-chrome|g' /usr/share/applications/google-chrome.desktop; \
    fi && \
    chmod +x /home/vscode/Desktop/google-chrome.desktop && \
    chown vscode:vscode /home/vscode/Desktop/google-chrome.desktop

EXPOSE 6901
