"""
THE BITLEVELING MESH KIT, MODELED IN BLENDER (bpy, headless).

    tools/blender/run.sh kit.py            (or: <venv>/bin/python tools/blender/kit.py)

Builds one mesh per ROLE (Hunter/MeshLibrary.luau ROLES: a monster's head, a beast's leg, a
wing, a blade, a crossguard, a pauldron, a cape...). Every mesh is modeled in the local space of
the Roblox part that plays the role (X right, Y up, -Z forward) and fitted to the unit cube, so a
MeshPart the part's size shows it exactly where the part was. Writes:

    tools/blender/out/kit.fbx        every role mesh, one object each, named by role
                                     (import it with Studio's 3D Importer, or upload.py)
    tools/blender/out/kit.blend      the same, to open in Blender and edit by hand
    tools/blender/out/kit.json       per role: triangles, vertices (for the tests)

Everything is procedural: a superquadric (a rounded box to a sphere) bent, tapered, bulged and
roughened, a lathe for anything round along an axis, and outlines extruded for the flat things.
"""

import bpy, bmesh, json, math, os, sys
from mathutils import Matrix, Vector

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "out")
os.makedirs(OUT, exist_ok=True)

# Roblox (x, y, z) -> Blender (x, -z, y): a rotation of +90 degrees about X. FBX export with
# bake_space_transform and the default axes undoes it, so the file holds Roblox coordinates.
TO_BLENDER = Matrix.Rotation(math.radians(90), 4, "X")


def clamp(v, a, b):
    return max(a, min(b, v))


def smoothstep(a, b, t):
    t = clamp((t - a) / (b - a), 0.0, 1.0)
    return t * t * (3 - 2 * t)


def hash_noise(x, y, z, freq=7.0, seed=0.0):
    """Cheap smooth-ish value noise from sines (deterministic: the same mesh every run)."""
    return (
        math.sin(x * freq * 1.7 + seed) * math.cos(y * freq * 1.3 + seed * 0.7)
        + math.sin(z * freq * 1.9 + x * 2.1 + seed * 1.3) * 0.6
        + math.sin((x + y + z) * freq * 2.7 + seed * 2.1) * 0.35
    ) / 1.95


# ── shapes ────────────────────────────────────────────────────────────────────────
def superq(e1=0.6, e2=0.6, nu=28, nv=18):
    """A superquadric in [-0.5, 0.5]^3: e near 0.1 is a rounded box, 1.0 a sphere."""
    def spow(c, e):
        return math.copysign(abs(c) ** e, c)

    verts, faces = [], []
    for j in range(1, nv):
        v = -math.pi / 2 + math.pi * j / nv
        for i in range(nu):
            u = -math.pi + 2 * math.pi * i / nu
            x = 0.5 * spow(math.cos(v), e1) * spow(math.cos(u), e2)
            z = 0.5 * spow(math.cos(v), e1) * spow(math.sin(u), e2)
            y = 0.5 * spow(math.sin(v), e1)
            verts.append([x, y, z])
    bottom = len(verts)
    verts.append([0, -0.5, 0])
    top = len(verts)
    verts.append([0, 0.5, 0])
    rows = nv - 1
    for j in range(rows - 1):
        for i in range(nu):
            a = j * nu + i
            b = j * nu + (i + 1) % nu
            c = (j + 1) * nu + (i + 1) % nu
            d = (j + 1) * nu + i
            faces.append([a, b, c, d])
    for i in range(nu):
        faces.append([bottom, (i + 1) % nu, i])
        faces.append([top, (rows - 1) * nu + i, (rows - 1) * nu + (i + 1) % nu])
    return verts, faces


