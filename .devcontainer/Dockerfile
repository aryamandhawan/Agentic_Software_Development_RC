# Combined dev container with .NET, Node.js, and Browser (VNC + CDP)
# Using Debian bookworm base with .NET 9 SDK installed manually
FROM mcr.microsoft.com/devcontainers/base:bookworm

# Remove Yarn apt repository (has expired GPG key in base image, causing apt-get update to fail)
RUN rm -f /etc/apt/sources.list.d/yarn.list

# Install .NET 9 SDK
RUN wget https://dot.net/v1/dotnet-install.sh -O /tmp/dotnet-install.sh \
    && chmod +x /tmp/dotnet-install.sh \
    && /tmp/dotnet-install.sh --channel 9.0 --install-dir /usr/share/dotnet \
    && ln -s /usr/share/dotnet/dotnet /usr/local/bin/dotnet \
    && rm /tmp/dotnet-install.sh

# Set .NET environment variables
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH="${PATH}:/usr/share/dotnet:/home/vscode/.dotnet/tools"
ENV NUGET_XMLDOC_MODE=

# Grant write permissions to dotnet directory (matches official image behavior)
RUN chmod -R a+w /usr/share/dotnet

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

# Install dos2unix for line ending conversion (safety measure for Windows users)
RUN apt-get install -y dos2unix

# Install poppler-utils for PDF text extraction (pdftotext, pdfinfo, pdfimages)
RUN apt-get install -y poppler-utils

# Install jq for JSON processing (useful for Azure CLI and API responses)
RUN apt-get install -y jq

# Install TailwindCSS standalone CLI (architecture-aware)
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "arm64" ]; then \
        curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/latest/download/tailwindcss-linux-arm64; \
        chmod +x tailwindcss-linux-arm64; \
        mv tailwindcss-linux-arm64 /usr/local/bin/tailwindcss; \
    else \
        curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/latest/download/tailwindcss-linux-x64; \
        chmod +x tailwindcss-linux-x64; \
        mv tailwindcss-linux-x64 /usr/local/bin/tailwindcss; \
    fi

# Install global npm packages
RUN npm install -g @azure/static-web-apps-cli azurite

# Install .NET tools for vscode user
USER vscode
RUN dotnet tool install --global dotnet-outdated-tool
USER root

# ============================================
# Browser packages (Chromium, VNC, noVNC, CDP)
# ============================================
RUN apt-get update && apt-get install -y \
    # Browser (works via apt on Debian, unlike Ubuntu which requires snap)
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

# Expose browser ports (VNC, noVNC, CDP)
EXPOSE 5900 6080 9222
