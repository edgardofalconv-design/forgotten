"""Blender: three existing accessories, UV/PBR, FBX round-trip, accessory-only preview."""
from pathlib import Path
import bpy, hashlib, json, math, numpy as np
from mathutils import Matrix, Vector

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT/'dist/pelotocino-native-visual/accesorios'
source = json.loads((OUT/'accesorios-source.json').read_text())
meta = json.loads((OUT/'manifest.json').read_text())
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
M = Matrix(((1, 0, 0), (0, 0, -1), (0, 1, 0)))
material = bpy.data.materials.new('Pelotocino_Accessories'); material.use_nodes = True
shader = material.node_tree.nodes.get('Principled BSDF')
images = []
for name, key in [('Color', 'Base Color'), ('Roughness', 'Roughness'), ('Metalness', 'Metallic')]:
    img = bpy.data.images.load(str(OUT/(name+'.png')))
    if name != 'Color': img.colorspace_settings.name = 'Non-Color'
    images.append(img)
    node = material.node_tree.nodes.new('ShaderNodeTexImage'); node.image = img
    material.node_tree.links.new(node.outputs['Color'], shader.inputs[key])
shader.inputs['Specular IOR Level'].default_value = .25
expected = {}; groups = []
for index, group in enumerate(['backpack', 'pan', 'tracker']):
    specs = [s for s in source['meshes'] if s['group'] == group]
    vertices, faces, normals, uvindices = [], [], [], []
    for s in specs:
        start = len(vertices)
        vertices.extend(s['vertices']); normals.extend(s['normals'])
        faces.extend([[start+i for i in face] for face in s['faces']])
        uvindices.extend(range(s['first_face'], s['first_face']+len(s['faces'])))
    array = np.array(vertices); center = Vector((array.min(0)+array.max(0))/2)
    name = group.title(); mesh = bpy.data.meshes.new(name)
    mesh.from_pydata([M@(Vector(v)-center) for v in vertices], [], faces); mesh.update()
    uv = mesh.uv_layers.new(name='UVMap')
    for face, f in zip(mesh.polygons, uvindices):
        tx, ty = (f % meta['columns'])*meta['cell'], (f // meta['columns'])*meta['cell']
        for loop, pt in zip(face.loop_indices, [(2, 2), (meta['cell']-3, 2), (2, meta['cell']-3)]):
            uv.data[loop].uv = ((tx+pt[0]+.5)/meta['atlas_size'], 1-(ty+pt[1]+.5)/meta['atlas_size'])
        face.use_smooth = True
    mesh.normals_split_custom_set([M@Vector(normals[loop.vertex_index]) for loop in mesh.loops])
    mesh.materials.append(material)
    obj = bpy.data.objects.new(name, mesh); bpy.context.collection.objects.link(obj)
    obj.location = M@Vector(((index-1)*1.9, 1.1, 0))
    obj['AccessoryOnly'] = True
    groups.append({'name': name, 'size': (array.max(0)-array.min(0)).tolist(),
                   'center_in_anchor': list(center), 'vertices': len(vertices), 'triangles': len(faces)})
    expected[name] = np.array([obj.matrix_world@v.co for v in mesh.vertices])
# Update transforms before recording/exporting.
bpy.context.view_layer.update()
for o in bpy.context.scene.objects:
    if o.type == 'MESH': expected[o.name] = np.array([o.matrix_world@v.co for v in o.data.vertices])
bpy.ops.object.select_all(action='SELECT')
bpy.context.scene.unit_settings.system = 'NONE'
bpy.ops.export_scene.fbx(filepath=str(OUT/'Accesorios-Pelotocino.fbx'), use_selection=True,
    object_types={'MESH'}, axis_forward='-Z', axis_up='Y', apply_unit_scale=True,
    global_scale=1, mesh_smooth_type='FACE', bake_anim=False, path_mode='COPY',
    embed_textures=True, use_custom_props=True)
for img in images: img.pack()
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'Accesorios-Pelotocino.blend'))
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.fbx(filepath=str(OUT/'Accesorios-Pelotocino.fbx'))
objects = {o.name: o for o in bpy.context.scene.objects if o.type == 'MESH'}
assert set(objects) == {'Backpack', 'Pan', 'Tracker'}
max_error = 0
for name, obj in objects.items():
    actual = np.array([obj.matrix_world@v.co for v in obj.data.vertices])
    assert actual.shape == expected[name].shape
    max_error = max(max_error, float(np.max(np.abs(actual-expected[name]))))
    assert len(obj.data.uv_layers) == 1
    shader = obj.data.materials[0].node_tree.nodes.get('Principled BSDF')
    assert shader.inputs['Base Color'].is_linked
    assert tuple(shader.inputs['Base Color'].links[0].from_node.image.size) == (1024, 1024)
assert max_error < 1e-5
# The bag is viewed from the back; turn the hand-held props so their working
# faces are visible in this accessory-only render. The FBX stays unchanged.
for name in ['Pan', 'Tracker']:
    objects[name].rotation_euler.z += math.pi
scene = bpy.context.scene; scene.render.engine = 'CYCLES'; scene.cycles.samples = 24
scene.cycles.use_denoising = False
scene.render.resolution_x = 1100; scene.render.resolution_y = 650; scene.render.resolution_percentage = 100
scene.world.use_nodes = True
scene.world.node_tree.nodes['Background'].inputs[0].default_value = (.15, .18, .23, 1)
scene.world.node_tree.nodes['Background'].inputs[1].default_value = .5
scene.view_settings.view_transform = 'AgX'; scene.view_settings.exposure = .7
for loc, energy in [((-3, -4, 6), 650), ((3, 2, 4), 800)]:
    light = bpy.data.lights.new('Preview', 'AREA'); light.energy = energy; light.size = 4
    obj = bpy.data.objects.new('Preview', light); bpy.context.collection.objects.link(obj)
    obj.location = loc; obj.rotation_euler = (Vector((0, 0, 1))-obj.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add(); cam = bpy.context.object; scene.camera = cam
cam.data.type = 'ORTHO'; cam.data.ortho_scale = 6.4
cam.location = (2, -8, 3.2); cam.rotation_euler = (Vector((0, 0, 1.1))-cam.location).to_track_quat('-Z','Y').to_euler()
scene.render.filepath = str(OUT/'accesorios-solo-blender.png'); bpy.ops.render.render(write_still=True)
meta.update({'meshes': groups, 'geometry_max_error_fbx_round_trip': max_error,
             'renderer': 'Blender '+bpy.app.version_string, 'preview_subject': 'Accessories only; no native avatar available here',
             'files': {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in OUT.iterdir()
                       if p.is_file() and p.name != 'manifest.json' and p.suffix != '.blend1'}})
(OUT/'manifest.json').write_text(json.dumps(meta, indent=2)+'\n')
print('PASS: 3 accessory meshes + UV/PBR + source blend; FBX round-trip max error', max_error)
