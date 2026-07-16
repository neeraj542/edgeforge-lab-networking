# Extending EdgeForge

## Point the edge at your own app

See the worked example: [examples/custom-origin](../examples/custom-origin/).

High-level steps:

1. Run your app on the Docker network (or `host.docker.internal` on Docker Desktop).
2. Change `upstream origin_backend` in `nginx/nginx.conf`.
3. `make reload` (or `make up` if you changed compose).

## Common expert extensions

| Idea | Where to change | Notes |
|------|-----------------|-------|
| Longer TTL | Origin `Cache-Control` or `proxy_cache_valid` | Prefer origin headers |
| Cache purge | New Nginx location + `proxy_cache_purge` (requires module) | Or wipe volume: `make clean` |
| Basic auth at edge | `auth_basic` in `location /` | Lab-only credentials |
| Multiple paths | Extra `location` blocks | e.g. `/api/` no-cache, `/assets/` long TTL |
| Structured logs | `log_format` / ship to file | Already includes `cache=` |

## Adding a test

Extend `test-suite.sh` with a new function and call it from `main`.
Keep assertions header-based so CI stays deterministic.

## Contribution expectations

Document *why* in comments. Prefer small PRs. Run `make test` before opening a PR.

Next: [Production Notes](production-notes.md) · [Contributing](../CONTRIBUTING.md)
