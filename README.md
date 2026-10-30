# Deer Hunter 2005 Server (Docker)

This repository provides a Dockerized **Deer Hunter: The 2005 Season** dedicated server. DH2005 has no Linux server, so the image runs the game's built-in headless dedicated mode (`DH2005.exe -Dedicated_Server:TRUE`) under Wine.
The image builds on [`lancommander/wine`](https://github.com/LANCommander/LANCommander.Servers.WINE). It supports file overlaying using OverlayFS.

---

## Features

- Runs the retail game's own dedicated server mode (no graphics or sound are initialized)
- Native Microsoft DirectPlay installed into the Wine prefix automatically. Wine's builtin DirectPlay 8 can't host games.
- Every server setting is an environment variable, and the image builds the game's `-Setting:"value"` command line
- The game log (`Game/Game.LOG`) is streamed to `docker logs`
- Supports file overlaying using OverlayFS (no file copying required)

## Docker Compose Example

```yaml
services:
  deerhunter2005:
    image: lancommander/deerhunter2005:latest
    container_name: deerhunter2005

    ports:
      - "23459:23459/udp"
      - "6073:6073/udp"

    volumes:
      - ./config:/config

    environment:
      DH2005_SERVER_NAME: "My Deer Hunter Server"
      DH2005_GAME_TYPE: "BEST_TROPHY"
      DH2005_MAX_PLAYERS: "16"
      DH2005_SEASON: "RUT"

    cap_add:
      - SYS_ADMIN
    security_opt:
      - apparmor:unconfined

    restart: unless-stopped
```

DirectPlay is LAN-oriented and also opens dynamic UDP ports. A network where the container gets its own LAN IP (macvlan/ipvlan, or `network_mode: host`) is more reliable than port mapping.

---

## Game Files

Deer Hunter 2005 is retail software with no public download. You must provide a **v1.2** install:

- copy the game folder (the one containing `DH2005.exe`, `Aspen.dll` and `Game/`) to `config/Server/`, **or**
- set `DH2005_ARCHIVE_URL` to a zip of that folder. It is downloaded and extracted on first start, if `Server/DH2005.exe` doesn't exist yet.

## Directory Layout (Host)

```text
.
└── config/
    ├── Server/            # Deer Hunter 2005 install (DH2005.exe, Aspen.dll, Game/)
    ├── Overlay/           # Your files, layered on top of Server/ (the game's log and profiles also land here)
    ├── Merged/            # Overlayfs merged view (auto-created, the server runs here)
    ├── wineprefix/        # Wine prefix with native DirectPlay (auto-created)
    └── Scripts/
        └── Hooks/         # PowerShell scripts run at container lifecycle hooks
```

---

## Environment Variables

These are in addition to the [WINE image's variables](https://github.com/LANCommander/LANCommander.Servers.WINE#environment).
Each `DH2005_*` setting becomes a `-Name:"value"` argument. Settings left empty are not passed, and the game uses its default for them.

| Variable | Argument | Values | Default |
|----------|----------|--------|---------|
| `DH2005_SERVER_NAME` | `-Server_Name` | text | `Deer Hunter 2005 Server` |
| `DH2005_MESSAGE_OF_THE_DAY` | `-Message_of_the_Day` | text | `Welcome! Have fun!` |
| `DH2005_PASSWORD` | `-Password` | text | |
| `DH2005_GAME_TYPE` | `-Game_Type` | `BEST_TROPHY`, `MOST_POINTS`, `FIRST_TROPHY` | `BEST_TROPHY` |
| `DH2005_MAX_PLAYERS` | `-Max_Players` | 1-32 | `16` |
| `DH2005_LOCATION` | `-Location` | location name, part of the name, or filename | *(game picks)* |
| `DH2005_SEASON` | `-Season` | `PRE-RUT`, `RUT`, `POST-RUT` | |
| `DH2005_DIFFICULTY` | `-Difficulty` | `EASY`, `NORMAL`, `EXPERT` | |
| `DH2005_RANDOM_MAPS` | `-Random_Maps` | `TRUE`/`FALSE` | `TRUE` |
| `DH2005_TIME_LIMIT` | `-Time_Limit` | 0-1000 minutes, 0 = end of day | `20` |
| `DH2005_SHOW_HUNTERS_IN_GPS` | `-Show_Hunters_in_GPS` | `TRUE`/`FALSE` | `TRUE` |
| `DH2005_PUBLISH_IN_GAMESPY` | `-Publish_in_Gamespy` | `TRUE`/`FALSE` | `FALSE` |
| `DH2005_AUTO_KICK_PEOPLE_SHOOTERS` | `-Auto_kick_People_Shooters` | `TRUE`/`FALSE` | `TRUE` |
| `DH2005_ALLOW_VOTING` | `-Allow_Voting` | `TRUE`/`FALSE` | `TRUE` |
| `DH2005_VIEW_DISTANCE` | `-View_Distance` | 0-100 | |
| `DH2005_TREE_DENSITY` | `-Tree_Density` | 0-100 | |
| `DH2005_WEATHER` | `-Weather` | 0-100 | |
| `DH2005_TIME_MULTIPLIER` | `-Time_Multiplier` | 1-25 | |
| `DH2005_FIRST_DAY_HOUR` | `-First_Day_Hour` | 6-17 | |
| `DH2005_DISABLED_ITEMS` | `-Disabled_Items` | comma list, see below | |
| `DH2005_EXTRA_ARGS` | | raw text appended to the command line | |
| `DH2005_ARCHIVE_URL` | | zip of the game folder, used if `Server/DH2005.exe` is missing | |

`DH2005_DISABLED_ITEMS` categories: `Rifles, Muzzleloaders, Shotguns, Handguns, Bows, Crossbows, Scopes, GPS, Concealment, Horse, ATV, Scents, Calls, Electronic_calls, Food, Attractant, Thermal_vision, Cameras`.

GameSpy no longer exists, so leave `DH2005_PUBLISH_IN_GAMESPY` off. Clients join from the in-game LAN search, or by IP.

See [Documentation/Docker.md](Documentation/Docker.md) for more detail.

---

## Building

The image is built `FROM lancommander/wine:latest` by default. To build against a local base image:

```bash
docker build --build-arg BASE_IMAGE=lancommander/wine:local -t lancommander/deerhunter2005:local .
```

The DirectX February 2010 redistributable (source of the DirectPlay DLLs) is downloaded at build time and verified by sha256. See `DIRECTX_REDIST_URL` / `DIRECTX_REDIST_SHA256` in the Dockerfile.

---

## License

Deer Hunter 2005, Wine and the DirectX redistributable are distributed under their respective licenses.
This repository contains only Docker build logic and helper scripts licensed under MIT.
