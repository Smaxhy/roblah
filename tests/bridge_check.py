#!/usr/bin/env python3
"""
THE STUDIO BRIDGE, CHECKED (tools/studio_bridge/bridge.py), with a stand-in for the plugin:
    python3 tests/bridge_check.py
  1. a chunk sent with `run` reaches the plugin and its output and return values come back
  2. an error in the chunk comes back as an error (and `run` exits 1)
  3. a request from a web page (an Origin header) or without the bridge's header is refused
  4. `run` with no plugin connected times out with a clear message
"""

import json, os, subprocess, sys, threading, time, urllib.request, urllib.error

HERE = os.path.dirname(os.path.abspath(__file__))
BRIDGE = os.path.join(os.path.dirname(HERE), "tools", "studio_bridge", "bridge.py")
PORT = 28000 + os.getpid() % 1000
failures = 0


def check(ok, msg):
    global failures
    print(("  ok    " if ok else "  FAIL  ") + msg)
    if not ok:
        failures += 1


def http(method, path, body=None, headers=None, timeout=30):
    req = urllib.request.Request(f"http://127.0.0.1:{PORT}{path}", method=method, data=json.dumps(body).encode() if body is not None else None)
    for k, v in (headers or {}).items():
        req.add_header(k, v)
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            raw = r.read().decode()
            return r.status, json.loads(raw) if raw else None
    except urllib.error.HTTPError as e:
        raw = e.read().decode()
        return e.code, json.loads(raw) if raw else None


server = subprocess.Popen([sys.executable, BRIDGE, "--port", str(PORT), "serve"], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
try:
    for _ in range(50):
        try:
            http("GET", "/status", headers={"X-Bridge-Client": "1"}, timeout=1)
            break
        except Exception:
            time.sleep(0.1)

    # a stand-in plugin: takes jobs and "runs" them (print -> output, return -> returns, error -> error)
    stop = threading.Event()

    def plugin():
        while not stop.is_set():
            try:
                st, job = http("GET", "/poll", headers={"X-Bridge-Plugin": "1"}, timeout=25)
            except Exception:
                time.sleep(0.2)
                continue
            if st == 200 and job:
                code = job["code"]
                if "error(" in code:
                    res = {"id": job["id"], "ok": False, "error": "boom", "output": []}
                else:
                    res = {"id": job["id"], "ok": True, "output": ["hello from studio"], "returns": ["42"]}
                http("POST", "/result", res, headers={"X-Bridge-Plugin": "1"})

    t = threading.Thread(target=plugin, daemon=True)
    t.start()

    out = subprocess.run([sys.executable, BRIDGE, "--port", str(PORT), "run", "print('hi') return 42"], capture_output=True, text=True, timeout=60)
    check(out.returncode == 0 and "hello from studio" in out.stdout and "=> 42" in out.stdout, "a chunk runs in 'Studio' and its output and returns come back")
    bad = subprocess.run([sys.executable, BRIDGE, "--port", str(PORT), "run", "error('x')"], capture_output=True, text=True, timeout=60)
    check(bad.returncode == 1 and "boom" in bad.stderr, "an error in the chunk comes back as an error")

    st, _ = http("POST", "/run", {"code": "print(1)"}, headers={"X-Bridge-Client": "1", "Origin": "https://evil.example"})
    check(st == 403, "a request from a web page is refused")
    st, _ = http("POST", "/run", {"code": "print(1)"})
    check(st == 403, "a request without the bridge's header is refused")
    st, _ = http("GET", "/poll", headers={"Origin": "https://evil.example", "X-Bridge-Plugin": "1"})
    check(st == 403, "a page can't pretend to be the plugin")
    st, s = http("GET", "/status", headers={"X-Bridge-Client": "1"})
    check(st == 200 and s and s.get("pluginConnected") is True, "status says the plugin is connected")

    stop.set()
    t.join(timeout=30)
    late = subprocess.run([sys.executable, BRIDGE, "--port", str(PORT), "run", "--timeout", "1.5", "print(1)"], capture_output=True, text=True, timeout=60)
    check(late.returncode == 1, "with no plugin connected, run gives up (exit 1)")
finally:
    server.terminate()
    server.wait(timeout=10)

if failures:
    print(f"\n{failures} check(s) failed.")
    sys.exit(1)
print("\nThe bridge carries Luau to Studio and back, and only for this computer's own tools.")
