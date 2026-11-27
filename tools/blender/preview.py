"""
PREVIEWS OF THE MESH KIT ON THE GAME'S OWN MODELS (Blender, Cycles on the CPU, headless).

    tools/blender/run.sh preview.py [monsters|weapons|outfits|kit|all]

Reads tools/blender/out/layout.json (tools/blender/dump_layout.luau: every monster, weapon and
outfit preset as the game builds it, with each part's role) and lays the kit's mesh over every
part that has a role, exactly as Hunter/MeshLibrary.dress does in the game; parts without one
stay boxes and balls. Renders a contact sheet per group into tools/blender/out/:
monsters.png, weapons.png, outfits.png, kit.png (every role mesh on its own).
"""

import bpy, json, math, os, sys
from mathutils import Matrix, Vector

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import kit  # the role meshes

OUT = kit.OUT
TO_BLENDER = kit.TO_BLENDER

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:  # labels are optional
    Image = None


# ── materials ──────────────────────────────────────────────────────────────────────
_mats = {}


def material(rgb, kind, transparency=0.0):
    key = (tuple(rgb), kind, round(transparency, 2))
    if key in _mats:
        return _mats[key]
    m = bpy.data.materials.new(f"m{len(_mats)}")
    m.use_nodes = True
    nt = m.node_tree
    bsdf = nt.nodes.get("Principled BSDF")
    col = (rgb[0] / 255, rgb[1] / 255, rgb[2] / 255, 1)
    # sRGB -> linear, roughly
    lin = tuple(c ** 2.2 for c in col[:3]) + (1,)
    bsdf.inputs["Base Color"].default_value = lin
    rough, metal = 0.55, 0.0
    if kind in ("Metal", "DiamondPlate", "CorrodedMetal"):
        rough, metal = 0.32, 0.85
    elif kind in ("Glass", "Ice", "ForceField"):
        rough = 0.08
        bsdf.inputs["Transmission Weight"].default_value = 0.6
    elif kind in ("Fabric", "Wood", "Slate", "Cobblestone", "Concrete", "Leather"):
        rough = 0.8
    elif kind == "SmoothPlastic":
        rough = 0.45
    bsdf.inputs["Roughness"].default_value = rough
    bsdf.inputs["Metallic"].default_value = metal
    if kind == "Neon":
        bsdf.inputs["Emission Color"].default_value = lin
        bsdf.inputs["Emission Strength"].default_value = 4.0
    if transparency > 0.01:
        bsdf.inputs["Alpha"].default_value = max(0.05, 1 - transparency)
        try:
            m.surface_render_method = "BLENDED"
        except Exception:
            pass
    _mats[key] = m
    return m


# ── meshes in Roblox space (unit cube), made once ──────────────────────────────────
_meshes = {}


def unit_mesh(key):
    if key in _meshes:
        return _meshes[key]
    if key in kit.ROLES:
        me = kit.build_mesh(key)
    else:
        me = bpy.data.meshes.new(key)
        if key == "Ball":
            v, f = kit.superq(1.0, 1.0, 20, 12)
        elif key == "Cylinder":
            v, f = kit.lathe([(-0.5, 0.5), (0.5, 0.5)], 16, "x")
        elif key == "Wedge":
            v = [[-0.5, -0.5, -0.5], [0.5, -0.5, -0.5], [0.5, -0.5, 0.5], [-0.5, -0.5, 0.5], [0.5, 0.5, 0.5], [-0.5, 0.5, 0.5]]
            f = [[0, 1, 2, 3], [3, 2, 4, 5], [0, 5, 4, 1], [0, 3, 5], [1, 4, 2]]
        elif key == "Head":
            v, f = kit.superq(0.35, 0.75, 20, 12)
        else:
            v = [[x, y, z] for x in (-0.5, 0.5) for y in (-0.5, 0.5) for z in (-0.5, 0.5)]
            f = [[0, 1, 3, 2], [4, 6, 7, 5], [0, 4, 5, 1], [2, 3, 7, 6], [0, 2, 6, 4], [1, 5, 7, 3]]
        me.from_pydata([tuple(p) for p in v], [], [tuple(x) for x in f])
        me.update()
        import bmesh
        bm = bmesh.new()
        bm.from_mesh(me)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        bm.to_mesh(me)
        bm.free()
        for p in me.polygons:
            p.use_smooth = key in ("Ball", "Head")
    _meshes[key] = me
    return me


