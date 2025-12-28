# Combined dev container with .NET, Node.js, and Browser (VNC + CDP)
FROM mcr.microsoft.com/devcontainers/dotnet:1-8.0

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install gh -y

# Install Node.js 22
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs

# Install Azure Functions Core Tools v4 via npm (more reliable cross-platform)
RUN npm install -g azure-functions-core-tools@4 --unsafe-perm true

# Install Redis server
RUN apt-get install -y redis-server

# Install poppler-utils for PDF text extraction (pdftotext, pdfinfo, pdfimages)
RUN apt-get install -y poppler-utils

# Install TailwindCSS standalone CLI
RUN curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/latest/download/tailwindcss-linux-x64 \
    && chmod +x tailwindcss-linux-x64 \
    && mv tailwindcss-linux-x64 /usr/local/bin/tailwindcss

# Install global npm packages and .NET tools
RUN npm install -g @azure/static-web-apps-cli azurite \
    && dotnet tool install --global dotnet-outdated-tool

# ============================================
# Browser packages (Chromium, VNC, noVNC, CDP)
# ============================================
RUN apt-get update && apt-get install -y \
    # Browser
    chromium \
    chromium-driver \
    # X server and window manager
    xvfb \
    fluxbox \
    x11-xserver-utils \
    # VNC server
    x11vnc \
    # noVNC for web-based VNC access
    novnc \
    websockify \
    # Fonts to reduce rendering issues
    fonts-dejavu \
    fonts-liberation \
    fonts-noto \
    # Process management
    tini \
    # Utilities
    socat \
    # Office document viewer (optional, for viewing docs)
    libreoffice-writer \
    libreoffice-calc \
    libreoffice-impress \
    && rm -rf /var/lib/apt/lists/*

# Create browser user and data directory
RUN useradd -m -s /bin/bash browser && \
    mkdir -p /data/chrome-profile && \
    chown -R browser:browser /data

# Copy browser startup script
COPY start-browser.sh /usr/local/bin/start-browser.sh
RUN chmod +x /usr/local/bin/start-browser.sh

# Browser environment variables
ENV DISPLAY=:99
ENV SCREEN_WIDTH=1920
ENV SCREEN_HEIGHT=1080
ENV SCREEN_DEPTH=24
ENV CDP_PORT=9222
ENV VNC_PORT=5900
ENV NOVNC_PORT=6080

# Add dotnet tools to PATH
ENV PATH="${PATH}:/root/.dotnet/tools:/home/vscode/.dotnet/tools"

# Expose browser ports (VNC, noVNC, CDP)
EXPOSE 5900 6080 9222
