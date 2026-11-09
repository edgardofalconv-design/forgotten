"""Blender review of exactly the generated mesh data. Not a Studio test."""
import bpy,json,math,hashlib
from mathutils import Vector,Matrix
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'dist/pelotocino/previews';OUT.mkdir(parents=True,exist_ok=True)
DATA=json.loads((ROOT/'assets/pelotocino/geometry.json').read_text());M=Matrix(((1,0,0),(0,0,-1),(0,1,0)))
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
materials={};objects=[]
for spec in DATA['meshes']:
 mesh=bpy.data.meshes.new(spec['name']);mesh.from_pydata([M@Vector(v) for v in spec['vertices']],[],spec['faces']);mesh.update()
 col=mesh.color_attributes.new(name='Color',type='FLOAT_COLOR',domain='POINT')
 for i,c in enumerate(spec['colors']):col.data[i].color=tuple((v/255)**2.2 for v in c)+(1,)
 uv=mesh.uv_layers.new(name='UVMap')
 for loop in mesh.loops:
  pt=spec['vertices'][loop.vertex_index];uv.data[loop.index].uv=(.5+pt[0]*.32,.5+pt[1]*.32)
 key=spec['material']+('_leather' if spec['group']=='backpack' else '_hair' if spec['group'] in ['hair','tuft'] else '')
 mat=materials.get(key)
 if not mat:
  mat=bpy.data.materials.new(key);mat.use_nodes=True;n=mat.node_tree.nodes;bs=n.get('Principled BSDF');v=n.new('ShaderNodeVertexColor');v.layer_name='Color';mat.node_tree.links.new(v.outputs['Color'],bs.inputs['Base Color'])
  bs.inputs['Roughness'].default_value=.8 if spec['material']=='Fabric' else .35
  if spec['material']=='Metal':bs.inputs['Metallic'].default_value=.6
  if spec['material']=='Neon':mat.node_tree.links.new(v.outputs['Color'],bs.inputs['Emission Color']);bs.inputs['Emission Strength'].default_value=.6
  if spec['material']=='Fabric':
   tex=n.new('ShaderNodeTexImage');tex.image=bpy.data.images.load(str(ROOT/'assets/pelotocino/textures'/('leather.png' if spec['group']=='backpack' else 'weave.png')),check_existing=True)
   mix=n.new('ShaderNodeMixRGB');mix.blend_type='MULTIPLY';mix.inputs[0].default_value=1;mat.node_tree.links.new(v.outputs['Color'],mix.inputs[1]);mat.node_tree.links.new(tex.outputs['Color'],mix.inputs[2]);mat.node_tree.links.new(mix.outputs[0],bs.inputs['Base Color'])
  bs.inputs['Specular IOR Level'].default_value=.25
  if spec['group'] in ['hair','tuft']:bs.inputs['Roughness'].default_value=.65
  materials[key]=mat
 mesh.materials.append(mat)
 obj=bpy.data.objects.new(spec['name'],mesh);bpy.context.collection.objects.link(obj)
 obj.location=M@Vector(DATA['anchors'][spec['anchor']]);obj['R15Anchor']=spec['anchor'];obj['Group']=spec['group']
 for p in mesh.polygons:p.use_smooth=True
 if spec['group']=='pan':obj.location=M@Vector(DATA['anchors']['UpperTorso'])+M@Vector([.65,-.25,.93]);r=Matrix.Rotation(.2,3,'Y')@Matrix.Rotation(-.22,3,'Z');obj.rotation_euler=(M@r@M.inverted()).to_euler()
 if spec['group']=='tracker':obj.location=M@Vector(DATA['anchors']['UpperTorso'])+M@Vector([-.69,-.28,.36])
 objects.append(obj)
# Export source meshes with vertex colors; Studio may require uploaded textures/materials.
bpy.ops.object.select_all(action='DESELECT')
for o in objects:o.select_set(True)
bpy.context.view_layer.objects.active=objects[0]
bpy.ops.export_scene.fbx(filepath=str(ROOT/'dist/pelotocino/Pelotocino-Meshes.fbx'),use_selection=True,object_types={'MESH'},apply_unit_scale=True,axis_forward='-Z',axis_up='Y',mesh_smooth_type='FACE',bake_anim=False,path_mode='COPY',embed_textures=True)
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'dist/pelotocino/Pelotocino.blend'))
scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=64;scene.cycles.use_denoising=False
scene.render.resolution_x=800;scene.render.resolution_y=1000;scene.render.resolution_percentage=100
scene.world.use_nodes=True;scene.world.node_tree.nodes['Background'].inputs[0].default_value=(.18,.21,.25,1);scene.world.node_tree.nodes['Background'].inputs[1].default_value=.45
scene.view_settings.view_transform='AgX';scene.view_settings.look='AgX - Medium High Contrast';scene.view_settings.exposure=.5
mat=bpy.data.materials.new('Ground');mat.diffuse_color=(.08,.10,.13,1)
bpy.ops.mesh.primitive_plane_add(size=100,location=(0,0,.06));ground=bpy.context.object;ground.data.materials.append(mat)
def area(loc,energy,size,color):
 d=bpy.data.lights.new('Blender light','AREA');d.energy=energy;d.size=size;d.color=color
 o=bpy.data.objects.new('Blender light',d);bpy.context.collection.objects.link(o);o.location=loc;o.rotation_euler=(Vector((0,0,3))-o.location).to_track_quat('-Z','Y').to_euler()
area((-4,6,9),950,5,(1,.88,.75));area((4,2,6),750,4,(.74,.85,1));area((0,-4,8),1000,4,(.8,.88,1))
bpy.ops.object.camera_add();camera=bpy.context.object;scene.camera=camera;camera.data.type='ORTHO';camera.data.ortho_scale=7.2
for filename,location in [('01-frontal.png',(0,12,3.1)),('02-trasera.png',(0,-12,3.1)),('03-izquierda.png',(-12,0,3.1)),('04-derecha.png',(12,0,3.1)),('05-perspectiva.png',(6,12,6))]:
 camera.location=location;camera.rotation_euler=(Vector((0,0,2.85))-camera.location).to_track_quat('-Z','Y').to_euler()
 scene.render.filepath=str(OUT/filename);bpy.ops.render.render(write_still=True)
 print('Render Blender:',filename,flush=True)
(OUT/'manifest.json').write_text(json.dumps({'renderer':'Blender '+bpy.app.version_string,'studio_executed':False,'geometry_sha256':hashlib.sha256((ROOT/'assets/pelotocino/geometry.json').read_bytes()).hexdigest(),'images':{p.name:hashlib.sha256(p.read_bytes()).hexdigest()for p in OUT.glob('*.png')}},indent=2)+'\n')