def lathe(profile, segments=16, axis="y", caps=True):
    """Revolve [(t, r)] (t along the axis from -0.5 to 0.5, r a radius up to 0.5)."""
    verts, faces = [], []
    n = len(profile)
    for (t, r) in profile:
        for i in range(segments):
            a = 2 * math.pi * i / segments
            c, s = math.cos(a) * r, math.sin(a) * r
            if axis == "y":
                verts.append([c, t, s])
            elif axis == "x":
                verts.append([t, c, s])
            else:
                verts.append([c, s, t])
    for j in range(n - 1):
        for i in range(segments):
            a = j * segments + i
            b = j * segments + (i + 1) % segments
            c = (j + 1) * segments + (i + 1) % segments
            d = (j + 1) * segments + i
            faces.append([a, b, c, d] if axis != "z" else [a, d, c, b])
    if caps:
        for end, ring in ((0, 0), (1, n - 1)):
            t = profile[ring][0]
            ci = len(verts)
            verts.append([0, t, 0] if axis == "y" else ([t, 0, 0] if axis == "x" else [0, 0, t]))
            for i in range(segments):
                a = ring * segments + i
                b = ring * segments + (i + 1) % segments
                faces.append([ci, b, a] if end == 0 else [ci, a, b])
    return verts, faces


def slab(outline_fn, nu=40, nv=8, thick_fn=None):
    """A flat thing in the X-Y plane (thin along Z): outline_fn(u) gives (x, y_low, y_high) for
    u in 0..1 across X; thick_fn(x, y, v) the half-thickness. Top and bottom skins and a rim."""
    verts, faces = [], []
    grid = []
    for side in (1, -1):
        rows = []
        for i in range(nu + 1):
            u = i / nu
            x, y0, y1 = outline_fn(u)
            row = []
            for j in range(nv + 1):
                v = j / nv
                y = y0 + (y1 - y0) * v
                h = thick_fn(x, y, v) if thick_fn else 0.5
                row.append(len(verts))
                verts.append([x, y, side * h])
            rows.append(row)
        grid.append(rows)
    for s, rows in enumerate(grid):
        for i in range(nu):
            for j in range(nv):
                a, b, c, d = rows[i][j], rows[i + 1][j], rows[i + 1][j + 1], rows[i][j + 1]
                faces.append([a, b, c, d] if s == 0 else [a, d, c, b])
    top, bot = grid[0], grid[1]
    for i in range(nu):  # the rim along both long edges
        for j in (0, nv):
            a, b = top[i][j], top[i + 1][j]
            c, d = bot[i + 1][j], bot[i][j]
            faces.append([a, d, c, b] if j == 0 else [a, b, c, d])
    for i in (0, nu):  # the ends
        for j in range(nv):
            a, b = top[i][j], top[i][j + 1]
            c, d = bot[i][j + 1], bot[i][j]
            faces.append([a, b, c, d] if i == 0 else [a, d, c, b])
    return verts, faces


def remap(verts, fn):
    return [list(fn(*v)) for v in verts]


def swap_axes(verts, order):
    """order like 'zyx': where each output axis is read from."""
    idx = {"x": 0, "y": 1, "z": 2}
    return [[v[idx[order[0]]], v[idx[order[1]]], v[idx[order[2]]]] for v in verts]


def fit_unit(verts):
    """Scale and centre into exactly [-0.5, 0.5] on every axis (a MeshPart fills its Size)."""
    lo = [min(v[k] for v in verts) for k in range(3)]
    hi = [max(v[k] for v in verts) for k in range(3)]
    out = []
    for v in verts:
        out.append([(v[k] - (lo[k] + hi[k]) / 2) / max(1e-6, hi[k] - lo[k]) for k in range(3)])
    return out


# ── the roles ──────────────────────────────────────────────────────────────────────
def head_biped():
    v, f = superq(0.55, 0.6)

    def d(x, y, z):
        # a heavy brow, a jaw that juts, a skull that narrows to the back
        if z < -0.2 and 0.05 < y < 0.28:
            z -= 0.07 * smoothstep(-0.2, -0.45, z)
        if y < -0.1:
            x *= 1.0 - 0.18 * smoothstep(-0.1, -0.5, y) * (0.5 + 0.5 * smoothstep(0.5, -0.5, z))
            z -= 0.05 * smoothstep(-0.1, -0.4, y) * smoothstep(0.0, -0.5, z)
        if z > 0.1:
            x *= 1.0 - 0.12 * smoothstep(0.1, 0.5, z)
        return x, y, z

    return remap(v, d), f


