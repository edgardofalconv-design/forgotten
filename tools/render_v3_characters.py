"""Render the authored V3 geometry in Blender. This is NOT a Studio screenshot."""
import bpy,json,math,hashlib
from datetime import datetime,timezone
from pathlib import Path
from mathutils import Vector,Matrix
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'dist/v3/previews';OUT.mkdir(parents=True,exist_ok=True)
DATA=json.loads((ROOT/'assets/v3/character-geometry.json').read_text())
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
M=Matrix(((1,0,0),(0,0,-1),(0,1,0)))
PALETTE={'pelotocino':([237,235,226],[18,21,25],[25,30,32]),'yellowguy':([245,205,48],[13,105,172],[75,151,75]),'junkbot':([157,134,51],[66,72,64],[63,69,63]),'deathspeaker':([33,65,75],[33,65,75],[33,65,75]),'guest666':([12,13,17],[13,15,19],[14,16,20]),'tubers93':([221,219,208],[16,18,22],[24,28,31])}
ANCHORS={'Torso':[0,3.4,0],'Head':[0,4.9,0],'LeftArm':[-1.5,3.4,0],'RightArm':[1.5,3.4,0],'LeftLeg':[-.5,1.4,0],'RightLeg':[.5,1.4,0]}
materials={};characters={};display_labels=[]
def material(color,kind='SmoothPlastic'):
 key=tuple(color)+(kind,)
 if key in materials:return materials[key]
 mat=bpy.data.materials.new(str(key));mat.use_nodes=True;bs=mat.node_tree.nodes.get('Principled BSDF')
 rgb=tuple((v/255)**2.2 for v in color);bs.inputs['Base Color'].default_value=(*rgb,1)
 bs.inputs['Roughness'].default_value=.45 if kind=='SmoothPlastic' else .65
 if kind=='Metal':bs.inputs['Metallic'].default_value=.5;bs.inputs['Roughness'].default_value=.4
 if kind=='Neon':bs.inputs['Emission Color'].default_value=(*rgb,1);bs.inputs['Emission Strength'].default_value=.7
 materials[key]=mat;return mat
def register(o,name,anchor,mat,offset):
 o.name=name;o.data.materials.append(mat);o.location+=M@Vector(ANCHORS[anchor]);o.location.x+=offset
 o['Anchor']=anchor;return o
def primitive(spec,offset):
 kind=spec['kind'];rot=spec.get('rotation',[0,0,0]);pos=spec.get('position',[0,0,0]);size=spec.get('size',[1,1,1])
 if kind=='Mesh':
  mesh=bpy.data.meshes.new(spec['name']);mesh.from_pydata([tuple(M@Vector(v)) for v in spec['vertices']],[],spec['faces']);mesh.update()
  o=bpy.data.objects.new(spec['name'],mesh);bpy.context.collection.objects.link(o)
 elif kind=='Segment':
  a,b=Vector(spec['start']),Vector(spec['end']);delta=b-a
  bpy.ops.mesh.primitive_cylinder_add(vertices=10,radius=spec['radius'],depth=delta.length,location=M@((a+b)/2))
  o=bpy.context.object;o.rotation_euler=(M@delta).to_track_quat('Z','Y').to_euler()
 else:
  if kind=='Sphere':
   bpy.ops.mesh.primitive_uv_sphere_add(segments=20,ring_count=12,radius=.5);o=bpy.context.object
   o.scale=(size[0],size[2],size[1]);bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
   for p in o.data.polygons:p.use_smooth=True
  elif kind=='Cylinder':
   bpy.ops.mesh.primitive_cylinder_add(vertices=20,radius=.5,depth=1);o=bpy.context.object
   # Data uses cylinder length in its second dimension, then rotates the X axis.
   for v in o.data.vertices:v.co=Vector((v.co.z*size[1],v.co.x*size[0],v.co.y*size[2]))
   for v in o.data.vertices:v.co=M@v.co
   for p in o.data.polygons:p.use_smooth=True
  elif kind=='Wedge':
   verts=[[-.5,-.5,-.5],[.5,-.5,-.5],[-.5,-.5,.5],[.5,-.5,.5],[-.5,.5,.5],[.5,.5,.5]]
   mesh=bpy.data.meshes.new(spec['name']);mesh.from_pydata([M@Vector([v[i]*size[i] for i in range(3)]) for v in verts],[],[[0,1,3,2],[2,3,5,4],[0,4,5,1],[0,2,4],[1,5,3]])
   o=bpy.data.objects.new(spec['name'],mesh);bpy.context.collection.objects.link(o)
  else:
   bpy.ops.mesh.primitive_cube_add(size=1);o=bpy.context.object;o.scale=(size[0],size[2],size[1]);bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
   if kind=='RoundedBlock':
    bevel=o.modifiers.new('Authored rounded contour','BEVEL');bevel.width=spec.get('radius',.08);bevel.segments=4;o.modifiers.new('Weighted normals','WEIGHTED_NORMAL')
  r=Matrix.Rotation(math.radians(rot[0]),3,'X')@Matrix.Rotation(math.radians(rot[1]),3,'Y')@Matrix.Rotation(math.radians(rot[2]),3,'Z')
  o.rotation_euler=(M@r@M.inverted()).to_euler();o.location=M@Vector(pos)
 return register(o,spec['name'],spec['anchor'],material(spec['color'],spec.get('material','SmoothPlastic')),offset)
