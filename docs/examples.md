# Examples

These examples keep the same ns-cdn-lab edge (`edge-proxy`) and replace only the
origin. That means the request path stays realistic:

```text
Client -> ns-cdn-lab edge -> origin-server replacement
```

## Available examples

| Example | Use it when you want to… | Run |
|---------|---------------------------|-----|
| [Static site](../examples/static-site/) | Cache HTML and assets with different TTLs | `make example-static` |
| [API](../examples/api/) | Cache GET, bypass POST | `make example-api` |
| [BYO-origin](../examples/byo-origin/) | Put your existing localhost app behind ns-cdn-lab | `make example-byo` |
| [Custom origin](../examples/custom-origin/) | Manually wire your own Dockerized app | Read the guide |

## Stop any example

```bash
make down
```

## Return to the default demo origin

```bash
make up
make test
```

## Notes

- Examples use Compose override files instead of editing `nginx/nginx.conf`.
- `edge-proxy` still binds only to `127.0.0.1:80` and `127.0.0.1:443`.
- The default `test-suite.sh` validates the default Flask origin. Example-specific
  verification commands live in each example README.