def head_beast():
    v, f = superq(0.6, 0.6)

    def d(x, y, z):
        k = smoothstep(0.1, -0.5, z)  # the muzzle narrows to the front
        x *= 1.0 - 0.38 * k
        y = y * (1.0 - 0.3 * k) - 0.08 * k
        if y < -0.3:
            y = -0.3 - (-0.3 - y) * 0.6  # a flatter jaw
        return x, y, z

    return remap(v, d), f


def head_serpent():
    v, f = superq(0.5, 0.75)

    def d(x, y, z):
        k = smoothstep(0.3, -0.5, z)
        x *= 1.0 - 0.45 * k
        y *= 1.0 - 0.45 * k
        if y > 0.25 and abs(x) > 0.18:
            y += 0.06 * smoothstep(-0.1, 0.2, -z)  # brow plates over the eyes
        return x, y, z

    return remap(v, d), f


def rocky(v, amp=0.05, freq=6.0, seed=0.0):
    out = []
    for (x, y, z) in v:
        n = hash_noise(x, y, z, freq, seed)
        r = math.sqrt(x * x + y * y + z * z) + 1e-6
        k = 1.0 + amp * n / max(0.25, r)
        out.append([x * k, y * k, z * k])
    return out


def head_golem():
    v, f = superq(0.25, 0.25, 22, 14)
    return rocky(v, 0.06, 7, 1.0), f


def snout():
    v, f = superq(0.6, 0.6)
    return remap(v, lambda x, y, z: (x * (1 - 0.35 * smoothstep(0.3, -0.5, z)), y * (1 - 0.3 * smoothstep(0.3, -0.5, z)), z)), f


def ear():
    v, f = superq(0.9, 0.9)

    def d(x, y, z):
        px = 1.0 - 0.85 * smoothstep(0.15, 0.5, abs(x))  # pointed at both ends across X
        py = 1.0 - 0.7 * smoothstep(0.1, 0.5, y)  # and up at the top
        return x, y, z * px * py

    return remap(v, d), f


def horn(axis):
    prof = []
    for i in range(13):
        t = -0.5 + i / 12
        r = 0.5 * (1 - (t + 0.5)) ** 0.9 + 0.02
        r *= 1.0 + 0.06 * math.sin(i * 1.9)  # growth rings
        prof.append((t, r))
    v, f = lathe(prof, 12, "y")

    def bend(x, y, z):
        k = (y + 0.5) ** 2
        return x, y, z - 0.35 * k  # curves forward to the tip

    v = remap(v, bend)
    if axis == "x":
        v = swap_axes(v, "yxz")
    elif axis == "z":
        v = swap_axes(v, "xzy")
    return v, f


def torso_biped():
    v, f = superq(0.45, 0.6)

    def d(x, y, z):
        x *= 0.78 + 0.27 * smoothstep(-0.5, 0.35, y)  # broad shoulders to a waist
        if z < 0 and y > -0.05:
            z -= 0.07 * smoothstep(-0.05, 0.25, y) * (1 - smoothstep(0.25, 0.5, y))  # the chest
        if y > 0.38:
            x *= 1.0 - 0.15 * smoothstep(0.38, 0.5, y)  # sloped shoulders
        return x, y, z

    return remap(v, d), f


def torso_golem():
    v, f = superq(0.22, 0.22, 24, 16)
    v = remap(v, lambda x, y, z: (x * (0.85 + 0.2 * smoothstep(-0.5, 0.4, y)), y, z))
    return rocky(v, 0.05, 6, 2.0), f


