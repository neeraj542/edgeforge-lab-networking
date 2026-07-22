# Bring your own origin (BYO-origin)

Use this recipe when your personal project already runs on your machine, for
example:

- React / Next dev server on `localhost:3000`
- Node API on `localhost:8080`
- Flask / FastAPI app on `localhost:5001`

The override swaps the demo origin for a small forwarder container. ns-cdn-lab
still talks to `origin-server:5000`; the forwarder sends traffic to your host app.

## Run your app

Example:

```bash
npm run dev   # app listens on localhost:3000
```

## Start ns-cdn-lab against that app

```bash
make certs
NS_CDN_LAB_UPSTREAM_PORT=3000 \
  docker compose -f docker-compose.yml -f examples/byo-origin/docker-compose.override.yml up --build -d --force-recreate --remove-orphans
```

For another port:

```bash
NS_CDN_LAB_UPSTREAM_PORT=8080 \
  docker compose -f docker-compose.yml -f examples/byo-origin/docker-compose.override.yml up --build -d --force-recreate --remove-orphans
```

## Verify

```bash
curl -Ik --resolve ns-cdn-lab.local:443:127.0.0.1 https://ns-cdn-lab.local/
```

If your app sends `Cache-Control`, ns-cdn-lab honors it. If your app sends no
cache policy, the forwarder defaults to `Cache-Control: no-store` so personal
projects are not cached accidentally.

## Stop

```bash
docker compose -f docker-compose.yml -f examples/byo-origin/docker-compose.override.yml down --remove-orphans
```

Back to [Examples](../../docs/examples.md) · [Guide](../../docs/guide.md).
