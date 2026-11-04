"""Render de geometría exportada del constructor; no representa una captura de Studio."""
import bpy,json,math
from pathlib import Path
from mathutils import Matrix,Vector
ROOT=Path(__file__).resolve().parents[1]
scene=json.loads((ROOT/'dist/preview-scene.json').read_text())
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
world=bpy.context.scene.world;world.use_nodes=True
world.node_tree.nodes['Background'].inputs[0].default_value=(.055,.075,.115,1)
world.node_tree.nodes['Background'].inputs[1].default_value=.18
M=Matrix(((1,0,0),(0,0,-1),(0,1,0)))
def pos(v):return M@Vector(v)
materials={}
def material(p):
 c=p['color'];kind=p['material'];alpha=p['alpha']
 key=tuple(c)+(kind,round(alpha,2))
 if key in materials:return materials[key]
 mat=bpy.data.materials.new(kind);mat.diffuse_color=(*c,1);mat.use_nodes=True
 nodes=mat.node_tree.nodes;links=mat.node_tree.links;bs=nodes.get('Principled BSDF')
 # sRGB values from Roblox converted approximately to linear.
 bs.inputs['Base Color'].default_value=(*(max(v,.001)**2.2 for v in c),1)
 bs.inputs['Roughness'].default_value=.72
 if kind=='Metal':bs.inputs['Metallic'].default_value=.72;bs.inputs['Roughness'].default_value=.34
 texture={'WoodPlanks':'oak','Wood':'oak','Cobblestone':'limestone','Slate':'limestone','Fabric':'woven','Metal':'aged_brass'}.get(kind)
 if texture:
  coords=nodes.new('ShaderNodeTexCoord')
  tex=nodes.new('ShaderNodeTexImage');tex.image=bpy.data.images.load(str(ROOT/'assets/textures'/f'{texture}_color.png'),check_existing=True);tex.projection='BOX';tex.projection_blend=.18
  links.new(coords.outputs['Generated'],tex.inputs['Vector'])
  mix=nodes.new('ShaderNodeMixRGB');mix.blend_type='MULTIPLY';mix.inputs[0].default_value=.72;mix.inputs[1].default_value=(*(max(v,.001)**2.2*2 for v in c),1)
  links.new(tex.outputs['Color'],mix.inputs[2]);links.new(mix.outputs[0],bs.inputs['Base Color'])
  bumptex=nodes.new('ShaderNodeTexImage');bumptex.image=bpy.data.images.load(str(ROOT/'assets/textures'/f'{texture}_normal.png'),check_existing=True);bumptex.image.colorspace_settings.name='Non-Color';bumptex.projection='BOX'
  links.new(coords.outputs['Generated'],bumptex.inputs['Vector'])
  roughtex=nodes.new('ShaderNodeTexImage');roughtex.image=bpy.data.images.load(str(ROOT/'assets/textures'/f'{texture}_roughness.png'),check_existing=True);roughtex.image.colorspace_settings.name='Non-Color';roughtex.projection='BOX'
  links.new(coords.outputs['Generated'],roughtex.inputs['Vector']);links.new(roughtex.outputs['Color'],bs.inputs['Roughness'])
  # Tangent maps are supplied for Roblox; bump for preview box mapping.
  bump=nodes.new('ShaderNodeBump');bump.inputs['Strength'].default_value=.25;bump.inputs['Distance'].default_value=.05
  links.new(tex.outputs['Color'],bump.inputs['Height']);links.new(bump.outputs['Normal'],bs.inputs['Normal'])
 if kind=='Neon':bs.inputs['Emission Color'].default_value=(*c,1);bs.inputs['Emission Strength'].default_value=2.5
 if kind=='Glass':bs.inputs['Transmission Weight'].default_value=.45;bs.inputs['Roughness'].default_value=.18
 materials[key]=mat;return mat
# Shared templates, baked sizes and cached meshes avoid costly operator updates.
mesh_cache={}
bpy.ops.mesh.primitive_cube_add(size=1);cube=bpy.context.object
bpy.ops.mesh.primitive_uv_sphere_add(segments=12,ring_count=8,radius=.5);sphere=bpy.context.object
bpy.ops.mesh.primitive_cylinder_add(vertices=16,radius=.5,depth=1);cylinder=bpy.context.object
base={}
for shape,template in [('Block',cube),('Ball',sphere),('Cylinder',cylinder)]:
 verts=[v.co.copy() for v in template.data.vertices]
 if shape=='Cylinder':verts=[Vector((v.z,v.y,-v.x)) for v in verts]
 base[shape]=(verts,[tuple(f.vertices) for f in template.data.polygons])
