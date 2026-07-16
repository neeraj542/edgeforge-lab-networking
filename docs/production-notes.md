# Production Notes

## What ns-cdn-lab is

A **local, educational Docker lab** that demonstrates CDN-style edge behavior:

- TLS termination
- Response caching
- Origin isolation
- Basic request filtering and rate limiting

## What ns-cdn-lab is not

| Not this | Use this instead (examples) |
|----------|-----------------------------|
| Global multi-PoP CDN | Cloudflare, Fastly, CloudFront, etc. |
| Enterprise WAF / bot management | Dedicated WAF products |
| Managed certificate lifecycle | ACME / public CA automation |
| Production DDoS scrubbing | Provider-level network defenses |
| Multi-tenant edge control plane | Real CDN configuration systems |

## Safe usage guidelines

- Do not expose the default lab stack to the public Internet as-is.
- Rotate / replace self-signed certs; never commit `edge.key`.
- Treat rate limits and UA blocks as **examples**, not a security program.
- When promoting to production patterns, re-validate every control with your threat model.

## Honest positioning for README / talks

> ns-cdn-lab helps you **learn and validate** edge delivery locally. It is a
> springboard to production CDNs — not a replacement for them.

Next: [Use Cases](use-cases.md) · [Getting Started](getting-started.md)
