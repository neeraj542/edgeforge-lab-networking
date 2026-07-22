# Example: custom origin

Run **your** app behind ns-cdn-lab instead of the bundled Flask demo.

## Option A — App in Docker on `cdn-network`

1. Add your service to `docker-compose.yml` (or a `docker-compose.override.yml`):

```yaml
services:
  my-app:
    image: your-image:tag
    # or build: ./path
    networks:
      - cdn-network
    # Do NOT publish ports to the host if you want origin cloaking.
```

2. Point Nginx upstream at it (`nginx/nginx.conf`):

```nginx
upstream origin_backend {
    server my-app:8080;   # change port to match your app
    keepalive 32;
}
```

3. Reload:

```bash
make reload
# or: make up
```

## Option B — App on the host (Docker Desktop)

On Docker Desktop, the host is often reachable as `host.docker.internal`:

```nginx
upstream origin_backend {
    server host.docker.internal:3000;
    keepalive 32;
}
```

Ensure your app listens on `0.0.0.0`, not only `127.0.0.1`.

## Checklist for your origin

- [ ] Sends sensible `Cache-Control` on cacheable GETs
- [ ] Does not require HTTPS from the edge (edge→origin is HTTP on the lab network)
- [ ] Health endpoint available for debugging
- [ ] You verified `X-Cache-Status` HIT/MISS through the edge

## Verify

```bash
curl -Ik --resolve ns-cdn-lab.local:443:127.0.0.1 https://ns-cdn-lab.local/
make test   # some origin-header assertions are Flask-specific; adjust as needed
```

Back to [Examples](../../docs/examples.md) · [Guide](../../docs/guide.md).
