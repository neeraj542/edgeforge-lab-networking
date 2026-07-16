# Use Cases — how personal projects benefit

ns-cdn-lab is useful when you want CDN-like behavior **locally** before (or instead of)
wiring a commercial edge.

## 1. Learn delivery debugging

Practice the same header-driven triage used in cloud support:

- `X-Cache-Status` → did the edge serve cache or origin?
- `X-Origin-Server` → which backend answered?
- `Cache-Control` → what TTL did the app request?

## 2. Validate HTTPS locally

Spin up TLS 1.3 + HSTS without buying a domain or waiting on DNS.
Useful for demos, workshops, and portfolio projects.

## 3. Protect a side project behind an edge

Put your Flask/FastAPI/Node app **behind** Nginx:

- Origin not published to the host
- Rate limiting and method filtering at the edge
- Cached GETs for marketing pages / static JSON

Start with [Examples](examples.md): static-site, API, BYO-origin, and custom-origin recipes.

## 4. Test cache headers before production CDN

Many “CDN isn’t caching” tickets are actually origin misconfiguration.
Reproduce with ns-cdn-lab, fix `Cache-Control`, then apply the same policy on
Cloudflare / CloudFront / Fastly.

## 5. Abuse / scanner demos (safely)

Demonstrate `403` / `405` / `429` responses in a controlled lab — great for
security awareness sessions and interview demos.

## 6. Interview / learning portfolio

Ship a public repo that proves you understand:

- TLS termination
- Reverse proxies
- Caching semantics
- Edge vs origin isolation
- Basic WAF-style controls

Next: [Examples](examples.md) · [Extending](extending.md)
