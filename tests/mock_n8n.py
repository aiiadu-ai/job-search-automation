#!/usr/bin/env python3
"""Мок n8n для тестів: віддає чергу з fixtures/queue.json, приймає jobs-done (лише рахує)."""
import json, sys
from http.server import BaseHTTPRequestHandler, HTTPServer
KEY, QUEUE = sys.argv[2], open(sys.argv[3], encoding="utf-8").read()
class H(BaseHTTPRequestHandler):
    def _ok(self, body):
        self.send_response(200); self.send_header("Content-Type", "application/json"); self.end_headers()
        self.wfile.write(body.encode())
    def do_GET(self):
        if self.headers.get("x-jobs-key") != KEY: return self._ok("")
        self._ok(QUEUE)
    def do_POST(self):
        n = int(self.headers.get("Content-Length", 0)); b = json.loads(self.rfile.read(n))
        print("jobs-done:", b.get("id"), b.get("subject"), file=sys.stderr, flush=True)
        self._ok(json.dumps({"ok": True, "id": b.get("id")}))
    def log_message(self, *a): pass
HTTPServer(("127.0.0.1", int(sys.argv[1])), H).serve_forever()
