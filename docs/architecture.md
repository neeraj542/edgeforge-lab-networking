# Architecture

## High-level

```text
┌─────────────────────────────────────────────────────────────┐
│ Host (your laptop)                                          │
│                                                             │
│   curl / browser                                            │
│        │ :80  → 301 HTTPS                                   │
│        ▼ :443 TLS 1.3                                       │
│   ┌─────────────────────┐      cdn-network (bridge)         │
│   │ edge-proxy (Nginx)  │ ───────────────────────────────►  │
│   │  cache + WAF-lite   │      HTTP :5000                   │
│   └─────────────────────┘                    ┌────────────┐ │
│                                              │ origin     │ │
│                                              │ Flask :5000│ │
│                                              │ (no host   │ │
│                                              │  publish)  │ │
│                                              └────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Services

| Compose service | Image / build | Host ports | Role |
|-----------------|---------------|------------|------|
| `edge-proxy` | `nginx:1.27-alpine` | `80`, `443` | Edge |
| `origin-server` | `./origin` Dockerfile | none | Origin |

## Important paths

| Path | Purpose |
|------|---------|
| `nginx/nginx.conf` | Edge behavior (TLS, cache, security) |
| `nginx/generate-certs.sh` | Lab certificate generator |
| `origin/app.py` | Demo origin + cache headers |
| `test-suite.sh` | End-to-end verification |
| `docker-compose.yml` | Network isolation + volumes |

## Request lifecycle (happy path)

1. Client hits `http://ns-cdn-lab.local/` → **301** to HTTPS
2. TLS 1.3 handshake at edge
3. Security gates (UA, method, rate limit)
4. Cache lookup → `MISS` → proxy to origin
5. Origin returns body + `Cache-Control: public, max-age=60`
6. Edge stores object; response includes `X-Cache-Status: MISS`
7. Second request within TTL → `X-Cache-Status: HIT`

Next: [Caching](caching.md) · [Security](security.md)
