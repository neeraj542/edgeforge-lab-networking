# Extending ns-cdn-lab

## Point the edge at your own app

For no-code-change recipes, start with [Examples](examples.md). For manual wiring, see [examples/custom-origin](../examples/custom-origin/).

High-level steps:

1. Use [examples/byo-origin](../examples/byo-origin/) if your app already runs on your host.
2. Use [examples/custom-origin](../examples/custom-origin/) if your app is Dockerized.
3. Change `nginx/nginx.conf` only when you need custom routing or multiple upstreams.

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
