#!/usr/bin/env python3
"""
Roblox content scan for the City pack: every string literal in src/shared/City is checked
for things the game must not contain at Roblox's "Moderate" bar (alcohol, drugs, smoking,
gambling, romance or sexual content, self-harm, graphic gore, cannibalism, profanity).
It prints each hit with its file and line, and exits non-zero if there are any.
Words that are fine in context can be allowed below (ALLOW), with a reason.
    python3 tests/safety_scan.py [folder]
"""
import pathlib
import re
import sys

ROOT = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else "src/shared/City")

BANNED = {
    "alcohol": r"\b(alcohol\w*|beers?|wines?|whiske?y|vodka|booze|liquor|drunk\w*|tipsy|hangover|brewer(y|ies)|bartender|cocktails?|soju|rum|gin|tavern|pub)\b",
    "smoking": r"\b(cigar\w*|tobacco|vap(e|es|ing)|nicotine|smoking (a|his|her|their)|lit a smoke|ashtray)\b",
    "drugs": r"\b(drugs?|narcotics?|cocaine|heroin|meth|opium|overdos\w*|junkie|stoned|dealer of \w+ powder|getting high|got high)\b",
    "gambling": r"\b(gambl\w*|casinos?|bet|bets|betting|wager\w*|poker|roulette|slot machines?|lotter(y|ies)|bookie|odds on|place a bet|dice games?)\b",
    # (v0.13) marriage, as a household made official at the District office with family there,
    # is allowed (Config.marriage switches it off); everything romantic stays banned
    "romance": r"\b(sex\w*|nude|naked|kiss\w*|dating|girlfriend|boyfriend|romanc\w*|romantic\w*|lovers?|flirt\w*|seduc\w*|husband|wife|wives|honeymoon|crush on|sweetheart|making out|bride\w*)\b",
    "self-harm": r"\b(suicid\w*|self[- ]harm\w*|kill(ed|s|ing)? (your|him|her|my|them)sel(f|ves)|cut (your|my|him|her)self|hang (your|my|him|her)self|end (it all|your life|their life))\b",
    "gore": r"\b(gore|gory|entrails|intestines?|disembowel\w*|decapitat\w*|behead\w*|dismember\w*|severed (head|limb|arm|leg|hand)s?|eyeballs?|flay\w*|skinned alive|brains? (splatter|matter)|guts spill\w*|torn apart limb)\b",
    "cannibalism": r"\b(cannibal\w*|eat(s|ing)? (people|humans|flesh|children|the dead)|human (flesh|meat)|man-?eat\w*)\b",
    "profanity": r"\b(damn\w*|crap|bastards?|bitch\w*|shit\w*|fuck\w*|piss\w*|asshole|dick|bloody hell|goddamn)\b",
}
# Fine in context (canon names, or a word in a harmless sense). Keep this list short.
ALLOW = [
    r"\bSmoke War\b",          # the canon war, not tobacco
    r"\bodds\b",               # clash odds shown to the player are not gambling
    r"\bThe Odds\b",
    r"\bkiss(ed|es)? (your|his|her|their|a child's|the child's) (forehead|head|hair)\b",  # a parent's goodnight
    r"\b(for|of) (the|your|his|her|their|its|our|my|everyone's|someone's) sake\b",
]

STRING = re.compile(r'"((?:[^"\\]|\\.)*)"')


def main() -> int:
    patterns = {k: re.compile(v, re.IGNORECASE) for k, v in BANNED.items()}
    allow = [re.compile(a, re.IGNORECASE) for a in ALLOW]
    hits = 0
    files = sorted(ROOT.rglob("*.luau"))
    for path in files:
        for lineno, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            stripped = line.strip()
            if stripped.startswith("--"):
                continue
            for m in STRING.finditer(line):
                text = m.group(1)
                clean = text
                for a in allow:
                    clean = a.sub(" ", clean)
                for kind, pat in patterns.items():
                    found = pat.search(clean)
                    if found:
                        hits += 1
                        print(f"{path}:{lineno}: [{kind}] '{found.group(0)}' in: {text[:140]}")
    print(f"\nscanned {len(files)} files: {hits} hit(s)")
    return 1 if hits else 0


if __name__ == "__main__":
    sys.exit(main())
