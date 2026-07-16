# Getting Started

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (macOS/Windows) **or** Docker Engine + Compose v2 (Linux)
- `curl` and `openssl` on your PATH
- Free host ports **80** and **443**

## Install & run

```bash
git clone https://github.com/neeraj542/edgeforge-lab-networking.git
cd edgeforge-lab-networking

make up      # generates certs + builds + starts
make test    # should print 10 passed
```

Equivalent without Make:

```bash
chmod +x nginx/generate-certs.sh test-suite.sh
./nginx/generate-certs.sh
docker compose up --build -d --remove-orphans
./test-suite.sh
```

## What success looks like

```text
Passed: 10
Failed: 0
All tests passed. ns-cdn-lab is ready for demo.
```

## First manual request

```bash
curl -Ik --resolve ns-cdn-lab.local:443:127.0.0.1 https://ns-cdn-lab.local/
```

Look for:

- `x-cache-status: MISS` (or `HIT` on a second request)
- `x-origin-server: Flask-Backend-01`
- `x-served-by: ns-cdn-lab`
- `strict-transport-security: ...`

## Stop

```bash
make down
```

Next: [Concepts](concepts.md) · [Troubleshooting](troubleshooting.md)
