# Caching

EdgeForge uses Nginx `proxy_cache` to simulate a CDN edge cache.

## Key settings (`nginx/nginx.conf`)

| Directive | Lab default | Why |
|-----------|-------------|-----|
| `proxy_cache_path` | 100m zone `cdn_cache` | Disk-backed edge cache |
| `proxy_cache_key` | `$scheme$host$request_uri` | GET and HEAD share one object |
| `proxy_cache_valid` | 60s for 200/301/302 | Fallback TTL if needed |
| Origin `Cache-Control` | `public, max-age=60` | Primary freshness signal |
| POST | bypass / no-cache | Never cache writes |

## Observability

Primary header: **`X-Cache-Status`**

```bash
# First request — expect MISS
curl -sk -D - -o /dev/null --resolve edgeforge.local:443:127.0.0.1 \
  "https://edgeforge.local/?demo=$(date +%s)" | grep -i x-cache

# Immediate repeat of a fixed URL — expect HIT
curl -sk -D - -o /dev/null --resolve edgeforge.local:443:127.0.0.1 \
  "https://edgeforge.local/?demo=fixed" | grep -i x-cache
curl -sk -D - -o /dev/null --resolve edgeforge.local:443:127.0.0.1 \
  "https://edgeforge.local/?demo=fixed" | grep -i x-cache
```

## Stale serving

If origin errors, the edge can serve stale content (`proxy_cache_use_stale`).
That trades freshness for availability — a common CDN support trade-off.

## Personal-project tip

Before you pay for a CDN, use EdgeForge to validate:

- Which URLs should be cacheable
- What `Cache-Control` your app actually sends
- Whether POST/API routes are incorrectly cached

Next: [Use Cases](use-cases.md) · [Extending](extending.md)
