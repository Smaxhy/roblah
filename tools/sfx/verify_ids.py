#!/usr/bin/env python3
"""Check every sound id the game names against the Roblox Creator Store's own records.

    python3 tools/sfx/verify_ids.py            # check, print a summary, exit 1 on a problem
    python3 tools/sfx/verify_ids.py --table    # also print a Markdown table (docs/SFX.md)
    python3 tools/sfx/verify_ids.py --offline  # only the file checks (no network)

What it reads:
  src/client/WorldSfx.luau   every variant `{ <id>, "<Creator Store name>" }`
  src/client/UiSounds.luau   every id in it (if any)
  src/shared/Config.luau     every id in the `sfx = { ... }` table

What it checks, per id (apis.roblox.com/toolbox-service/v1/items/details, public, read-only):
  - the asset exists and is audio (asset type 3) and is published (free to use)
  - its creator is Roblox (user 1) or ProSoundEffects (user 7462895450, Roblox's licensed
    sound-effects partner), or one of ALLOWED_EXTRA below
  - for WorldSfx, the name written next to the id matches the store's name (so a typo in an id
    can't slip through as a different sound)
  - nothing is filed under gore, and no name or description mentions blood or gore
And for every rbxasset://sounds/ path: the file is one the client ships today (BUILT_IN, from
the client's rbxManifest.txt, version 0.748; MaximumADHD/Roblox-Client-Tracker mirrors it).
Only the Python standard library is used.
"""
import json
import re
import sys
import time
import urllib.request

ROOT = __file__.rsplit("/tools/", 1)[0] if "/tools/" in __file__ else "."
API = "https://apis.roblox.com/toolbox-service/v1/items/details?assetIds="
ROBLOX, PSE = 1, 7462895450
ALLOWED = {ROBLOX: "Roblox", PSE: "ProSoundEffects"}
ALLOWED_EXTRA = {}  # creator id -> name, for any other creator the team decides to trust
# the music (Config.music.moods): Roblox's licensed libraries (APM, DistroKid) or Roblox
MUSIC_ALLOWED = {1: "Roblox", 7462718749: "APMOfficial", 7135127272: "DistrokidOfficial"}
BUILT_IN = {
    "action_falling.ogg", "action_footsteps_plastic.mp3", "action_get_up.mp3", "action_jump.mp3",
    "action_jump_land.mp3", "action_swim.mp3", "impact_explosion_03.mp3", "impact_water.mp3",
    "oof.ogg", "ouch.ogg", "volume_slider.ogg",
}
BAD_WORDS = re.compile(r"\b(blood|bloody|gore|gory|flesh|guts)\b", re.I)


def read(path):
    try:
        with open(f"{ROOT}/{path}", encoding="utf-8") as f:
            return f.read()
    except OSError:
        return ""


def config_sfx_block(text):
    i = text.find("sfx = {")
    if i < 0:
        return ""
    depth = 0
    for j in range(i + len("sfx = "), len(text)):
        if text[j] == "{":
            depth += 1
        elif text[j] == "}":
            depth -= 1
            if depth == 0:
                return text[i:j + 1]
    return ""


def config_music_block(text):
    i = text.find("moods = {")
    if i < 0:
        return ""
    depth = 0
    for j in range(i + len("moods = "), len(text)):
        if text[j] == "{":
            depth += 1
        elif text[j] == "}":
            depth -= 1
            if depth == 0:
                return text[i:j + 1]
    return ""


def strip_comments(text):
    # Luau block comments (--[[ ]], --[=[ ]=]) and line comments; ids in prose aren't sounds
    text = re.sub(r"--\[(=*)\[.*?\]\1\]", "", text, flags=re.S)
    text = "\n".join(line.split("--", 1)[0] for line in text.splitlines())
    # the keys of a legacy-path map (["rbxasset://sounds/x.wav"] = ...) name old files, not sounds to play
    return re.sub(r"\[\s*\"rbxasset://sounds/[^\"]+\"\s*\]\s*=", "", text)


def collect():
    named = {}  # id -> expected name (WorldSfx)
    where = {}  # id -> set of files
    paths = {}  # rbxasset path -> set of files
    ws = read("src/client/WorldSfx.luau")
    for m in re.finditer(r"\{\s*(\d{6,}),\s*\"([^\"]+)\"\s*\}", ws):
        named[int(m.group(1))] = m.group(2)
        where.setdefault(int(m.group(1)), set()).add("WorldSfx")
    for name, text in (("WorldSfx", ws), ("UiSounds", read("src/client/UiSounds.luau")),
                       ("Config.sfx", config_sfx_block(read("src/shared/Config.luau")))):
        code = strip_comments(text)
        for m in re.finditer(r"(?<![\w.])(\d{7,})(?![\w.])", code):
            where.setdefault(int(m.group(1)), set()).add(name)
        for m in re.finditer(r"rbxasset://sounds/([\w .\-]+\.(?:wav|mp3|ogg))", code):
            paths.setdefault(m.group(1), set()).add(name)
    music = set()
    for m in re.finditer(r"(?<![\w.])(\d{7,})(?![\w.])", strip_comments(config_music_block(read("src/shared/Config.luau")))):
        music.add(int(m.group(1)))
    return named, where, paths, music