def body_quad():
    v, f = superq(0.55, 0.55, 30, 18)

    def d(x, y, z):
        chest = smoothstep(0.4, -0.3, z)  # deep at the chest, tucked at the belly
        if y < 0:
            y *= 0.75 + 0.35 * chest
        if y > 0.2:
            y += 0.05 * smoothstep(-0.1, -0.35, z)  # shoulder hump
        x *= 0.88 + 0.12 * chest
        return x, y, z

    return remap(v, d), f


def body_flyer():
    v, f = superq(0.7, 0.7)
    return remap(v, lambda x, y, z: (x * (1 - 0.5 * smoothstep(-0.2, 0.5, z)), y * (1 - 0.4 * smoothstep(-0.2, 0.5, z)), z)), f


def carapace():
    v, f = superq(0.55, 0.45, 30, 18)

    def d(x, y, z):
        if y < -0.2:
            y = -0.2 + (y + 0.2) * 0.35  # flat underneath
        k = 1.0 - 0.05 * (0.5 + 0.5 * math.cos(z * math.pi * 7))  # plate grooves
        return x * k, y * k, z

    return remap(v, d), f


def cephalothorax():
    v, f = superq(0.75, 0.6)
    return remap(v, lambda x, y, z: (x * (1 - 0.2 * smoothstep(0.2, -0.5, z)), y, z)), f


def abdomen():
    v, f = superq(0.95, 0.95, 28, 18)
    return remap(v, lambda x, y, z: (x * (0.85 + 0.15 * smoothstep(-0.5, 0.3, z)), y * (0.9 + 0.1 * smoothstep(-0.5, 0.3, z)), z)), f


def slime():
    v, f = superq(0.95, 0.95, 28, 18)

    def d(x, y, z):
        w = 1.0 + 0.18 * smoothstep(0.3, -0.4, y)  # it sags
        if y < -0.38:
            y = -0.38 - (-0.38 - y) * 0.3
        if y > 0.35 and abs(x) < 0.12 and abs(z) < 0.12:
            y += 0.06  # a little peak
        return x * w, y, z * w

    return remap(v, d), f


def limb_profile(points, segs=14):
    v, f = lathe(points, segs, "y")
    return v, f


def arm():
    prof = [(0.5, 0.36), (0.42, 0.48), (0.3, 0.5), (0.12, 0.42), (0.0, 0.36), (-0.12, 0.4), (-0.28, 0.36), (-0.36, 0.32), (-0.42, 0.42), (-0.48, 0.38), (-0.5, 0.2)]
    v, f = limb_profile(prof)
    return remap(v, lambda x, y, z: (x, y, z * (1.0 if y > -0.36 else 1.15))), f


def leg():
    prof = [(0.5, 0.4), (0.4, 0.5), (0.2, 0.46), (0.02, 0.36), (-0.06, 0.38), (-0.2, 0.42), (-0.34, 0.32), (-0.42, 0.3), (-0.5, 0.3)]
    v, f = limb_profile(prof)

    def d(x, y, z):
        if y < -0.38:
            z -= 0.22 * smoothstep(-0.38, -0.5, y) * (1 if z < 0.05 else 0.3)  # the foot
        return x, y, z

    return remap(v, d), f


def arm_golem():
    v, f = superq(0.25, 0.25, 20, 18)
    v = remap(v, lambda x, y, z: (x * (0.9 + 0.12 * smoothstep(-0.1, -0.5, y)), y, z * (0.9 + 0.12 * smoothstep(-0.1, -0.5, y))))
    return rocky(v, 0.07, 7, 3.0), f


def leg_golem():
    v, f = superq(0.25, 0.25, 20, 14)
    return rocky(v, 0.06, 6, 4.0), f


def leg_quad():
    prof = [(0.5, 0.42), (0.35, 0.5), (0.15, 0.4), (0.0, 0.3), (-0.2, 0.26), (-0.36, 0.24), (-0.44, 0.3), (-0.5, 0.26)]
    v, f = limb_profile(prof)

    def d(x, y, z):
        if y > 0.2:
            z *= 1.2  # a deep thigh
        if y < -0.4:
            z -= 0.12  # the paw sits forward
        return x, y, z

    return remap(v, d), f


