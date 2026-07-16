#!/usr/bin/env python3
"""
origin/app.py — Customer Origin Server (EdgeForge lab)
======================================================
In a CDN model, the "origin" is the customer's backend. The edge fetches content
from origin on a cache MISS, then serves later requests from edge cache until TTL
expires.

This Flask app:
  1. Serves HTML and static assets
  2. Emits Cache-Control headers the edge must honor
  3. Adds X-Origin-Server for request tracing while troubleshooting
"""

import os

from flask import Flask, render_template, send_from_directory

app = Flask(
    __name__,
    template_folder="templates",
    static_folder="static",
)


@app.after_request
def inject_origin_headers(response):
    """
    Attach origin-level headers to every response.

    Cache-Control: public, max-age=60
        - public   → edge MAY cache this response for any client
        - max-age  → content is fresh for 60 seconds

    X-Origin-Server: Flask-Backend-01
        - Identifies which origin instance served the content.
        - Compare with X-Cache-Status to see if a request hit cache or origin.
    """
    response.headers["Cache-Control"] = "public, max-age=60"
    response.headers["X-Origin-Server"] = "Flask-Backend-01"
    return response


@app.route("/")
def index():
    """Serve the main HTML page — primary cacheable object for CDN demos."""
    return render_template("index.html")


@app.route("/static/<path:filename>")
def static_asset(filename):
    """Serve static assets from static/. Edge caches these by URL + Cache-Control."""
    return send_from_directory(app.static_folder, filename)


@app.route("/health")
def health():
    """Container health endpoint — not meant for public CDN caching demos."""
    return {"status": "healthy", "service": "origin-server"}, 200


if __name__ == "__main__":
    # Bind 0.0.0.0 so Docker peers (edge-proxy) can reach us.
    # Port 5000 is internal-only — not published to the host.
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=False)
