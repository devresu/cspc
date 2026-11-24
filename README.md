# Linux Codespace PC (High-FPS Web Desktop + Google Chrome)

A ready-to-upload GitHub Codespaces configuration that turns any GitHub Codespace into a **web-accessible Linux Desktop PC** powered by **Ubuntu 24.04**, **XFCE4** (compositor disabled for snappy response), **KasmVNC** (up to **60 FPS** over WebSockets with dynamic resolution & audio), and **Google Chrome** preinstalled.

---

## Quick Start

### 1. Upload to GitHub
You can either run `start.bat` on Windows (Option 2) or push manually:

```bash
git init -b main
git add .
git commit -m "Add Linux Codespace PC"
# Create a repo on GitHub, then:
git remote add origin https://github.com/<YOUR_USER>/<YOUR_REPO>.git
git push -u origin main
```

### 2. Launch the Codespace
1. Open your repository on GitHub.
2. Click **Code** -> **Codespaces** -> **... (New with options)** -> **Create codespace on main**.
3. **Recommended Machine Type:** Choose **4-core** or **8-core** (Codespaces includes 2-core minimum, but 4+ cores makes 60 FPS WebP/JPEG encoding and Google Chrome much smoother).

### 3. Access the Linux PC in Your Web Browser
1. Once the Codespace finishes building (~2–4 minutes on first build), open the **Ports** tab in the bottom panel of VS Code Web.
2. Find port **`6901`** (`Linux Desktop PC (Web)`).
3. Click the **Globe icon ("Open in Browser")** (or accept the auto-forwarded browser popup).
4. Your Ubuntu desktop will open full-screen directly in your browser. **Google Chrome** is on the Desktop and in the Applications menu.

---

## Tuning for Maximum FPS & Lowest Latency

KasmVNC is preconfigured in [`.devcontainer/kasmvnc.yaml`](.devcontainer/kasmvnc.yaml) for **60 FPS** and **HTTP/WebSocket** forwarding (zero SSL cert popups behind GitHub Codespaces' HTTPS proxy):

- **In the browser sidebar (left edge tab -> Settings):**
  - **Streaming Quality / Preset:** Choose **High** or **Custom** with **Frame Rate = 60**.
  - **Prefer WebP** or **Adaptive** mode gives crisp text and smooth video playback.
  - **Enable Audio:** Click the speaker icon in the KasmVNC toolbar to stream browser/YouTube audio over WebSockets.
- **Compositor Disabled:** XFCE window compositing (`use_compositing = false`) and `vblank_mode = off` are preconfigured so window dragging and Chrome scrolling have zero desktop-compositor lag.
- **2 GB Shared Memory (`--shm-size=2gb`):** Configured in [`.devcontainer/devcontainer.json`](.devcontainer/devcontainer.json) so Chrome tabs never crash under heavy usage.

> **Note on Latency & Hardware Limits:** GitHub Codespaces VMs use CPU-based rendering (no dedicated GPU) and forward traffic through GitHub's cloud region. While KasmVNC delivers up to 60 FPS with minimal encoding overhead, true 0 ms latency is physically bounded by your network ping to the Codespace region (choose the closest GitHub region in your GitHub Codespaces settings for lowest latency).

---

## Optional Configuration

- **Enable VNC Password Prompt:** By default, port `6901` is private to your GitHub account via Codespaces authentication. If you ever make the port public or want an extra password prompt, copy [`.env.example`](.env.example) to `.env`, set `VNC_ENABLE_AUTH=1` and a strong `VNC_PW`, and restart the desktop:
  ```bash
  vncserver -kill :1 && bash /usr/local/bin/start-desktop.sh
  ```
- **Manual Restart:** If the desktop ever stops, run:
  ```bash
  bash /usr/local/bin/start-desktop.sh
  ```

---

## Project Structure

- [`.devcontainer/devcontainer.json`](.devcontainer/devcontainer.json) — Codespaces VM config, 2 GB `/dev/shm`, port `6901` auto-forward, startup hook.
- [`.devcontainer/Dockerfile`](.devcontainer/Dockerfile) — Ubuntu 24.04, XFCE4, PulseAudio, Google Chrome, and KasmVNC installation.
- [`.devcontainer/kasmvnc.yaml`](.devcontainer/kasmvnc.yaml) — 60 FPS WebSocket & adaptive WebP/JPEG configuration.
- [`.devcontainer/start-desktop.sh`](.devcontainer/start-desktop.sh) — Idempotent desktop & audio startup script.
- [`.devcontainer/launch-chrome.sh`](.devcontainer/launch-chrome.sh) — Container-safe Google Chrome launcher.
- [`start.bat`](start.bat) — Optional Windows helper to push to GitHub and launch Codespaces.