def leg_insect():
    prof = [(0.5, 0.42), (0.36, 0.5), (0.2, 0.34), (0.06, 0.32), (-0.02, 0.42), (-0.12, 0.3), (-0.3, 0.24), (-0.42, 0.14), (-0.5, 0.02)]
    return lathe(prof, 10, "y")


def sleeve():
    prof = [(0.5, 0.3), (0.35, 0.34), (0.0, 0.38), (-0.3, 0.44), (-0.5, 0.5)]
    v, f = lathe(prof, 16, "y", caps=True)
    return remap(v, lambda x, y, z: (x * (1 + 0.05 * math.sin(math.atan2(z, x) * 5)), y, z)), f


def tail():
    prof = []
    for i in range(14):
        t = -0.5 + i / 13
        prof.append((t, 0.5 * (1 - (t + 0.5)) ** 0.8 + 0.03))
    v, f = lathe(prof, 12, "z")
    return remap(v, lambda x, y, z: (x, y + 0.25 * (z + 0.5) ** 2, z)), f


def wing(right=True):
    # in the X-Z plane (thin along Y): the root at -X, the tip at +X, the leading edge at -Z
    def outline(u):
        x = -0.5 + u
        front = -0.5 + 0.08 * u
        span = 1.0 - 0.75 * u ** 1.4
        scallop = 0.22 * abs(math.sin(u * math.pi * 3.0)) * (1 - u)
        back = front + span - scallop
        return x, front, back

    def thick(x, z, v):
        bone = 1.0 - smoothstep(0.0, 0.18, v)  # the arm bone along the leading edge
        finger = max(0.0, 1.0 - abs(math.sin(((x + 0.5) * math.pi * 3.0))) * 6) * 0.5
        return 0.18 + 0.32 * max(bone, finger)

    v, f = slab(outline, 48, 10, thick)
    v = swap_axes(v, "xzy")  # slab is X-Y with Z thin; a wing is X-Z with Y thin
    if not right:
        v = [[-p[0], p[1], p[2]] for p in v]
        f = [list(reversed(face)) for face in f]
    return v, f


def segment():
    v, f = superq(0.75, 0.8)
    return remap(v, lambda x, y, z: (x * (1 - 0.06 * math.cos(z * math.pi * 4)), y * (1 - 0.06 * math.cos(z * math.pi * 4)), z)), f


def neck():
    prof = [(-0.5, 0.5), (-0.2, 0.44), (0.2, 0.4), (0.5, 0.36)]
    v, f = lathe(prof, 14, "y")
    return remap(v, lambda x, y, z: (x, y, z - 0.18 * math.sin((y + 0.5) * math.pi))), f


def robe():
    prof = [(0.5, 0.3), (0.3, 0.36), (0.0, 0.42), (-0.3, 0.47), (-0.5, 0.5)]
    v, f = lathe(prof, 32, "y")
    return remap(v, lambda x, y, z: (x * (1 + 0.06 * math.sin(math.atan2(z, x) * 8) * (0.5 - y)), y, z * (1 + 0.06 * math.sin(math.atan2(z, x) * 8) * (0.5 - y)))), f


def hood_open():
    v, f = superq(0.7, 0.7)

    def d(x, y, z):
        if z < -0.15:
            k = smoothstep(0.32, 0.1, abs(x)) * smoothstep(0.34, 0.05, abs(y + 0.05))
            z += 0.55 * k * smoothstep(-0.15, -0.5, z)  # the opening, deep and dark
        if y > 0.3 and z > 0.1:
            z += 0.08 * smoothstep(0.3, 0.5, y)  # the point at the back
        return x, y, z

    return remap(v, d), f


def crystal(axis):
    prof = [(-0.5, 0.0), (-0.42, 0.36), (-0.3, 0.5), (0.22, 0.5), (0.5, 0.0)]
    v, f = lathe(prof, 6, "y", caps=False)
    if axis == "x":
        v = swap_axes(v, "yxz")
    elif axis == "z":
        v = swap_axes(v, "xzy")
    return v, f


