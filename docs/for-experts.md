# For CDN / edge / platform engineers

ns-cdn-lab is a **local, inspectable stand-in** for patterns you already know from
Cloudflare, CloudFront, Fastly, Akamai, and Nginx edge stacks — without a
vendor account or public DNS.

Use it when you need a reproducible lab for:

- Cache triage (`HIT` / `MISS` / `BYPASS`) and `Cache-Control` debugging
- TLS 1.3 termination and HTTP→HTTPS redirect behavior
- Origin cloaking / origin shield style isolation
- Edge rate limits, method allowlists, and scanner User-Agent blocks
- Teaching or interviewing on reverse proxies and delivery paths

## Concept map (lab ↔ production)

| You know this… | In ns-cdn-lab… |
|----------------|----------------|
| CDN / edge PoP | `edge-proxy` (Nginx) |
| Origin / customer origin | `origin-server` (Flask, or your app) |
| `proxy_cache` / edge object cache | Nginx `proxy_cache` + `X-Cache-Status` |
| Cache key | `$scheme$host$request_uri` |
| Origin TTL signal | Origin `Cache-Control` |
| TLS termination | Edge-only TLS 1.3 |
| Origin not on the public Internet | No host ports on origin (Docker network only) |
| WAF / bot / abuse controls | Method filter, UA maps, `limit_req` |
| Staging before CloudFront/Cloudflare rules | Compose overrides under `examples/` |

## Search / research keywords

CDN lab · Nginx reverse proxy · `proxy_cache` · HTTP caching · `Cache-Control` ·
`X-Cache-Status` · TLS 1.3 · origin cloaking · edge security · rate limiting ·
Docker Compose networking · local CDN simulator · delivery troubleshooting

## Start here

1. [Architecture](architecture.md) — request path and ports  
2. [Caching](caching.md) — TTL, keys, stale serving  
3. [Security](security.md) — edge controls  
4. [Examples](examples.md) — static, API, BYO-origin  
5. [Production notes](production-notes.md) — what this is *not*

Root overview: [README](../README.md)
