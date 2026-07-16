# Static-site example

This recipe replaces the default Flask origin with a small static-site origin.
It demonstrates a common personal-project pattern:

- HTML pages: short TTL (`Cache-Control: public, max-age=30`)
- CSS / static JSON: longer TTL (`public, max-age=600` or more)
- Origin stays cloaked; only `edge-proxy` publishes ports

## Run

From the repository root:

```bash
make certs
docker compose -f docker-compose.yml -f examples/static-site/docker-compose.override.yml up --build -d --force-recreate --remove-orphans
```

## Verify

```bash
# HTML should MISS first, then HIT
curl -sk -D - -o /dev/null --resolve ns-cdn-lab.local:443:127.0.0.1 https://ns-cdn-lab.local/ | grep -iE 'cache-control|x-cache-status|x-origin-server'
curl -sk -D - -o /dev/null --resolve ns-cdn-lab.local:443:127.0.0.1 https://ns-cdn-lab.local/ | grep -iE 'cache-control|x-cache-status|x-origin-server'

# Asset has a longer TTL
curl -sk -D - -o /dev/null --resolve ns-cdn-lab.local:443:127.0.0.1 https://ns-cdn-lab.local/assets/site.css | grep -iE 'cache-control|x-cache-status|x-origin-server'
```

## Stop

```bash
docker compose -f docker-compose.yml -f examples/static-site/docker-compose.override.yml down --remove-orphans
```

Back to [use cases](../../docs/use-cases.md).
