# Contributing to ns-cdn-lab

Thanks for helping improve ns-cdn-lab. This project is a local CDN / edge lab —
contributions that keep the **5-minute quick start** simple are especially welcome.

## Code of Conduct

Please read and follow [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Ways to contribute

- Bug reports and reproducible test failures
- Documentation improvements (beginner clarity is gold)
- Examples that help personal projects (custom origin, static site, API)
- Hardening of the Nginx edge config (with comments explaining *why*)
- CI / packaging improvements

## Development setup

Prerequisites: Docker Desktop (or Docker Engine + Compose v2), `curl`, `openssl`.

```bash
git clone https://github.com/neeraj542/edgeforge-lab-networking.git
cd edgeforge-lab-networking
make certs
make up
make test
```

Useful targets:

| Command | What it does |
|---------|----------------|
| `make up` | Build and start the stack |
| `make test` | Run `./test-suite.sh` |
| `make down` | Stop containers |
| `make logs` | Tail edge + origin logs |
| `make reload` | Reload Nginx config without full rebuild |

## Pull request checklist

- [ ] `make test` passes locally
- [ ] Docs updated if behavior or commands changed
- [ ] Comments explain *why* for non-obvious Nginx / security settings
- [ ] No secrets committed (`nginx/certs/edge.key` is gitignored)

## Commit style

Prefer short, imperative messages:

- `fix: use TLS 1.3 Ciphersuites via ssl_conf_command`
- `docs: add troubleshooting for port 80 conflicts`
- `feat: add custom-origin example`

## License

By contributing, you agree that your contributions are licensed under the
[Apache License 2.0](LICENSE).
