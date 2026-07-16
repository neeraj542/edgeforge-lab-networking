# ns-cdn-lab

ns-cdn-lab is a local CDN-style edge lab. It uses Nginx as an edge proxy in front of a hidden Flask origin. The edge terminates TLS 1.3, redirects HTTP to HTTPS, caches origin responses using Nginx proxy cache, exposes cache status via headers, and applies basic edge security like method filtering, scanner User-Agent blocking, rate limiting, and security headers. The origin is cloaked because it is only reachable inside the Docker network.

**Local CDN-style edge lab** — TLS 1.3, response caching, origin cloaking, and basic edge security — so you can learn and test delivery patterns on personal projects in minutes.

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![CI](https://github.com/neeraj542/edgeforge-lab-networking/actions/workflows/ci.yml/badge.svg)](https://github.com/neeraj542/edgeforge-lab-networking/actions/workflows/ci.yml)

> **Not a production CDN.** ns-cdn-lab is an educational Docker stack. See [docs/production-notes.md](docs/production-notes.md).

## Why it helps

| You want to… | ns-cdn-lab gives you… |
|--------------|----------------------|
| Understand HIT vs MISS | `X-Cache-Status` on every proxied response |
| Demo HTTPS locally | TLS 1.3 edge with self-signed lab certs |
| Hide a side-project origin | Flask (or your app) unreachable from the host |
| Practice edge security | Method filter, scanner UA block, rate limits |
| Prepare for CDN / support interviews | Real headers, logs, and a test suite |

## Quick start (≈ 5 minutes)

**Requirements:** Docker + Compose v2, free ports 80/443, `curl`, `openssl`.

```bash
git clone https://github.com/neeraj542/edgeforge-lab-networking.git
cd edgeforge-lab-networking
make up
make test
```

Expected: **10 passed / 0 failed**.

### Manual peek

```bash
curl -Ik --resolve ns-cdn-lab.local:443:127.0.0.1 https://ns-cdn-lab.local/
```

## Architecture

```text
[ Client ] → edge-proxy:80/443 → [ cdn-network ] → origin-server:5000
                 │                                      │
                 │ TLS, cache, WAF-lite                 │ Cache-Control
                 │ X-Cache-Status                       │ X-Origin-Server
```

| Service | Role |
|---------|------|
| `edge-proxy` | Nginx edge — TLS, cache, security |
| `origin-server` | Demo Flask origin (not published to host) |

## Documentation

| Level | Guide |
|-------|-------|
| Beginner | [Getting Started](docs/getting-started.md) · [Concepts](docs/concepts.md) |
| Intermediate | [Architecture](docs/architecture.md) · [Caching](docs/caching.md) · [Security](docs/security.md) |
| Apply it | [Use Cases](docs/use-cases.md) · [Examples](docs/examples.md) |
| Expert | [Extending](docs/extending.md) · [Production notes](docs/production-notes.md) |
| Stuck? | [Troubleshooting](docs/troubleshooting.md) |

Full index: [docs/README.md](docs/README.md)

## Make targets

| Command | Description |
|---------|-------------|
| `make up` | Generate certs, build, start |
| `make test` | Run verification suite |
| `make logs` | Tail edge + origin logs |
| `make reload` | Reload Nginx after config edits |
| `make down` | Stop containers |
| `make clean` | Stop and wipe cache volume |
| `make example-static` | Run the static-site cache example |
| `make example-api` | Run the cache-aware API example |
| `make example-byo` | Run against a host app |

## License

Apache License 2.0 — see [LICENSE](LICENSE) and [NOTICE](NOTICE).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) and [ROADMAP.md](ROADMAP.md).  
Security reports: [SECURITY.md](SECURITY.md).
