#!/usr/bin/env bash
# Disable PAI if you don't want it
if [ "$RSTUDIO_DISABLE_POSIT_ASSISTANT" = "true" ]; then
    if ! grep -q "RSTUDIO_DISABLE_POSIT_ASSISTANT" /home/jovyan/.Renviron 2>/dev/null; then
        echo "RSTUDIO_DISABLE_POSIT_ASSISTANT=${RSTUDIO_DISABLE_POSIT_ASSISTANT}" >> /home/jovyan/.Renviron
        chown -R ${NB_USER:-jovyan}:${NB_GID:-100} /home/jovyan/.Renviron
   fi
else
    # We're not disabling PAI, so set up the TUI and the RStudio 
    if [ ! -f /home/jovyan/.local/share/rstudio/pai/bin/pa ]; then
        mkdir -p /home/jovyan/.local/share/rstudio/pai/bin
        curl -fsSL https://assistant.posit.co/builds/install-tui.sh | INSTALL_DIR=/home/jovyan/.local/share/rstudio/pai/bin bash
    fi
    ln -sf /home/jovyan/.local/share/rstudio/pai/bin/pa /usr/local/bin/pa
    MANIFEST_JSON=$(curl -fsSL https://cdn.posit.co/posit-ai/manifest.json)
    PAI_URL=$(echo "$MANIFEST_JSON" | jq -r '.versions | to_entries | last | .value.url')
    PAI_VERSION=$(echo "$MANIFEST_JSON" | jq -r '.versions | to_entries | last | .value.version')
    TARGET_DIR="/home/jovyan/.local/share/rstudio/pai/versions/${PAI_VERSION}"
    if [ -z "$PAI_URL" ] || [ "$PAI_URL" = "null" ] || [ -z "$PAI_VERSION" ] || [ "$PAI_VERSION" = "null" ]; then
        echo "Warning: PAI_URL or PAI_VERSION is missing or null. (This is likely a network issue) Exiting script."
        exit 0
    fi
    if [ ! -d "${TARGET_DIR}" ]; then
        mkdir -p "$TARGET_DIR"
        wget -O /tmp/assistant.zip "$PAI_URL"
        unzip -oq /tmp/assistant.zip -d "$TARGET_DIR"
        rm -f /tmp/assistant.zip
    fi
    chown -R ${NB_USER:-jovyan}:${NB_GID:-100} /home/jovyan/.local/share/rstudio/pai
fi
