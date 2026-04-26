# CloudNet MOOC

Archive of a 2017 cloud networking course. The project simulates a virtual datacenter using Mininet (network emulator) and Ryu (SDN controller).

## Running with Docker

Mininet requires Linux kernel features and Python 2, so Docker is the easiest way to run this on a modern Mac.

### Build

```bash
docker compose build
```

### Run

You need two terminals because Mininet and Ryu run as separate processes.

**Terminal 1 — start the container and launch Mininet:**

```bash
docker compose run --rm mdc
# inside the container:
python2 mdc --vid
# it will print "start ryu<ENTER>" and pause — leave this terminal open
```

**Terminal 2 — exec into the same container and start Ryu:**

```bash
docker ps                          # find the container ID
docker exec -it <container_id> bash
# inside the container:
cd /app/minidc/controller
ryu-manager controller.py
```

> **Important:** use `docker exec`, not `docker compose run`. A second `docker compose run`
> starts a fresh container with its own `localhost`, so Ryu and Mininet can't see each other.

Then go back to Terminal 1 and press Enter. The Mininet CLI (`mininet>`) will appear and the PHP dashboard will be available on port 80.

### Profile options

| Flag    | Description                          |
|---------|--------------------------------------|
| `--vid` | Assignment 1–3 profile (video streaming) |
| `--adp` | Assignment 4 profile (load balancing) |
