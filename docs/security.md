# Security

ns-cdn-lab includes a **lab-scale** edge security layer — enough to teach
patterns, not enough to replace a commercial WAF.

## Controls

| Control | Behavior | Typical response |
|---------|----------|------------------|
| HTTPS redirect | HTTP → HTTPS | `301` |
| TLS policy | TLS 1.3 only | Handshake failure on legacy TLS |
| Method allowlist | GET, HEAD, POST only | `405` |
| Bad User-Agents | nikto, sqlmap, nmap, … | `403` |
| Rate limit | ~10 r/s + burst 20 per IP | `429` |
| Security headers | HSTS, CSP, XFO, nosniff | Present on proxied responses |

## Try it

```bash
# Method block
curl -sk -o /dev/null -w "%{http_code}\n" -X DELETE \
  --resolve ns-cdn-lab.local:443:127.0.0.1 https://ns-cdn-lab.local/

# Bot UA block
curl -sk -o /dev/null -w "%{http_code}\n" \
  -H "User-Agent: Nikto/2.1.6" \
  --resolve ns-cdn-lab.local:443:127.0.0.1 https://ns-cdn-lab.local/
```

## Design notes for contributors

- Rate limiting applies to `location /`, **not** `/edge-health`, so health probes
  and `make test` readiness checks are not false-failed with 429.
- TLS 1.3 cipher suites must use `ssl_conf_command Ciphersuites` on OpenSSL 3 —
  do **not** put `TLS_AES_*` in `ssl_ciphers` (that crashes Nginx).

Next: [Troubleshooting](troubleshooting.md) · [Production Notes](production-notes.md)