def core_gem():
    prof = [(-0.5, 0.0), (-0.15, 0.5), (0.15, 0.5), (0.5, 0.0)]
    return lathe(prof, 8, "z", caps=False)


def armor_plate():
    v, f = superq(0.3, 0.35)
    return remap(v, lambda x, y, z: (x * (1 - 0.04 * abs(math.sin(y * math.pi * 3))), y, z * (1 - 0.04 * abs(math.sin(y * math.pi * 3))))), f


def club_head():
    v, f = superq(0.8, 0.8, 26, 18)
    out = []
    for (x, y, z) in v:
        bump = 1.0 + 0.12 * max(0.0, math.sin(x * 19) * math.sin(y * 17) * math.sin(z * 23))
        out.append([x * bump, y * bump, z * bump])
    return out, f


def axe_head():
    # thin along X; the haft at the back (+Z), the cutting edge a convex curve at the front (-Z)
    def outline(u):
        z = 0.5 - u  # u 0 at the haft, 1 at the edge
        h = 0.2 + 0.3 * u ** 1.6
        bulge = 0.06 * math.sin(u * math.pi)
        return z, -h - bulge, h + bulge

    def thick(z, y, v):
        edge = smoothstep(0.55, 1.0, 0.5 - z)  # thins to an edge
        return 0.5 * (1 - 0.85 * edge)

    v, f = slab(outline, 30, 10, thick)
    v = swap_axes(v, "zyx")  # slab X-Y (thin Z) -> Z-Y (thin X)
    return v, f


def scythe_blade():
    def outline(u):
        z = 0.5 - u  # from the shaft (+Z) out to the point (-Z)
        w = 0.5 * (1 - u) ** 0.8 + 0.02
        c = 0.35 * u * u  # it curves down to the point
        return z, 0.5 - 2 * w - c, 0.5 - c

    def thick(z, y, v):
        return 0.5 * (1 - 0.8 * smoothstep(0.4, 0.0, v))  # the edge is the lower side

    v, f = slab(outline, 32, 8, thick)
    v = swap_axes(v, "zyx")
    return v, f


def spear_point():
    prof = []
    for i in range(12):
        t = -0.5 + i / 11  # back (-) to point (+); flipped to -Z below
        r = 0.5 * math.sin(math.pi * clamp((t + 0.5) * 1.15, 0, 1)) ** 0.7
        if t > 0.35:
            r *= 1 - smoothstep(0.35, 0.5, t)
        prof.append((t, max(0.01, r)))
    v, f = lathe(prof, 4, "z")
    return remap(v, lambda x, y, z: (x, y, -z)), f


def blade():
    # thin along X, width along Y, length along Z: a diamond section, a touch of taper
    def outline(u):
        z = 0.5 - u
        w = 0.5 * (1 - 0.1 * u)
        return z, -w, w

    def thick(z, y, v):
        return 0.5 * (1 - abs(v - 0.5) * 2) ** 0.85 + 0.03

    v, f = slab(outline, 6, 12, thick)
    v = swap_axes(v, "zyx")
    return v, f


def blade_tip():
    # like a WedgePart: full at the back (+Z), running out to a point at the front-bottom
    def outline(u):
        z = 0.5 - u
        top = 0.5 - 1.0 * (u ** 0.75)
        return z, -0.5, max(-0.49, top)

    def thick(z, y, v):
        return 0.5 * (1 - abs(v - 0.5) * 2) ** 0.85 + 0.03

    v, f = slab(outline, 16, 10, thick)
    v = swap_axes(v, "zyx")
    return v, f


