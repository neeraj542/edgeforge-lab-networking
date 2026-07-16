# API example

This recipe replaces the default origin with a cache-aware API origin.
It demonstrates a production-relevant rule:

- `GET /api/time` is cacheable for 15 seconds
- `POST /api/echo` is `no-store` and the edge bypasses cache for POST

## Run

From the repository root:

```bash
make certs
docker compose -f docker-compose.yml -f examples/api/docker-compose.override.yml up --build -d --force-recreate --remove-orphans
```

## Verify GET cache

```bash
curl -sk -D - --resolve ns-cdn-lab.local:443:127.0.0.1 https://ns-cdn-lab.local/api/time
curl -sk -D - --resolve ns-cdn-lab.local:443:127.0.0.1 https://ns-cdn-lab.local/api/time
```

On the second request, look for:

```text
x-cache-status: HIT
cache-control: public, max-age=15
```

## Verify POST bypass

```bash
curl -sk -D - -X POST \
  -H 'Content-Type: text/plain' \
  --data 'hello from my app' \
  --resolve ns-cdn-lab.local:443:127.0.0.1 \
  https://ns-cdn-lab.local/api/echo
```

Look for:

```text
cache-control: no-store
x-cache-status: BYPASS
```

## Stop

```bash
docker compose -f docker-compose.yml -f examples/api/docker-compose.override.yml down --remove-orphans
```

Back to [use cases](../../docs/use-cases.md).
