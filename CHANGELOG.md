# Changelog

All notable changes to ns-cdn-lab are documented here.

Format inspired by [Keep a Changelog](https://keepachangelog.com/).
This project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.2.0] - 2026-07-22

### Changed

- Rebranded product name from EdgeForge to **ns-cdn-lab**
- Local demo domain is now `ns-cdn-lab.local`
- Safer cert generation: reuse existing lab certs unless `FORCE=1`
- Compose bring-up uses `--force-recreate` for more reliable host TLS after switches

### Added

- Phase 2 examples: static-site origin, cache-aware API origin, and BYO-origin forwarder
- Makefile shortcuts for `example-static`, `example-api`, and `example-byo`
- Docs for examples plus troubleshooting notes for cert reuse / TLS flakes

## [0.1.0] - 2026-07-16

### Added

- Nginx edge proxy with TLS 1.3, HTTP→HTTPS redirect, session resumption
- CDN-style `proxy_cache` with `X-Cache-Status` (HIT / MISS / BYPASS)
- Edge security: method filter, malicious UA block, rate limiting, security headers
- Flask origin with `Cache-Control` and `X-Origin-Server`
- Origin cloaking via Docker Compose (origin not published to host)
- Certificate generator and end-to-end `test-suite.sh`
