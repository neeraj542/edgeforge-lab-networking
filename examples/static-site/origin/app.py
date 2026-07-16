#!/usr/bin/env python3
"""Static-site origin used by the ns-cdn-lab static caching example."""

from __future__ import annotations

import json
import mimetypes
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import unquote, urlparse

PUBLIC_DIR = Path(__file__).parent / "public"
ORIGIN_NAME = "Static-Origin-01"

CACHE_POLICIES = {
    ".html": "public, max-age=30",
    ".css": "public, max-age=600",
    ".js": "public, max-age=600",
    ".json": "public, max-age=120",
    ".svg": "public, max-age=3600",
    ".png": "public, max-age=3600",
    ".jpg": "public, max-age=3600",
    ".jpeg": "public, max-age=3600",
}


class StaticOriginHandler(BaseHTTPRequestHandler):
    server_version = "NsCdnLabStaticOrigin/1.0"

    def do_HEAD(self) -> None:
        self._serve(send_body=False)

    def do_GET(self) -> None:
        self._serve(send_body=True)

    def log_message(self, fmt: str, *args: object) -> None:
        print(f"{self.client_address[0]} - {fmt % args}")

    def _serve(self, *, send_body: bool) -> None:
        parsed = urlparse(self.path)

        if parsed.path == "/health":
            body = json.dumps({"status": "healthy", "service": ORIGIN_NAME}).encode()
            self._send_headers(200, "application/json", len(body), "no-store")
            if send_body:
                self.wfile.write(body)
            return

        relative_path = "index.html" if parsed.path in ("/", "") else unquote(parsed.path).lstrip("/")
        candidate = (PUBLIC_DIR / relative_path).resolve()

        if not str(candidate).startswith(str(PUBLIC_DIR.resolve())) or not candidate.is_file():
            body = b"not found\n"
            self._send_headers(404, "text/plain", len(body), "public, max-age=30")
            if send_body:
                self.wfile.write(body)
            return

        body = candidate.read_bytes()
        content_type = mimetypes.guess_type(candidate.name)[0] or "application/octet-stream"
        cache_control = CACHE_POLICIES.get(candidate.suffix.lower(), "public, max-age=60")
        self._send_headers(200, content_type, len(body), cache_control)
        if send_body:
            self.wfile.write(body)

    def _send_headers(self, status: int, content_type: str, content_length: int, cache_control: str) -> None:
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(content_length))
        self.send_header("Cache-Control", cache_control)
        self.send_header("X-Origin-Server", ORIGIN_NAME)
        self.end_headers()


def main() -> None:
    port = int(os.environ.get("PORT", "5000"))
    server = ThreadingHTTPServer(("0.0.0.0", port), StaticOriginHandler)
    print(f"{ORIGIN_NAME} listening on :{port}")
    server.serve_forever()


if __name__ == "__main__":
    main()
