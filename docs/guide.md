# Guide

Educational local CDN lab: Nginx edge in front of a hidden Flask origin.
**Not a production CDN** — use Cloudflare / CloudFront / Fastly for that.

## Run

Needs Docker Compose v2, free ports 80/443, `curl`, `openssl`.

```bash
make up
make test   # expect 10 passed
make down
```

```bash
curl -Ik --resolve ns-cdn-lab.local:443:127.0.0.1 https://ns-cdn-lab.local/
```

Look for `x-cache-status`, `x-origin-server`, `x-served-by`.

## Concepts

| Term | Here | Meaning |
|------|------|---------|
| Edge | `edge-proxy` (Nginx) | TLS, cache, basic security |
| Origin | `origin-server` (Flask) | Content source; no host ports |
| `MISS` | first fetch | Edge went to origin |
| `HIT` | cache hit | Served from Nginx `proxy_cache` |
| `BYPASS` | skipped cache | e.g. POST |

Flow: `Client → HTTPS → edge-proxy → HTTP → origin`

## Important files

| Path | Purpose |
|------|---------|
| `nginx/nginx.conf` | TLS, cache, security |
| `origin/app.py` | Demo origin + `Cache-Control` |
| `docker-compose.yml` | Network isolation |
| `test-suite.sh` | End-to-end checks |

## Caching

- Cache key: `$scheme$host$request_uri` (GET/HEAD share)
- Origin sends `Cache-Control: public, max-age=60`
- POST is never cached
- Stale can be served if origin errors (`proxy_cache_use_stale`)

```bash
curl -sk -D - -o /dev/null --resolve ns-cdn-lab.local:443:127.0.0.1 \
  "https://ns-cdn-lab.local/?demo=fixed" | grep -i x-cache
# run twice → expect HIT
```

## Security (lab-scale)

| Control | Response |
|---------|----------|
| HTTP → HTTPS | `301` |
| TLS 1.3 only | legacy TLS fails |
| Methods other than GET/HEAD/POST | `405` |
| Scanner UAs (nikto, sqlmap, …) | `403` |
| Rate limit (~10 r/s) | `429` |

TLS 1.3 ciphers must use `ssl_conf_command Ciphersuites` — not `ssl_ciphers`.

## Use your own app

- Host app: `make example-byo` → [examples/byo-origin](../examples/byo-origin/)
- Dockerized app: [examples/custom-origin](../examples/custom-origin/)
- Recipes: [examples.md](examples.md)

## Compared to real CDNs

| Production | This lab |
|------------|----------|
| Multi-PoP CDN | One local Nginx |
| Managed WAF / DDoS | Tiny filters for learning |
| Public CA certs | Self-signed lab certs |

Do not expose this default stack to the public Internet as-is.

Stuck? → [troubleshooting.md](troubleshooting.md)
