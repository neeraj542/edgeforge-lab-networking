#!/usr/bin/env python3
"""Cache-aware API origin used by the ns-cdn-lab API example."""

from __future__ import annotations

import json
import os
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse

ORIGIN_NAME = "API-Origin-01"


class ApiOriginHandler(BaseHTTPRequestHandler):
    server_version = "NsCdnLabApiOrigin/1.0"

    def do_HEAD(self) -> None:
        self._handle(send_body=False)

    def do_GET(self) -> None:
        self._handle(send_body=True)

    def do_POST(self) -> None:
        parsed = urlparse(self.path)
        if parsed.path != "/api/echo":
            self._json(404, {"error": "not_found"}, "no-store")
            return

        length = int(self.headers.get("Content-Length", "0"))
        body = self.rfile.read(length).decode("utf-8") if length else ""
        self._json(
            200,
            {
                "method": "POST",
                "received": body,
                "origin": ORIGIN_NAME,
                "generated_at": int(time.time()),
                "cache_policy": "no-store; edge must not cache writes",
            },
            "no-store",
        )

    def log_message(self, fmt: str, *args: object) -> None:
        print(f"{self.client_address[0]} - {fmt % args}")

    def _handle(self, *, send_body: bool) -> None:
        parsed = urlparse(self.path)

        if parsed.path == "/health":
            payload = {"status": "healthy", "service": ORIGIN_NAME}
            self._json(200, payload, "no-store", send_body=send_body)
            return

        if parsed.path == "/api/time":
            payload = {
                "method": "GET",
                "origin": ORIGIN_NAME,
                "generated_at": int(time.time()),
                "cache_policy": "public, max-age=15",
                "note": "Repeat this URL quickly and X-Cache-Status should become HIT.",
            }
            self._json(200, payload, "public, max-age=15", send_body=send_body)
            return

        self._json(404, {"error": "not_found"}, "public, max-age=30", send_body=send_body)

    def _json(self, status: int, payload: dict[str, object], cache_control: str, *, send_body: bool = True) -> None:
        body = json.dumps(payload, indent=2).encode("utf-8") + b"\n"
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", cache_control)
        self.send_header("X-Origin-Server", ORIGIN_NAME)
        self.end_headers()
        if send_body:
            self.wfile.write(body)


def main() -> None:
    port = int(os.environ.get("PORT", "5000"))
    server = ThreadingHTTPServer(("0.0.0.0", port), ApiOriginHandler)
    print(f"{ORIGIN_NAME} listening on :{port}")
    server.serve_forever()


if __name__ == "__main__":
    main()