for template in [cube,sphere,cylinder]:bpy.data.objects.remove(template,do_unlink=True)
for p in scene['parts']:
 if p['alpha']>.75 or p['name']=='Base':continue
 mat=material(p);shape=p['shape'] if p['shape'] in base else 'Block'
 key=(shape,tuple(p['size']),mat.name)
 mesh=mesh_cache.get(key)
 if mesh is None:
  vs,fs=base[shape]
  mesh=bpy.data.meshes.new(p['name'])
  mesh.from_pydata([tuple(M@Vector((v.x*p['size'][0],v.y*p['size'][1],v.z*p['size'][2]))) for v in vs],[],fs)
  mesh.materials.append(mat);mesh_cache[key]=mesh
 obj=bpy.data.objects.new(p['name'],mesh);bpy.context.collection.objects.link(obj)
 R=Matrix([p['rot'][i:i+3] for i in (0,3,6)])
 obj.matrix_world=(M@R@M.inverted()).to_4x4();obj.location=pos(p['pos'])
 if min(p['size'])>.25 and shape=='Block':
  bevel=obj.modifiers.new('Cantos artesanales','BEVEL');bevel.width=min(.09,min(p['size'])*.08);bevel.segments=2
  obj.modifiers.new('Normales','WEIGHTED_NORMAL')
print('Geometry ready',flush=True)
for light in scene['lights']:
 data=bpy.data.lights.new('Farol','POINT');data.color=light['color'];data.energy=light['brightness']*850;data.shadow_soft_size=.7
 ob=bpy.data.objects.new('Farol',data);bpy.context.collection.objects.link(ob);ob.location=pos(light['pos'])
def area(name,location,target,energy,color,size):
 data=bpy.data.lights.new(name,'AREA');data.energy=energy;data.color=color;data.shape='DISK';data.size=size
 ob=bpy.data.objects.new(name,data);bpy.context.collection.objects.link(ob);ob.location=pos(location);ob.rotation_euler=(pos(target)-ob.location).to_track_quat('-Z','Y').to_euler()
area('Relleno suave',(0,25,-12),(0,2,12),6500,(.65,.73,.9),25)
area('Rebote fuego',(22,8,29),(20,3,10),2200,(1,.53,.24),7)
area('Luna entrada',(0,16,-34),(0,9,10),3300,(.43,.61,1),18)
for t in scene['texts']:
 if not t['text']:continue
 data=bpy.data.curves.new('Inscripcion','FONT');data.body=t['text'];data.align_x='CENTER';data.align_y='CENTER';data.size=min(t['size'][0]/max(3,max(map(len,t['text'].split('\n')))) *1.4,t['size'][1]/3)
 data.extrude=.002
 ob=bpy.data.objects.new('Inscripcion',data);bpy.context.collection.objects.link(ob)
 direction=Vector((0,0,1 if t['face']=='Back' else -1))
 R=Matrix([t['rot'][i:i+3] for i in (0,3,6)])
 normal=M@R@direction
 ob.location=pos(t['pos'])+normal*(t['size'][2]/2+.025)
 ob.rotation_euler=normal.to_track_quat('Z','Y').to_euler()
 mat=bpy.data.materials.get('Letras')
 if not mat:mat=bpy.data.materials.new('Letras');mat.diffuse_color=(.8,.7,.48,1)
 data.materials.append(mat)
sc=bpy.context.scene;sc.render.engine='CYCLES';sc.cycles.samples=48;sc.cycles.use_denoising=False
sc.render.resolution_x=1280;sc.render.resolution_y=820;sc.render.resolution_percentage=100
sc.view_settings.view_transform='AgX'
sc.view_settings.look='AgX - Medium High Contrast';sc.view_settings.exposure=1.1
bpy.ops.object.camera_add();camera=bpy.context.object;sc.camera=camera;camera.data.lens=23
out=ROOT/'dist/previews';out.mkdir(exist_ok=True)
views=[('01-sala',(2,10,-29),(3,11,18),22),('02-altillo',(-15,28,-12),(7,7,19),23),('03-hogar',(4,8,8),(24,7,28),29)]
bpy.ops.wm.save_as_mainfile(filepath=str(out/'Forgotten-preview.blend'))
for name,location,target,lens in views:
 camera.location=pos(location);camera.rotation_euler=(pos(target)-camera.location).to_track_quat('-Z','Y').to_euler();camera.data.lens=lens
 sc.render.filepath=str(out/(name+'.png'));bpy.ops.render.render(write_still=True)
bpy.ops.wm.save_as_mainfile(filepath=str(out/'Forgotten-preview.blend'))