def fetch(ids):
    out = {}
    ids = sorted(ids)
    for i in range(0, len(ids), 30):
        chunk = ids[i:i + 30]
        for attempt in range(4):
            try:
                with urllib.request.urlopen(API + ",".join(map(str, chunk)), timeout=40) as r:
                    data = json.loads(r.read().decode("utf-8"))
                break
            except Exception as e:  # rate limits, the odd timeout
                if attempt == 3:
                    print(f"  ! lookup failed for {chunk[0]}..: {e}", file=sys.stderr)
                    data = {"data": []}
                time.sleep(1.5 * (attempt + 1))
        for x in data.get("data", []):
            a, c = x.get("asset", {}), x.get("creator", {})
            fp = x.get("fiatProduct") or {}
            out[a.get("id")] = {
                "name": a.get("name") or "", "type": a.get("typeId"), "creator": c.get("id"),
                "creatorName": c.get("name"), "published": fp.get("published"),
                "duration": a.get("duration"),
                "desc": (a.get("description") or "").replace("\n", " "),
            }
    return out


def norm(name):
    return re.sub(r"\s+", " ", name.replace("(SFX)", "")).strip().lower()


def main():
    offline = "--offline" in sys.argv
    named, where, paths, music = collect()
    problems = []
    for p, files in sorted(paths.items()):
        if p not in BUILT_IN:
            problems.append(f"rbxasset://sounds/{p} ({', '.join(sorted(files))}) is not in today's client")
    print(f"{len(where)} ids ({len(named)} named in WorldSfx), {len(paths)} built-in files")
    rows = {}
    if not offline:
        rows = fetch(where.keys())
        for i in sorted(where):
            r = rows.get(i)
            files = ", ".join(sorted(where[i]))
            if not r:
                problems.append(f"{i} ({files}): not found (private, removed, or not an asset)")
                continue
            ok_creator = r["creator"] in ALLOWED or r["creator"] in ALLOWED_EXTRA
            if r["type"] != 3:
                problems.append(f"{i} ({files}): not audio (type {r['type']})")
            if not r["published"]:
                problems.append(f"{i} ({files}): not published")
            if not ok_creator:
                problems.append(f"{i} ({files}): by {r['creatorName']} ({r['creator']}), not Roblox or ProSoundEffects")
            if i in named and norm(named[i]) != norm(r["name"]):
                problems.append(f"{i} (WorldSfx): written as \"{named[i]}\", the store says \"{r['name']}\"")
            if BAD_WORDS.search(r["name"]) or BAD_WORDS.search(r["desc"]):
                problems.append(f"{i} ({files}): \"{r['name']}\" mentions gore")
        # the music: published audio from Roblox's licensed libraries
        mrows = fetch(music)
        for i in sorted(music):
            r = mrows.get(i)
            if not r:
                problems.append(f"{i} (Config.music): not found")
            elif r["type"] != 3 or r["creator"] not in MUSIC_ALLOWED:
                problems.append(f"{i} (Config.music): \"{r['name']}\" by {r['creatorName']} ({r['creator']}), not a licensed library")
        print(f"music: {len(music)} tracks, " + ", ".join(sorted({r['creatorName'] for r in mrows.values()})))
        by = {}
        for r in rows.values():
            by[r["creatorName"]] = by.get(r["creatorName"], 0) + 1
        print("creators: " + ", ".join(f"{k} {v}" for k, v in sorted(by.items(), key=lambda kv: -kv[1])))
    if "--table" in sys.argv and rows:
        print("\n| id | Creator Store name | creator | s | used in |\n|---|---|---|---|---|")
        for i in sorted(where):
            r = rows.get(i)
            if r:
                print(f"| {i} | {r['name']} | {r['creatorName']} | {r['duration']} | {', '.join(sorted(where[i]))} |")
    if problems:
        print(f"\n{len(problems)} problem(s):")
        for p in problems:
            print("  - " + p)
        sys.exit(1)
    print("every sound checks out")


if __name__ == "__main__":
    main()
