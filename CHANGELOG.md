# Changelog

All notable changes to EdgeForge are documented here.

Format inspired by [Keep a Changelog](https://keepachangelog.com/).
This project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- Open-source Phase 1 packaging: Apache-2.0 license, NOTICE, security policy,
  contributing guide, code of conduct
- Makefile shortcuts (`up`, `down`, `test`, `certs`, `logs`, `reload`)
- Documentation skeleton under `docs/`
- GitHub Actions CI to run the verification suite
- Custom-origin example under `examples/custom-origin/`

## [0.1.0] - 2026-07-16

### Added

- Nginx edge proxy with TLS 1.3, HTTP→HTTPS redirect, session resumption
- CDN-style `proxy_cache` with `X-Cache-Status` (HIT / MISS / BYPASS)
- Edge security: method filter, malicious UA block, rate limiting, security headers
- Flask origin with `Cache-Control` and `X-Origin-Server`
- Origin cloaking via Docker Compose (origin not published to host)
- Certificate generator and end-to-end `test-suite.sh`
