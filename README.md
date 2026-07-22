# ns-cdn-lab

**Local CDN lab** — Nginx reverse proxy + `proxy_cache` + TLS 1.3 + origin cloaking.

Learn edge delivery (HIT/MISS, HTTPS, basic WAF-lite) without Cloudflare / CloudFront.

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![CI](https://github.com/neeraj542/edgeforge-lab-networking/actions/workflows/ci.yml/badge.svg)](https://github.com/neeraj542/edgeforge-lab-networking/actions/workflows/ci.yml)

> Lab only — not a production CDN. Details in [docs/guide.md](docs/guide.md).

## Quick start

```bash
git clone https://github.com/neeraj542/edgeforge-lab-networking.git
cd edgeforge-lab-networking
make up
make test
```

Expected: **10 passed / 0 failed**.

```bash
curl -Ik --resolve ns-cdn-lab.local:443:127.0.0.1 https://ns-cdn-lab.local/
```

## How it works

<p align="center">
  <img src="docs/images/architecture.jpg" alt="Client → Nginx edge-proxy → hidden Flask origin" width="720" />
</p>

| Service | Role |
|---------|------|
| `edge-proxy` | Nginx — TLS, cache, security |
| `origin-server` | Flask origin (no host ports) |

## Docs

- [Guide](docs/guide.md) — concepts, cache, security, extending
- [Examples](docs/examples.md) — static / API / BYO origin
- [Troubleshooting](docs/troubleshooting.md)

## Make targets

| Command | What it does |
|---------|--------------|
| `make up` / `make test` / `make down` | Start, verify, stop |
| `make logs` / `make reload` / `make clean` | Debug / reload / wipe cache |
| `make example-static` / `example-api` / `example-byo` | Recipe origins |

## License

Apache 2.0 — [LICENSE](LICENSE) · [NOTICE](NOTICE) · [CONTRIBUTING.md](CONTRIBUTING.md) · [SECURITY.md](SECURITY.md)
