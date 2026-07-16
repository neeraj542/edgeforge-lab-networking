# Security Policy

## Supported versions

| Version | Supported |
|---------|-----------|
| `main` / latest release | Yes |
| Older tags | Best-effort only |

## What ns-cdn-lab is (and is not)

ns-cdn-lab is a **local learning / lab stack**. It uses self-signed certificates,
simple WAF-style rules, and Docker networking for demos. It is **not** a
production CDN, WAF, or DDoS product.

## Reporting a vulnerability

Please **do not** open a public GitHub issue for security problems.

1. Prefer a private GitHub Security Advisory once the repo is public.
2. Or email the maintainer listed in the repository profile / release notes.

Include:

- Affected component (`edge-proxy`, `origin-server`, scripts, docs)
- Steps to reproduce
- Impact (info leak, bypass, DoS against the lab, etc.)
- Your suggested fix if you have one

We aim to acknowledge reports within **7 days**.

## Safe disclosure expectations

- Give us a reasonable window before public disclosure.
- Do not use ns-cdn-lab findings to attack third-party systems.
- Lab-only findings (e.g. “self-signed cert is insecure by design”) are out of scope.
