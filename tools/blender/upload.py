#!/usr/bin/env python3
"""
UPLOAD THE MESH KIT TO ROBLOX (Open Cloud Assets API), then point the game at it.

    python3 tools/blender/upload.py --user <your Roblox user id>        # or --group <group id>
    python3 tools/blender/upload.py --user 123 --update <asset id>        # a new version of it
    python3 tools/blender/upload.py --user 123 --dry-run                  # show the request only

Needs an Open Cloud API key with the Assets API's write permission (create it at
create.roblox.com > Open Cloud > API Keys, for your account or the group that owns the game),
in the ROBLOX_API_KEY environment variable. (In a cloud session whose network proxy adds the
key to requests for apis.roblox.com, any placeholder works.)

It uploads tools/blender/out/kit.fbx as a Model asset owned by you (or the group), waits for
Roblox to process it, and writes the asset id into src/shared/Hunter/MeshAssets.luau. The
game's server then loads it with InsertService (Hunter/MeshLibrary.load), which works for
assets owned by the game's owner. Only the standard library is used.
"""

import argparse, json, os, re, sys, time, uuid
import urllib.request, urllib.error

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
KIT = os.path.join(HERE, "out", "kit.fbx")
ASSETS_LUAU = os.path.join(ROOT, "src", "shared", "Hunter", "MeshAssets.luau")
API = "https://apis.roblox.com/assets/v1"


def multipart(fields, files):
    boundary = "----bitleveling" + uuid.uuid4().hex
    body = bytearray()
    for name, value in fields.items():
        body += f"--{boundary}\r\nContent-Disposition: form-data; name=\"{name}\"\r\n\r\n".encode()
        body += value.encode() + b"\r\n"
    for name, (filename, content, ctype) in files.items():
        body += f"--{boundary}\r\nContent-Disposition: form-data; name=\"{name}\"; filename=\"{filename}\"\r\nContent-Type: {ctype}\r\n\r\n".encode()
        body += content + b"\r\n"
    body += f"--{boundary}--\r\n".encode()
    return bytes(body), f"multipart/form-data; boundary={boundary}"


def call(method, url, key, body=None, ctype=None):
    req = urllib.request.Request(url, data=body, method=method)
    req.add_header("x-api-key", key)
    if ctype:
        req.add_header("Content-Type", ctype)
    try:
        with urllib.request.urlopen(req, timeout=120) as r:
            return r.status, json.loads(r.read().decode() or "{}")
    except urllib.error.HTTPError as e:
        text = e.read().decode(errors="replace")
        try:
            return e.code, json.loads(text)
        except ValueError:
            return e.code, {"message": text[:400]}


def write_id(asset_id):
    src = open(ASSETS_LUAU).read()
    new = re.sub(r"kit = \d+,", f"kit = {asset_id},", src)
    open(ASSETS_LUAU, "w").write(new)
    print(f"wrote kit = {asset_id} into src/shared/Hunter/MeshAssets.luau")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    who = ap.add_mutually_exclusive_group(required=True)
    who.add_argument("--user", type=int, help="your Roblox user id (the asset's owner)")
    who.add_argument("--group", type=int, help="a group id (the asset's owner)")
    ap.add_argument("--update", type=int, help="upload a new version of this asset id instead")
    ap.add_argument("--file", default=KIT)
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    if not os.path.exists(args.file):
        sys.exit(f"{args.file} doesn't exist: run tools/blender/run.sh first")
    key = os.environ.get("ROBLOX_API_KEY") or ""
    if not key and not args.dry_run:
        sys.exit("set ROBLOX_API_KEY to an Open Cloud API key with Assets write permission")
    creator = {"userId": str(args.user)} if args.user else {"groupId": str(args.group)}
    request = {
        "assetType": "Model",
        "displayName": "BitLeveling Mesh Kit",
        "description": "Blender-made meshes for BitLeveling's monsters, weapons and gear (one MeshPart per role).",
        "creationContext": {"creator": creator},
    }
    if args.update:
        request = {"assetId": str(args.update)}
    content = open(args.file, "rb").read()
    body, ctype = multipart({"request": json.dumps(request)}, {"fileContent": (os.path.basename(args.file), content, "model/fbx")})
    url = f"{API}/assets/{args.update}" if args.update else f"{API}/assets"
    method = "PATCH" if args.update else "POST"
    print(f"{method} {url}  ({len(content) // 1024} KB, owner {creator})")
    if args.dry_run:
        print("request:", json.dumps(request))
        return
    status, res = call(method, url, key, body, ctype)
    if status >= 300:
        sys.exit(f"upload refused ({status}): {res}")
    op = res.get("path") or res.get("operationId")
    asset_id = (res.get("response") or {}).get("assetId")
    print("operation:", op)
    for _ in range(60):
        if asset_id or res.get("done"):
            asset_id = asset_id or (res.get("response") or {}).get("assetId")
            break
        time.sleep(3)
        path = op if op and op.startswith("operations/") else f"operations/{op}"
        status, res = call("GET", f"{API}/{path}", key)
        if status >= 300:
            sys.exit(f"checking the upload failed ({status}): {res}")
    if not asset_id:
        sys.exit(f"Roblox didn't finish processing the kit in time; last answer: {res}")
    print(f"uploaded: asset {asset_id}  (https://create.roblox.com/store/asset/{asset_id})")
    write_id(asset_id if not args.update else args.update)


if __name__ == "__main__":
    main()