def guard():
    prof = []
    for i in range(17):
        t = -0.5 + i / 16
        r = 0.5 * (0.55 + 0.45 * (1 - abs(t) * 2) ** 0.5)
        if abs(t) > 0.42:
            r = 0.5  # round ends
        prof.append((t, r))
    v, f = lathe(prof, 10, "x")
    return remap(v, lambda x, y, z: (x, y, z + 0.25 * (abs(x) * 2) ** 2)), f  # quillons bend toward the hand


def rod(axis):
    prof = [(-0.5, 0.36), (-0.47, 0.48), (0.47, 0.48), (0.5, 0.36)]
    v, f = lathe(prof, 12, axis)
    return v, f


def hammer_head():
    v, f = superq(0.3, 0.3)

    def d(x, y, z):
        flare = 1.0 + 0.12 * smoothstep(0.25, 0.5, abs(z))  # faces flare at both ends
        band = 1.0 + 0.05 * (1 - smoothstep(0.0, 0.08, abs(z)))
        return x * flare * band, y * flare * band, z

    return remap(v, d), f


def shield(thin):
    # a heater shield in its broad plane, bulging out a little
    def outline(u):
        a = -0.5 + u
        k = abs(a) * 2
        bottom = -0.5 + 0.5 * k ** 1.6  # comes to a point at the bottom
        top = 0.5 - 0.06 * k ** 3
        return a, bottom, top

    def thick(a, y, v):
        return 0.5 * (0.35 + 0.65 * (1 - (abs(a) * 2) ** 2) * (1 - ((y) * 1.5) ** 2 * 0.3))

    v, f = slab(outline, 24, 16, thick)  # broad X-Y, thin Z
    if thin == "x":
        v = swap_axes(v, "zyx")
    return v, f


def cloth(thin):
    def outline(u):
        x = -0.5 + u
        hem = -0.5 + 0.05 * math.sin(u * math.pi * 6) + 0.03 * math.sin(u * math.pi * 13)
        return x, hem, 0.5

    def thick(x, y, v):
        return 0.25

    v, f = slab(outline, 40, 14, thick)

    def folds(x, y, z):
        fold = 0.35 * math.sin((x + 0.5) * math.pi * 5) * (0.3 + 0.7 * (0.5 - y))
        return x, y, z + fold

    v = remap(v, folds)
    if thin == "x":
        v = swap_axes(v, "zyx")
    return v, f


def pauldron():
    v, f = superq(0.55, 0.55)

    def d(x, y, z):
        if y < -0.1:
            y = -0.1 + (y + 0.1) * 0.25  # an open shell, not a ball
        band = 1.0 + 0.05 * (1 if math.sin((y + 0.5) * math.pi * 3) > 0 else 0)  # two lames
        return x * band, y, z * band

    return remap(v, d), f


def cuirass():
    v, f = superq(0.35, 0.45)

    def d(x, y, z):
        if z < -0.1:
            for px in (-0.22, 0.22):
                k = math.exp(-((x - px) ** 2 + (y - 0.22) ** 2) / 0.02)
                z -= 0.07 * k  # the breastplate's two plates
            z -= 0.03 * (1 - smoothstep(0.0, 0.05, abs(x))) * smoothstep(-0.4, 0.3, y)  # the centre ridge
        x *= 1.0 + 0.06 * smoothstep(-0.3, -0.5, y)  # flared at the waist
        return x, y, z

    return remap(v, d), f


def helm():
    v, f = superq(0.4, 0.35)

    def d(x, y, z):
        if y > 0.15:
            k = smoothstep(0.15, 0.5, y)
            x *= 1 - 0.18 * k
            z *= 1 - 0.18 * k  # a domed top
        if z < -0.3 and abs(x) < 0.06:
            z -= 0.04  # the ridge down the face
        return x, y, z

    return remap(v, d), f


