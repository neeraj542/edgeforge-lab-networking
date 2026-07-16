# Concepts

## Edge vs origin

| Term | In ns-cdn-lab | Meaning |
|------|--------------|---------|
| **Edge** | `edge-proxy` (Nginx) | First hop for the client. Terminates TLS, caches, applies security. |
| **Origin** | `origin-server` (Flask) | Your app / content source. Hidden from the public host network. |

```text
Client ──HTTPS──► Edge ──HTTP──► Origin
```

## Cache status

| `X-Cache-Status` | Meaning |
|------------------|---------|
| `MISS` | Edge did not have a fresh copy; fetched from origin |
| `HIT` | Served from edge cache (fast path) |
| `BYPASS` | Cache intentionally skipped (e.g. some error paths) |

## Origin cloaking

The Flask container publishes **no host ports**. Only Nginx binds `80`/`443`.
That mirrors how real CDNs hide origin IPs behind the edge.

## Why self-signed TLS?

Lab convenience. Production edges use public CA certificates. For local demos,
`curl -k` or `--resolve` + trusting the lab cert is enough.

## Security layers (lab-scale)

1. HTTPS only (HTTP → 301)
2. Allowlisted methods (GET / HEAD / POST)
3. Block known scanner User-Agents
4. Per-IP rate limiting → HTTP 429
5. Browser hardening headers (HSTS, CSP, etc.)

Next: [Architecture](architecture.md) · [Caching](caching.md)
