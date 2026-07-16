# Troubleshooting

## Edge never becomes ready / connection refused on :443

1. Check containers: `docker compose ps`
2. Check logs: `docker compose logs edge-proxy`
3. Classic OpenSSL 3 failure:

```text
SSL_CTX_set_cipher_list("TLS_AES_...") failed (no cipher match)
```

**Fix:** TLS 1.3 suites belong in `ssl_conf_command Ciphersuites`, not `ssl_ciphers`.

4. Orphan container holding ports:

```bash
docker compose down --remove-orphans
make up
```

## Port 80 or 443 already allocated

Something else on the host is bound (other reverse proxy, old container).

```bash
docker ps --format '{{.Names}}\t{{.Ports}}' | grep -E ':80|:443'
make down
# stop the conflicting process/container, then:
make up
```

## `make test` fails cache HIT

- Wait a second and retry; ensure you use the **same URL** twice.
- Confirm cache key does not include a changing timestamp query.
- Reload after config edits: `make reload`

## Rate limit trips during normal browsing

Expected under bursty curls from one IP. Wait a few seconds, or raise
`rate=` / `burst=` in `nginx/nginx.conf` for local use.

## Certificate errors in browsers

Lab certs are self-signed. For curl demos use `-k`. For browsers, import
`nginx/certs/edge.crt` as a trusted cert or use curl/`--resolve` for verification.

## Origin healthy but edge returns 502

```bash
docker compose exec edge-proxy wget -qO- http://origin-server:5000/health
```

If that fails, the containers are not on the same network — recreate with `make up`.

Still stuck? Open a [bug report](../.github/ISSUE_TEMPLATE/bug_report.md) with `make test` output and `docker compose logs`.