def text(body,position,size=.25,color=(224,219,201)):
 curve=bpy.data.curves.new('Label','FONT');curve.body=body;curve.align_x='CENTER';curve.align_y='CENTER';curve.size=size
 obj=bpy.data.objects.new('Label',curve);bpy.context.collection.objects.link(obj);obj.location=M@Vector(position);obj.rotation_euler=Vector((0,1,0)).to_track_quat('Z','Y').to_euler();curve.materials.append(material(list(color)));return obj
def face(id,offset):
 # Existing original artwork is used only in this technical render.
 mat=bpy.data.materials.new('Classic face');mat.use_nodes=True
 nodes=mat.node_tree.nodes;links=mat.node_tree.links;bs=nodes.get('Principled BSDF')
 tex=nodes.new('ShaderNodeTexImage');tex.image=bpy.data.images.load(str(ROOT/'assets/characters/bacon_face.png'),check_existing=True)
 links.new(tex.outputs['Color'],bs.inputs['Base Color']);links.new(tex.outputs['Alpha'],bs.inputs['Alpha']);mat.surface_render_method='DITHERED'
 bpy.ops.mesh.primitive_plane_add(size=1,location=(offset,.636,4.9),rotation=(math.pi/2,0,0));o=bpy.context.object;o.scale=(1.3,1.25,1);o.data.materials.append(mat);return o
for index,(id,specs) in enumerate(DATA.items()):
 offset=(2.5-index)*6;objects=[];skin,torso,legs=PALETTE[id]
 if id not in ['junkbot','deathspeaker']:
  for anchor,size in [('Torso',[2,2,1]),('LeftArm',[1,2,1]),('RightArm',[1,2,1]),('LeftLeg',[1,2,1]),('RightLeg',[1,2,1])]:
   if any(s.get('body') and s['anchor']==anchor for s in specs):continue
   color=torso if anchor=='Torso' else legs if 'Leg' in anchor else skin
   objects.append(primitive(dict(name=anchor,anchor=anchor,kind='Block',size=size,position=[0,0,0],color=color),offset))
  head=primitive(dict(name='Native head approximation',anchor='Head',kind='Block',size=[1.3,1.25,1.25],position=[0,0,0],color=skin),offset)
  bevel=head.modifiers.new('Native head contour','BEVEL');bevel.width=.2;bevel.segments=5;head.modifiers.new('Head normals','WEIGHTED_NORMAL');objects.append(head)
  if id!='guest666':objects.append(face(id,offset))
  else:
   for side in [-1,1]:objects.append(primitive(dict(name='Red eye',anchor='Head',kind='Sphere',size=[.09,.18,.02],position=[side*.23,.08,-.637],color=[217,20,34],material='Neon'),offset))
 if id in ['pelotocino','tubers93']:
  objects.append(primitive(dict(name='Blue shirt',anchor='Torso',kind='Block',size=[.8,1.92,.015],position=[0,0,-.51],color=[14,102,157]),offset))
 for spec in specs:
  if spec.get('visibility'):continue
  objects.append(primitive(spec,offset))
  if spec.get('label'):
   p=Vector(ANCHORS[spec['anchor']])+Vector(spec['position']);p.x+=offset;p.z-=spec['size'][2]/2+.012
   objects.append(text(spec['label'],list(p),.18))
 if id=='guest666':objects.append(text('ROBLOX',[offset,3.7,-.512],.31,(227,222,209)))
 characters[id]=objects
 display_labels.append(text({'pelotocino':'PELOTOCINO','yellowguy':'YELLOW GUY','junkbot':'JUNKBOT*','deathspeaker':'DEATHSPEAKER*','guest666':'GUEST 666','tubers93':'TUBERS93'}[id],[offset,7.35,0],.34))

scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=16;scene.cycles.use_denoising=False
scene.render.resolution_x=1900;scene.render.resolution_y=620;scene.render.resolution_percentage=100
scene.world.use_nodes=True;scene.world.node_tree.nodes['Background'].inputs[0].default_value=(.22,.25,.32,1);scene.world.node_tree.nodes['Background'].inputs[1].default_value=.5
scene.view_settings.view_transform='AgX';scene.view_settings.look='AgX - Medium High Contrast';scene.view_settings.exposure=.8
bpy.ops.mesh.primitive_plane_add(size=200);bpy.context.object.data.materials.append(material([61,71,82]))
def area(location,energy,size,color):
 d=bpy.data.lights.new('Studio light','AREA');d.energy=energy;d.size=size;d.color=color
 o=bpy.data.objects.new('Studio light',d);bpy.context.collection.objects.link(o);o.location=location;o.rotation_euler=(Vector((0,0,3))-o.location).to_track_quat('-Z','Y').to_euler()
area((-12,9,15),4500,15,(1,.9,.8));area((12,8,12),3800,15,(.78,.87,1));area((0,-8,13),5000,20,(.6,.8,1))
bpy.ops.object.camera_add(location=(0,40,13));camera=bpy.context.object;camera.rotation_euler=(Vector((0,0,3.7))-camera.location).to_track_quat('-Z','Y').to_euler();camera.data.type='ORTHO';camera.data.ortho_scale=37;scene.camera=camera
display_labels.append(text('FORGOTTEN V3  /  GEOMETRIA PROPIA PROVISIONAL',[0,8.3,0],.45))
display_labels.append(text('Render tecnico en Blender; no es una captura de Roblox Studio.  *Alternativas propias del catalogo.',[0,.3,-3],.25))
scene.render.filepath=str(OUT/'01-personajes-v3.png');bpy.ops.render.render(write_still=True)
# Preserve the actual authoring scene for reproducible inspection.
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'Personajes-V3.blend'))
print('V3 technical geometry preview:',scene.render.filepath,flush=True)

# Three orthographic views from the exact same geometry; never generated concept art.
for objects in characters.values():
 for obj in objects:obj.hide_render=True
for obj in display_labels:obj.hide_render=True
scene.render.resolution_x=1500;scene.render.resolution_y=800
camera.location=(0,30,3.8);camera.rotation_euler=(Vector((0,0,3.8))-camera.location).to_track_quat('-Z','Y').to_euler();camera.data.ortho_scale=21
for index,(id,objects) in enumerate(characters.items()):
 clones=[];old_center=(2.5-index)*6
 for view,(angle,label) in enumerate([(0,'FRONTAL'),(math.pi/2,'LATERAL'),(math.pi,'TRASERA')]):
  offset=(1-view)*6.6
  transform=Matrix.Translation((offset,0,0))@Matrix.Rotation(angle,4,'Z')@Matrix.Translation((-old_center,0,0))
  for original in objects:
   clone=original.copy();bpy.context.collection.objects.link(clone);clone.hide_render=False
   clone.matrix_world=transform@original.matrix_world;clones.append(clone)
  clones.append(text(label,[offset,7.35,0],.4))
 name={'pelotocino':'PELOTOCINO','yellowguy':'YELLOW GUY','junkbot':'JUNKBOT','deathspeaker':'KORBLOX DEATHSPEAKER','guest666':'GUEST 666','tubers93':'TUBERS93'}[id]
 clones.append(text('FORGOTTEN V3  /  '+name,[0,8.55,0],.48))
 clones.append(text('RENDER DE BLENDER / NO ES ROBLOX STUDIO',[0,-.55,-1],.32))
 note='Alternativa propia provisional; al jugar se intenta cargar el original de Roblox.' if id in ['junkbot','deathspeaker'] else 'Geometria propia V3; cabeza nativa aproximada para este render.'
 clones.append(text(note,[0,-1.15,-1],.25))
 scene.render.filepath=str(OUT/f'{index+2:02}-{id}-tres-vistas.png');bpy.ops.render.render(write_still=True)
 for obj in clones:bpy.data.objects.remove(obj,do_unlink=True)
 print('Rendered three views:',id,flush=True)
manifest={'renderer':'Blender '+bpy.app.version_string,'studio_screenshot':False,
 'geometry_sha256':hashlib.sha256((ROOT/'assets/v3/character-geometry.json').read_bytes()).hexdigest(),
 'rendered_at':datetime.now(timezone.utc).isoformat(),
 'limitations':['Own provisional alternatives, not live catalog bodies','Native head approximation','Blender materials and lighting differ from Roblox'],
 'images':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(OUT.glob('*.png'))}}
(OUT/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
