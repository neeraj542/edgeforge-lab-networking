# TLS certificates (local only)

Generated files live here after `make certs` or `./nginx/generate-certs.sh`:

| File | Purpose |
|------|---------|
| `edge.crt` | Public certificate for `edgeforge.local` |
| `edge.key` | Private key (**gitignored — never commit**) |
| `openssl.cnf` | OpenSSL config used for generation |

These are **self-signed lab certificates**. Do not use them on the public Internet.