def cf_matrix(c):
    x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = c
    return Matrix(((r00, r01, r02, x), (r10, r11, r12, y), (r20, r21, r22, z), (0, 0, 0, 1)))


def corners(part):
    m = cf_matrix(part["cf"])
    sx, sy, sz = part["size"]
    out = []
    for a in (-0.5, 0.5):
        for b in (-0.5, 0.5):
            for c in (-0.5, 0.5):
                out.append(m @ Vector((a * sx, b * sy, c * sz)))
    return out


def place(model, cell_center, cell_size, turn_deg, use_kit=True, extra_scale=1.0):
    parts = [p for p in model["parts"] if p.get("transparency", 0) < 0.99]
    pts = [c for p in parts for c in corners(p)]
    lo = Vector((min(p.x for p in pts), min(p.y for p in pts), min(p.z for p in pts)))
    hi = Vector((max(p.x for p in pts), max(p.y for p in pts), max(p.z for p in pts)))
    center = (lo + hi) / 2
    ext = max(hi.x - lo.x, hi.y - lo.y, hi.z - lo.z, 1e-3)
    s = cell_size / ext * extra_scale
    base = (Matrix.Translation(cell_center) @ Matrix.Rotation(math.radians(14), 4, "X") @ Matrix.Rotation(math.radians(turn_deg), 4, "Z")
            @ Matrix.Scale(s, 4) @ TO_BLENDER @ Matrix.Translation(-center))
    coll = bpy.context.scene.collection
    for p in parts:
        role = p.get("role") if use_kit else None
        key = role or ("Head" if p["name"] == "Head" and "gait" not in model else p.get("shape", "Block"))
        me = unit_mesh(key)
        ob = bpy.data.objects.new(p["name"], me)
        sx, sy, sz = p["size"]
        ob.matrix_world = base @ cf_matrix(p["cf"]) @ Matrix.Diagonal((sx, sy, sz, 1))
        ob.data = me
        ob.material_slots and None
        mat = material(p["color"], p["material"], p.get("transparency", 0))
        ob.active_material = mat
        if not ob.material_slots:
            ob.data.materials.append(mat)
        ob.material_slots[0].link = "OBJECT"
        ob.material_slots[0].material = mat
        coll.objects.link(ob)


def scene_setup(width, height, ortho_scale, cam_target):
    sc = bpy.context.scene
    sc.render.engine = "CYCLES"
    sc.cycles.device = "CPU"
    sc.cycles.samples = 24
    try:
        sc.cycles.use_denoising = True
        sc.cycles.denoiser = "OPENIMAGEDENOISE"
    except Exception:
        pass
    sc.render.resolution_x = width
    sc.render.resolution_y = height
    sc.render.film_transparent = False
    world = bpy.data.worlds.new("w")
    world.use_nodes = True
    world.node_tree.nodes["Background"].inputs[0].default_value = (0.035, 0.04, 0.06, 1)
    world.node_tree.nodes["Background"].inputs[1].default_value = 1.0
    sc.world = world
    cam = bpy.data.objects.new("cam", bpy.data.cameras.new("cam"))
    cam.data.type = "ORTHO"
    cam.data.ortho_scale = ortho_scale
    # straight in front (the models face Blender +Y; each is tipped a little to show its top)
    cam.location = cam_target + Vector((0, 60, 0))
    direction = cam_target - cam.location
    cam.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
    sc.collection.objects.link(cam)
    sc.camera = cam
    for i, (rot, energy) in enumerate((((50, 10, 150), 3.2), ((60, 0, -40), 1.2))):
        l = bpy.data.objects.new(f"sun{i}", bpy.data.lights.new(f"sun{i}", "SUN"))
        l.data.energy = energy
        l.rotation_euler = [math.radians(a) for a in rot]
        sc.collection.objects.link(l)
    return sc


