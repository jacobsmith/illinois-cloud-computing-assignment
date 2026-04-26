# CloudNet MOOC

Archive of a 2017 cloud networking course. The project simulates a virtual datacenter using Mininet (network emulator) and Ryu (SDN controller).

> **Note:** This repository contains no answers or solutions. It is a snapshot of the original course VirtualBox VM image, reformatted to run in Docker on modern hardware. The assignment code stubs are exactly as distributed to students in 2017.

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) for Mac

## Running with Docker

Mininet requires Linux kernel features and Python 2, so Docker handles all of that for you.

### First-time setup

```bash
docker compose build   # takes a few minutes
```

### Run

You need two terminals because Mininet and Ryu run as separate processes.

**Terminal 1 — start the container and launch Mininet:**

```bash
docker compose run --service-ports --rm mdc
# inside the container:
python2 mdc --vid
# prints "start ryu<ENTER>" and pauses — leave this terminal open
```

**Terminal 2 — exec into the same container and start Ryu:**

```bash
docker ps                           # copy the container ID from the list
docker exec -it <container_id> bash
# inside the container:
cd /app/minidc/controller
ryu-manager controller.py
```

> **Important:** use `docker exec`, not `docker compose run`. A second `docker compose run`
> starts a fresh container with its own `localhost`, so Ryu and Mininet can't see each other.

Back in Terminal 1, press Enter. The Mininet CLI (`mininet>`) will appear.

### Accessing the UIs

| URL | What it is |
|-----|-----------|
| `http://localhost:8080` | Dashboard — bandwidth and tenant stats |
| `http://localhost:8081/streaming.html` | DASH adaptive video player (Big Buck Bunny) |

Both are available once the Mininet CLI appears (after pressing Enter).

### Editing files

The project directory is bind-mounted into the container at `/app`, so any edits you make on your Mac take effect immediately. Just restart `python2 mdc --vid` inside the container — no rebuild needed.

You only need to rebuild (`docker compose build`) when you change `Dockerfile` or `docker-entrypoint.sh`.

### Profile options

| Flag    | Description                          |
|---------|--------------------------------------|
| `--vid` | Assignment 1–3 profile (video streaming) |
| `--adp` | Assignment 4 profile (load balancing) |

### Expected startup noise

These messages appear on every start and are harmless:

```
modprobe: FATAL: Module openvswitch not found in directory /lib/modules/...-linuxkit
```
OVS is built into Docker Desktop's Linux kernel rather than available as a loadable module. The entrypoint works around this automatically.

```
*** Error: Error: Cannot delete qdisc with handle of zero.
```
Traffic shaping (TCLink) partially fails in the container environment. The network still runs.

```
Unable to contact the remote controller at 127.0.0.1:6633
```
Mininet's pre-check uses `telnet` which isn't installed. The controller connection still works — ignore this warning.

### Notes on Chrome

The `--vid` profile is designed to launch a Chrome browser on virtual host `h2` to stream video from `h1`. This requires a display and won't work in Docker. The video content is instead served directly at `localhost:8081/streaming.html`. The dashboard and Ryu controller functionality work normally.
