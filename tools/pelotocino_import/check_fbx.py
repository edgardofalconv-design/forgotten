"""Round-trip FBX and render the imported, textured meshes in Blender (not Studio)."""
import bpy,json,hashlib,math,numpy as np
from pathlib import Path
from mathutils import Vector,Matrix
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'dist/pelotocino-importado';SRC=OUT/'fuentes-3d'
D=json.loads((ROOT/'assets/pelotocino/geometry.json').read_text());M=Matrix(((1,0,0),(0,0,-1),(0,1,0)))
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.fbx(filepath=str(SRC/'Pelotocino-Importar.fbx'))
objects={o.name:o for o in bpy.context.scene.objects if o.type=='MESH'}
assert set(objects)=={s['name']for s in D['meshes']}
max_error=0
for spec in D['meshes']:
 obj=objects[spec['name']];mesh=obj.data
 expected=np.array([M@(Vector(v)+Vector(D['anchors'][spec['anchor']]))for v in spec['vertices']])
 actual=np.array([obj.matrix_world@v.co for v in mesh.vertices])
 assert expected.shape==actual.shape,spec['name']+' vertex count'
 error=float(np.max(np.abs(expected-actual)));max_error=max(error,max_error)
 assert error<1e-5,spec['name']+' shape/coordinates: '+str(error)
 assert len(mesh.polygons)==len(spec['faces']) and len(mesh.uv_layers)==1
 mat=mesh.materials[0];bs=mat.node_tree.nodes.get('Principled BSDF')
 assert bs.inputs['Base Color'].is_linked
 image=bs.inputs['Base Color'].links[0].from_node.image
 assert image and tuple(image.size)==(2048,2048)
 # Equipment stowed with exactly the runtime mount transforms.
 if spec['group']in['pan','tracker']:
  lo=Vector(tuple(min(v[i]for v in spec['vertices'])for i in range(3)));hi=Vector(tuple(max(v[i]for v in spec['vertices'])for i in range(3)));center=(lo+hi)/2
  rot=Matrix.Rotation(.2,3,'Y')@Matrix.Rotation(-.22,3,'Z')if spec['group']=='pan'else Matrix.Identity(3)
  offset=Vector((.65,-.25,.93)if spec['group']=='pan'else(-.69,-.28,.36))
  obj.location=M@(Vector(D['anchors']['UpperTorso'])+offset+rot@center);obj.rotation_euler=(M@rot@M.inverted()).to_euler()
scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=40;scene.cycles.use_denoising=False
scene.render.resolution_x=800;scene.render.resolution_y=1000;scene.render.resolution_percentage=100
scene.world.use_nodes=True;scene.world.node_tree.nodes['Background'].inputs[0].default_value=(.18,.21,.25,1);scene.world.node_tree.nodes['Background'].inputs[1].default_value=.45
scene.view_settings.view_transform='AgX';scene.view_settings.look='AgX - Medium High Contrast';scene.view_settings.exposure=.5
floor=bpy.data.materials.new('Floor');floor.diffuse_color=(.08,.10,.13,1)
bpy.ops.mesh.primitive_plane_add(size=100,location=(0,0,.06));bpy.context.object.data.materials.append(floor)
for loc,energy,color in [((-4,6,9),950,(1,.88,.75)),((4,2,6),750,(.74,.85,1)),((0,-4,8),1000,(.8,.88,1))]:
 light=bpy.data.lights.new('Blender light','AREA');light.energy=energy;light.size=5;light.color=color
 o=bpy.data.objects.new('Blender light',light);bpy.context.collection.objects.link(o);o.location=loc;o.rotation_euler=(Vector((0,0,3))-o.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add();cam=bpy.context.object;scene.camera=cam;cam.data.type='ORTHO';cam.data.ortho_scale=7.2
previews=OUT/'previews';previews.mkdir(exist_ok=True)
for name,loc in [('frontal-fbx-blender.png',(0,12,3.1)),('trasera-fbx-blender.png',(0,-12,3.1))]:
 cam.location=loc;cam.rotation_euler=(Vector((0,0,2.85))-cam.location).to_track_quat('-Z','Y').to_euler()
 scene.render.filepath=str(previews/name);bpy.ops.render.render(write_still=True)
report={'studio_executed':False,'renderer':'Blender '+bpy.app.version_string,'mesh_count':25,
 'fbx_round_trip_geometry_equal_within_1e_5':True,'geometry_max_error':max_error,'uv_and_base_color_image_checked':True,
 'fbx_sha256':hashlib.sha256((SRC/'Pelotocino-Importar.fbx').read_bytes()).hexdigest(),
 'images':{p.name:hashlib.sha256(p.read_bytes()).hexdigest()for p in previews.glob('*.png')}}
(OUT/'fbx-validation.json').write_text(json.dumps(report,indent=2)+'\n')
print('PASS: FBX reimportado, geometría idéntica, 25 mallas, UV y texturas; Blender, no Studio.')