def sheet(name, items, cols, cell, turn, title, label_of, use_kit=True, width=None):
    kit.reset()
    _mats.clear()
    _meshes.clear()
    rows = math.ceil(len(items) / cols)
    W = width or cols * 220
    H = int(W * rows / cols)
    world_w = cols * cell
    for i, it in enumerate(items):
        c, r = i % cols, i // cols
        # (the camera looks back along -Y, so screen-left is +X: columns run from +X to -X)
        center = Vector((world_w / 2 - (c + 0.5) * cell, 0, -(r + 0.5) * cell + rows * cell / 2 - cell * 0.06))
        place(it, center, cell * 0.78, turn, use_kit)
    sc = scene_setup(W, H, world_w, Vector((0, 0, 0)))
    # (orthographic: the camera's view is world_w wide; its height follows the aspect)
    path = os.path.join(OUT, name + ".png")
    sc.render.filepath = path
    bpy.ops.render.render(write_still=True)
    if Image:
        img = Image.open(path).convert("RGB")
        top = 34
        canvas = Image.new("RGB", (img.width, img.height + top), (8, 10, 16))
        canvas.paste(img, (0, top))
        d = ImageDraw.Draw(canvas)
        try:
            font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 15)
            small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 12)
        except Exception:
            font = small = ImageFont.load_default()
        d.text((10, 8), title, fill=(255, 150, 110), font=font)
        cw, ch = img.width / cols, img.height / rows
        for i, it in enumerate(items):
            c, r = i % cols, i // cols
            d.text((c * cw + 6, top + r * ch + 4), label_of(it), fill=(220, 220, 230), font=small)
        canvas.save(path)
    print("wrote", path)


def kit_items(layout):
    # each role at the proportions of a part that really plays it (a wing is long and thin)
    sizes = {}
    for group in ("monsters", "weapons", "rigs"):
        for m in layout[group]:
            for p in m["parts"]:
                r = p.get("role")
                if r and r not in sizes:
                    sizes[r] = p["size"]
    items = []
    for role in kit.ROLES:
        size = sizes.get(role, [1, 1, 1])
        items.append({"role": role, "parts": [{"name": role, "role": role, "size": size, "cf": [0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1], "color": [170, 176, 190], "material": "SmoothPlastic", "shape": "Block"}]})
    return items


def main():
    what = sys.argv[sys.argv.index("--") + 1] if "--" in sys.argv else (sys.argv[1] if len(sys.argv) > 1 else "all")
    layout = json.load(open(os.path.join(OUT, "layout.json")))
    rank = "EDCBAS"
    if what in ("monsters", "all"):
        sheet("monsters", layout["monsters"], 6, 10.0, 35, "BITLEVELING · THE MONSTERS WITH THE BLENDER MESH KIT (Cycles)",
              lambda m: f"{rank[m['rank'] - 1]} · {m['name']}", width=1500)
    if what in ("weapons", "all"):
        sheet("weapons", layout["weapons"], 10, 10.0, 80, "BITLEVELING · EVERY WEAPON WITH THE MESH KIT (side view)",
              lambda w: w["name"][:24], width=1800)
    if what in ("outfits", "all"):
        sheet("outfits", layout["rigs"], 8, 10.0, 25, "BITLEVELING · OUTFIT PRESETS WITH THE MESH KIT (capes, pauldrons, cuirass, helms...)",
              lambda r: r["name"], width=1600)
    if what in ("kit", "all"):
        sheet("kit", kit_items(layout), 9, 10.0, 35, "BITLEVELING · THE MESH KIT: ONE MESH PER ROLE (each one stretches to the part that plays it)",
              lambda it: it["role"], width=1620)


if __name__ == "__main__":
    main()