ROLES = {
    "head_biped": head_biped, "head_beast": head_beast, "head_serpent": head_serpent, "head_golem": head_golem,
    "snout": snout, "ear": ear, "horn_x": lambda: horn("x"), "horn_y": lambda: horn("y"), "horn_z": lambda: horn("z"),
    "torso_biped": torso_biped, "torso_golem": torso_golem, "body_quad": body_quad, "body_flyer": body_flyer,
    "carapace": carapace, "cephalothorax": cephalothorax, "abdomen": abdomen, "slime": slime,
    "arm": arm, "leg": leg, "arm_golem": arm_golem, "leg_golem": leg_golem, "leg_quad": leg_quad, "leg_insect": leg_insect, "sleeve": sleeve,
    "tail": tail, "wing_r": lambda: wing(True), "wing_l": lambda: wing(False), "segment": segment, "neck": neck,
    "robe": robe, "hood_open": hood_open, "crystal_x": lambda: crystal("x"), "crystal_y": lambda: crystal("y"), "crystal_z": lambda: crystal("z"),
    "core_gem": core_gem, "armor_plate": armor_plate, "club_head": club_head, "axe_head": axe_head, "scythe_blade": scythe_blade, "spear_point": spear_point,
    "blade": blade, "blade_tip": blade_tip, "guard": guard, "rod_x": lambda: rod("x"), "rod_y": lambda: rod("y"), "rod_z": lambda: rod("z"),
    "hammer_head": hammer_head, "shield_x": lambda: shield("x"), "shield_z": lambda: shield("z"),
    "cloth_x": lambda: cloth("x"), "cloth_z": lambda: cloth("z"), "pauldron": pauldron, "cuirass": cuirass, "helm": helm,
}
FLAT = {"crystal_x", "crystal_y", "crystal_z", "core_gem", "torso_golem", "head_golem", "arm_golem", "leg_golem"}


def build_mesh(role):
    verts, faces = ROLES[role]()
    verts = fit_unit(verts)
    me = bpy.data.meshes.new(role)
    me.from_pydata([tuple(v) for v in verts], [], [tuple(f) for f in faces])
    me.validate(clean_customdata=False)
    me.update()
    # consistent outward normals (some generators wind their faces by hand)
    bm = bmesh.new()
    bm.from_mesh(me)
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-5)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    bm.to_mesh(me)
    bm.free()
    for p in me.polygons:
        p.use_smooth = role not in FLAT
    return me


def reset():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def main():
    reset()
    known = None
    layout_path = os.path.join(OUT, "layout.json")
    if os.path.exists(layout_path):
        known = json.load(open(layout_path)).get("roles")
    missing = [r for r in (known or []) if r not in ROLES]
    if missing:
        print("ERROR: roles with no Blender model:", missing)
        sys.exit(1)
    stats = {}
    coll = bpy.context.scene.collection
    for i, role in enumerate(ROLES):
        me = build_mesh(role)
        me.transform(TO_BLENDER)  # model in Roblox space, store in Blender's
        ob = bpy.data.objects.new(role, me)
        ob.location = ((i % 10) * 2.0, -(i // 10) * 2.0, 0)
        coll.objects.link(ob)
        tris = sum(len(p.vertices) - 2 for p in me.polygons)
        stats[role] = {"verts": len(me.vertices), "tris": tris}
    # the kit as one file: Studio's 3D Importer makes a MeshPart per object, named by role
    for ob in bpy.data.objects:
        ob.location = (0, 0, 0)
    bpy.ops.export_scene.fbx(
        filepath=os.path.join(OUT, "kit.fbx"), use_selection=False, object_types={"MESH"},
        apply_scale_options="FBX_SCALE_UNITS", bake_space_transform=True, mesh_smooth_type="FACE",
        add_leaf_bones=False, path_mode="AUTO",
    )
    bpy.ops.wm.save_as_mainfile(filepath=os.path.join(OUT, "kit.blend"))
    json.dump({"roles": stats}, open(os.path.join(OUT, "kit.json"), "w"), indent=1)
    total = sum(s["tris"] for s in stats.values())
    print(f"kit: {len(stats)} role meshes, {total} triangles (largest {max(s['tris'] for s in stats.values())}) -> tools/blender/out/kit.fbx")


if __name__ == "__main__":
    main()
