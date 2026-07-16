#!/usr/bin/env python3
"""Tiny HTTP forwarder that lets ns-cdn-lab proxy to an app on the host."""

from __future__ import annotations

import http.client
import json
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlsplit

UPSTREAM_HOST = os.environ.get("UPSTREAM_HOST", "host.docker.internal")
UPSTREAM_PORT = int(os.environ.get("UPSTREAM_PORT", "3000"))
ORIGIN_NAME = "BYO-Origin-Forwarder"

HOP_BY_HOP_HEADERS = {
    "connection",
    "keep-alive",
    "proxy-authenticate",
    "proxy-authorization",
    "te",
    "trailers",
    "transfer-encoding",
    "upgrade",
}


class Forwarder(BaseHTTPRequestHandler):
    server_version = "NsCdnLabByoForwarder/1.0"

    def do_HEAD(self) -> None:
        self._forward(send_body=False)

    def do_GET(self) -> None:
        self._forward(send_body=True)

    def do_POST(self) -> None:
        self._forward(send_body=True)

    def log_message(self, fmt: str, *args: object) -> None:
        print(f"{self.client_address[0]} - {fmt % args}")

    def _forward(self, *, send_body: bool) -> None:
        parsed = urlsplit(self.path)

        if parsed.path == "/health":
            body = json.dumps(
                {
                    "status": "healthy",
                    "service": ORIGIN_NAME,
                    "upstream": f"{UPSTREAM_HOST}:{UPSTREAM_PORT}",
                }
            ).encode("utf-8") + b"\n"
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body)))
            self.send_header("Cache-Control", "no-store")
            self.send_header("X-Origin-Server", ORIGIN_NAME)
            self.end_headers()
            if send_body:
                self.wfile.write(body)
            return

        body_length = int(self.headers.get("Content-Length", "0"))
        request_body = self.rfile.read(body_length) if body_length else None
        target = parsed.path or "/"
        if parsed.query:
            target = f"{target}?{parsed.query}"

        headers = {
            key: value
            for key, value in self.headers.items()
            if key.lower() not in HOP_BY_HOP_HEADERS and key.lower() != "host"
        }
        headers["Host"] = f"{UPSTREAM_HOST}:{UPSTREAM_PORT}"
        headers["X-Forwarded-Host"] = self.headers.get("Host", "ns-cdn-lab.local")

        try:
            connection = http.client.HTTPConnection(UPSTREAM_HOST, UPSTREAM_PORT, timeout=15)
            connection.request(self.command, target, body=request_body, headers=headers)
            response = connection.getresponse()
            response_body = response.read()
        except OSError as exc:
            payload = json.dumps(
                {
                    "error": "upstream_unreachable",
                    "upstream": f"{UPSTREAM_HOST}:{UPSTREAM_PORT}",
                    "detail": str(exc),
                },
                indent=2,
            ).encode("utf-8") + b"\n"
            self.send_response(502)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(payload)))
            self.send_header("Cache-Control", "no-store")
            self.send_header("X-Origin-Server", ORIGIN_NAME)
            self.end_headers()
            if send_body:
                self.wfile.write(payload)
            return

        self.send_response(response.status, response.reason)
        sent_cache_control = False
        for key, value in response.getheaders():
            lower = key.lower()
            if lower in HOP_BY_HOP_HEADERS or lower == "content-length":
                continue
            if lower == "cache-control":
                sent_cache_control = True
            self.send_header(key, value)

        # If the user's app has no explicit cache policy, default to no-store.
        # Users can opt in to edge caching by sending Cache-Control themselves.
        if not sent_cache_control:
            self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Length", str(len(response_body)))
        self.send_header("X-Origin-Server", ORIGIN_NAME)
        self.end_headers()
        if send_body:
            self.wfile.write(response_body)


def main() -> None:
    port = int(os.environ.get("PORT", "5000"))
    server = ThreadingHTTPServer(("0.0.0.0", port), Forwarder)
    print(f"{ORIGIN_NAME} listening on :{port}; upstream={UPSTREAM_HOST}:{UPSTREAM_PORT}")
    server.serve_forever()


if __name__ == "__main__":
    main()
