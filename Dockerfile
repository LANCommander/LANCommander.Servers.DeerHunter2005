# syntax=docker/dockerfile:1.7

# Override to build against a locally built base, e.g. lancommander/wine:local
ARG BASE_IMAGE=lancommander/wine:latest
FROM ${BASE_IMAGE}

# Native DirectPlay comes from the DirectX February 2010 redist. Wine's builtin dpnet cannot host
# (IDirectPlay8Server::Host is a stub), so the redist is cached in the image and installed into the
# prefix with `winetricks directplay` on first start. Microsoft's own URL is gone; this is the mirror
# winetricks pins, checked against the same sha256.
ARG DIRECTX_REDIST_URL="https://files.holarse-linuxgaming.de/mirrors/microsoft/directx_feb2010_redist.exe"
ARG DIRECTX_REDIST_SHA256="f6d191e89a963d7cca34f169d30f49eab99c1ed3bb92da73ec43617caaa1e93f"

# ----------------------------
# Server settings
#   - The game files are not downloadable; put a Deer Hunter 2005 v1.2 install in /config/Server,
#     or set DH2005_ARCHIVE_URL to a zip of one
#   - Each DH2005_* setting maps to a -Name:value argument; empty settings are left out
# ----------------------------
ENV W_CACHE=/opt/winetricks-cache \
    DH2005_ARCHIVE_URL="" \
    DH2005_SERVER_NAME="Deer Hunter 2005 Server" \
    DH2005_MESSAGE_OF_THE_DAY="Welcome! Have fun!" \
    DH2005_PASSWORD="" \
    DH2005_GAME_TYPE="BEST_TROPHY" \
    DH2005_MAX_PLAYERS="16" \
    DH2005_LOCATION="" \
    DH2005_SEASON="" \
    DH2005_DIFFICULTY="" \
    DH2005_RANDOM_MAPS="TRUE" \
    DH2005_TIME_LIMIT="20" \
    DH2005_SHOW_HUNTERS_IN_GPS="TRUE" \
    DH2005_PUBLISH_IN_GAMESPY="FALSE" \
    DH2005_AUTO_KICK_PEOPLE_SHOOTERS="TRUE" \
    DH2005_ALLOW_VOTING="TRUE" \
    DH2005_VIEW_DISTANCE="" \
    DH2005_TREE_DENSITY="" \
    DH2005_WEATHER="" \
    DH2005_TIME_MULTIPLIER="" \
    DH2005_FIRST_DAY_HOUR="" \
    DH2005_DISABLED_ITEMS="" \
    DH2005_EXTRA_ARGS="" \
    START_EXE="/usr/local/bin/dh2005-server" \
    START_ARGS=""

RUN set -eux; \
    mkdir -p "${W_CACHE}/directx9"; \
    curl -fsSL --retry 3 "${DIRECTX_REDIST_URL}" -o "${W_CACHE}/directx9/directx_feb2010_redist.exe"; \
    echo "${DIRECTX_REDIST_SHA256}  ${W_CACHE}/directx9/directx_feb2010_redist.exe" | sha256sum -c -

COPY Scripts/dh2005-server /usr/local/bin/dh2005-server
RUN chmod +x /usr/local/bin/dh2005-server

COPY Hooks/ "${BASE_HOOKS}/"

# 23459/udp: game (DirectPlay host). 6073/udp: DirectPlay session enumeration (dpnsvr).
EXPOSE 23459/udp 6073/udp

WORKDIR /config
ENTRYPOINT ["/usr/local/bin/entrypoint.ps1"]
