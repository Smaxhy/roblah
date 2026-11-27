#!/usr/bin/env python3
"""
THE LOCAL STUDIO BRIDGE (BitLeveling): run Luau in Roblox Studio from a terminal, a script or an
AI agent on the same computer. Standard library only.

    python3 tools/studio_bridge/bridge.py serve [--port 28754]      # leave this running
    (in Studio: BitLeveling panel > BRIDGE > Connect)
    python3 tools/studio_bridge/bridge.py run "print(#workspace:GetChildren())"
    python3 tools/studio_bridge/bridge.py run --file tools/studio_bridge/smoke.luau
    python3 tools/studio_bridge/bridge.py status

How it works: `serve` keeps a queue on 127.0.0.1. The plugin (src/plugin/Lib/Bridge.luau) asks
for work every moment; `run` puts a chunk in the queue and waits for the plugin to send back what
it printed and returned. Exit code 1 if the chunk errored.

Safety: it listens on 127.0.0.1 only; it refuses any request that comes from a web page (an
Origin header) or that lacks the bridge's own headers (which a page can't add without a CORS
preflight this server never grants); and the plugin only polls while you have it connected.
"""

import argparse, json, os, sys, threading, time, uuid
from collections import deque
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import urllib.request, urllib.error

PORT = 28754


class State:
    def __init__(self):
        self.jobs = deque()
        self.results = {}
        self.cond = threading.Condition()
        self.plugin_seen = 0.0


STATE = State()


class Handler(BaseHTTPRequestHandler):
    server_version = "BitLevelingBridge/1"

    def log_message(self, fmt, *args):  # quiet
        pass

    def _json(self, code, obj=None):
        body = json.dumps(obj).encode() if obj is not None else b""
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        if body:
            self.wfile.write(body)

    def _allowed(self, header):
        if self.headers.get("Origin"):
            return False  # a browser
        return self.headers.get(header) == "1"

    def _body(self):
        n = int(self.headers.get("Content-Length") or 0)
        raw = self.rfile.read(n) if n else b"{}"
        try:
            return json.loads(raw.decode() or "{}")
        except ValueError:
            return {}

    def do_OPTIONS(self):
        self._json(403, {"error": "no"})

    def do_GET(self):
        if self.path == "/poll" and self._allowed("X-Bridge-Plugin"):
            STATE.plugin_seen = time.time()
            with STATE.cond:
                deadline = time.time() + 20
                while not STATE.jobs and time.time() < deadline:
                    STATE.cond.wait(timeout=0.5)
                    STATE.plugin_seen = time.time()
                job = STATE.jobs.popleft() if STATE.jobs else None
            if job:
                self._json(200, job)
            else:
                self._json(204)
        elif self.path == "/status" and self._allowed("X-Bridge-Client"):
            ago = time.time() - STATE.plugin_seen if STATE.plugin_seen else None
            self._json(200, {"pluginConnected": ago is not None and ago < 25, "pluginSeenSecondsAgo": ago, "queued": len(STATE.jobs)})
        else:
            self._json(403, {"error": "not allowed"})

    def do_POST(self):
        if self.path == "/result" and self._allowed("X-Bridge-Plugin"):
            res = self._body()
            with STATE.cond:
                STATE.results[res.get("id")] = res
                STATE.cond.notify_all()
            self._json(200, {"ok": True})
        elif self.path == "/run" and self._allowed("X-Bridge-Client"):
            req = self._body()
            code = req.get("code")
            if not isinstance(code, str) or not code.strip():
                self._json(400, {"error": "no code"})
                return
            jid = uuid.uuid4().hex[:12]
            timeout = float(req.get("timeout") or 60)
            with STATE.cond:
                STATE.jobs.append({"id": jid, "code": code})
                STATE.cond.notify_all()
                deadline = time.time() + timeout
                while jid not in STATE.results and time.time() < deadline:
                    STATE.cond.wait(timeout=0.5)
                res = STATE.results.pop(jid, None)
                if res is None:
                    # never picked up or never finished: drop it from the queue if it's still there
                    STATE.jobs = deque(j for j in STATE.jobs if j["id"] != jid)
            if res is None:
                self._json(504, {"error": "Studio didn't answer in time. Is the plugin connected (BitLeveling panel > BRIDGE)?"})
            else:
                self._json(200, res)
        else:
            self._json(403, {"error": "not allowed"})


def serve(port):
    httpd = ThreadingHTTPServer(("127.0.0.1", port), Handler)
    print(f"BitLeveling bridge on 127.0.0.1:{port}. In Studio: BitLeveling panel > BRIDGE > Connect. Ctrl+C to stop.")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass


def client(port, method, path, body=None, timeout=90):
    req = urllib.request.Request(f"http://127.0.0.1:{port}{path}", method=method, data=json.dumps(body).encode() if body is not None else None)
    req.add_header("X-Bridge-Client", "1")
    req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return r.status, json.loads(r.read().decode() or "{}")
    except urllib.error.HTTPError as e:
        try:
            return e.code, json.loads(e.read().decode() or "{}")
        except ValueError:
            return e.code, {}
    except urllib.error.URLError as e:
        sys.exit(f"no bridge on port {port} ({e.reason}): start it with  python3 tools/studio_bridge/bridge.py serve")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--port", type=int, default=int(os.environ.get("BITLEVELING_BRIDGE_PORT", PORT)))
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("serve")
    sub.add_parser("status")
    r = sub.add_parser("run")
    r.add_argument("code", nargs="?")
    r.add_argument("--file")
    r.add_argument("--timeout", type=float, default=60)
    r.add_argument("--json", action="store_true", help="print the raw result")
    args = ap.parse_args()
    if args.cmd == "serve":
        serve(args.port)
    elif args.cmd == "status":
        print(json.dumps(client(args.port, "GET", "/status")[1], indent=1))
    else:
        code = open(args.file).read() if args.file else args.code
        if not code:
            sys.exit("give some Luau, or --file")
        status, res = client(args.port, "POST", "/run", {"code": code, "timeout": args.timeout}, timeout=args.timeout + 10)
        if args.json:
            print(json.dumps(res, indent=1))
        else:
            for line in res.get("output") or []:
                print(line)
            if res.get("returns"):
                print("=> " + ", ".join(res["returns"]))
            if res.get("error"):
                print("ERROR: " + str(res["error"]), file=sys.stderr)
        sys.exit(0 if status == 200 and res.get("ok") else 1)


if __name__ == "__main__":
    main()
