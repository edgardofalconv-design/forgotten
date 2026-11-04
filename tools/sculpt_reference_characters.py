"""Reconstrucción original desde referencias visuales. No importa assets de terceros."""
import bpy, math, json, sys
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'dist/reference-characters';OUT.mkdir(exist_ok=True)
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
M={};objects=[];anchors={};current='';part='Torso'
def mat(name,color,metal=0,rough=.5,emit=0):
 if name in M:return M[name]
 m=bpy.data.materials.new(name);m.diffuse_color=(*color,1);m.use_nodes=True;b=m.node_tree.nodes.get('Principled BSDF')
 b.inputs['Base Color'].default_value=(*color,1);b.inputs['Metallic'].default_value=metal;b.inputs['Roughness'].default_value=rough
 if emit:b.inputs['Emission Color'].default_value=(*color,1);b.inputs['Emission Strength'].default_value=emit
 M[name]=m;return m
black=mat('Negro carbon',(.008,.01,.013),0,.6);rubber=mat('Goma',(.018,.02,.024),0,.8)
white=mat('Plastico claro',(.78,.8,.77));blue=mat('Camisa azul',(.012,.16,.3),0,.82)
hair=mat('Castano',(.10,.032,.009),0,.65);highlight=mat('Vetas castanas',(.18,.065,.014),0,.65)
yellow=mat('Piel amarilla',(.72,.43,.09),0,.5);blond=mat('Cabello dorado',(.38,.18,.025),0,.34)
gold=mat('Armadura ocre',(.24,.19,.045),.5,.65);steel=mat('Acero gris',(.075,.088,.08),.65,.6)
silver=mat('Metal violeta claro',(.34,.35,.44),.6,.38);purple=mat('Armadura purpura',(.07,.042,.085),.35,.5)
teal=mat('Tejido espectral',(.017,.055,.065),0,.8);cyan=mat('Cristal azul',(.015,.35,.48),.4,.25,.25)
red=mat('Rojo guest',(.35,.008,.018),0,.46);redEye=mat('Ojos rojos',(.7,.002,.004),0,.3,1.8)
green=mat('Visor verde',(.025,.17,.052),.3,.3,.12);bandage=mat('Venda desgastada',(.52,.48,.37),0,.9)
def register(o,name,material):
 o.name=current+'__'+part+'__'+name;o.data.materials.append(material);o['Anchor']=part;objects.append(o);return o
def cube(name,loc,scale,material,bevel=.05):
 bpy.ops.mesh.primitive_cube_add(size=1,location=loc);o=bpy.context.object;o.scale=scale;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 if bevel:
  mod=o.modifiers.new('Bordes moldeados','BEVEL');mod.width=bevel;mod.segments=3
  o.modifiers.new('Normales','WEIGHTED_NORMAL')
 return register(o,name,material)
def ell(name,loc,scale,material,segments=24):
 bpy.ops.mesh.primitive_uv_sphere_add(segments=segments,ring_count=12,radius=1,location=loc);o=bpy.context.object;o.scale=scale
 for f in o.data.polygons:f.use_smooth=True
 return register(o,name,material)
def mesh(name,verts,faces,material):
 data=bpy.data.meshes.new(name);data.from_pydata(verts,[],faces);data.update();o=bpy.data.objects.new(name,data);bpy.context.collection.objects.link(o);return register(o,name,material)
def tube(name,points,radii,material,sides=10):
 pts=[Vector(p) for p in points];verts=[]
 for i,p in enumerate(pts):
  tangent=(pts[min(i+1,len(pts)-1)]-pts[max(i-1,0)]).normalized();ref=Vector((0,1,0))
  if abs(tangent.dot(ref))>.9:ref=Vector((1,0,0))
  u=tangent.cross(ref).normalized();v=tangent.cross(u).normalized()
  for j in range(sides):verts.append(p+radii[i]*(math.cos(j*2*math.pi/sides)*u+math.sin(j*2*math.pi/sides)*v))
 faces=[]
 for i in range(len(pts)-1):
  for j in range(sides):faces.append((i*sides+j,i*sides+(j+1)%sides,(i+1)*sides+(j+1)%sides,(i+1)*sides+j))
 faces.extend([tuple(range(sides-1,-1,-1)),tuple((len(pts)-1)*sides+j for j in range(sides))])
 o=mesh(name,verts,faces,material)
 for f in o.data.polygons:f.use_smooth=True
 return o
def bar(name,a,b,r,material):return tube(name,[a,b],[r,r],material,12)
def torus(name,loc,major,minor,material,rot=(0,0,0)):
 bpy.ops.mesh.primitive_torus_add(major_radius=major,minor_radius=minor,major_segments=24,minor_segments=8,location=loc,rotation=rot);o=bpy.context.object
 for f in o.data.polygons:f.use_smooth=True
 return register(o,name,material)
def graphic(name,loc,width,height,file):
 m=mat('Image '+file,(1,1,1));nodes=m.node_tree.nodes;links=m.node_tree.links;b=nodes.get('Principled BSDF')
 if not nodes.get('Artwork'):
  n=nodes.new('ShaderNodeTexImage');n.name='Artwork';n.image=bpy.data.images.load(str(ROOT/'assets/characters'/(file+'.png')),check_existing=True)
  links.new(n.outputs['Color'],b.inputs['Base Color']);links.new(n.outputs['Alpha'],b.inputs['Alpha']);m.surface_render_method='DITHERED'
 bpy.ops.mesh.primitive_plane_add(size=1,location=loc,rotation=(math.pi/2,0,0));o=bpy.context.object;o.scale=(width,height,1);return register(o,name,m)
def text(name,body,loc,size,material):
 d=bpy.data.curves.new(name,'FONT');d.body=body;d.align_x='CENTER';d.align_y='CENTER';d.size=size;d.extrude=.001
 o=bpy.data.objects.new(name,d);bpy.context.collection.objects.link(o);o.location=loc;o.rotation_euler=(math.pi/2,0,0);register(o,name,material);return o
def start(id):
 global current,objects,anchors,part
 current=id;objects=[];part='Torso'
 anchors={'Torso':(0,0,3.3),'Head':(0,0,4.95),'LeftArm':(-1.15,0,4),'RightArm':(1.15,0,4),'LeftLeg':(-.5,0,2.25),'RightLeg':(.5,0,2.25)}
def basic_body(skin,guest=False):
 global part
 part='Torso';cube('Torso',(0,0,3.35),(1.85,.95,1.95),black,.15)
 cube('Cintura',(0,0,2.45),(1.65,.9,.24),black,.05)
 for s in [-1,1]:
  part='LeftLeg' if s<0 else 'RightLeg'
  cube('Pantalon',(s*.47,0,1.36),(.88,.88,1.95),black,.08)
  cube('Zapato',(s*.47,-.14,.27),(.9,1.16,.45),black if guest else white,.16)
  part='LeftArm' if s<0 else 'RightArm'
  cube('Brazo',(s*1.32,0,3.3),(.72,.84,1.65),black if guest else skin,.16)
  if not guest:cube('Manga',(s*1.32,0,3.82),(.76,.88,.67),black,.09)
  cube('Palma',(s*1.32,-.015,2.33),(.59,.65,.48),black if guest else skin,.14)
  if not guest:
   for j in range(4):bar('Dedo',(s*1.32-.21+j*.14,-.24,2.25),(s*1.32-.21+j*.14,-.26,2.06),.062,skin)
   ell('Pulgar',(s*1.65,-.08,2.35),(.12,.14,.2),skin)
 part='Head';cube('Cabeza',(0,0,4.96),(1.24,1.12,1.22),skin,.28)
def bacon_hair():
 global part
 part='Head';ell('Cabellera',(0,.12,5.48),(.75,.61,.36),hair)
 for i in range(-3,4):
  x=i*.19
  pts=[(x*.8,.37,5.6),(x,.1,5.79),(x*1.08,-.32,5.68),(x*1.15,-.57,5.38),(x*1.08,-.58,[5.26,5.13,5.02,5.38,4.98,5.22,5.3][i+3])]
  tube('Mechon ondulado',pts,[.1,.14,.135,.11,.055],hair,12)
  for k in [-1,1]:tube('Veta',[(p[0]+k*.036,p[1]-.012,p[2]+.06) for p in pts],[.009]*5,highlight,5)
 for s in [-1,1]:tube('Mechon lateral',[(s*.53,.35,5.6),(s*.69,.2,5.35),(s*.66,.1,4.9)],[.16,.16,.08],hair)
def jacket():
 global part
 part='Torso';cube('Camiseta azul',(0,-.49,3.34),(.79,.035,1.8),blue,.01)
 for s in [-1,1]:
  o=cube('Solapa',(s*.52,-.53,3.65),(.25,.09,1.17),black,.035);o.rotation_euler.y=s*-.15
  cube('Bolsillo',(s*.66,-.54,3.16),(.27,.04,.2),rubber,.015)
  bar('Costura',(s*.73,-.548,3.05),(s*.73,-.548,4.08),.006,steel)
def scars():
 global part
 if current in ['yellowguy','deathspeaker']:
  part='Torso'
  front=-.535 if current=='deathspeaker' else -.34
  for i in range(4):bar('Arañazo de armadura',(-.24,front,3.6+i*.065),(-.09,front-.01,3.65+i*.065),.007,silver)
 else:
  part='Head';bar('Cicatriz',(-.4,-.574,4.94),(-.32,-.578,4.78),.008,mat('Cicatriz',(.26,.12,.07)))
  o=cube('Venda',(.37,-.574,4.7),(.2,.025,.085),bandage,.01);o.rotation_euler.y=.15
  part='Torso'
  for i in range(2):bar('Raspon',(-.6,-.58,2.85+i*.09),(-.43,-.58,2.91+i*.09),.007,steel)
def make_bacon(killer=False):
 global part
 basic_body(white);bacon_hair();jacket();part='Head';graphic('Sonrisa',(0,-.568,4.94),1.15,1.1,'bacon_face')
 if killer:
  part='Torso';cube('Mascara dorada',(0,-.59,3.86),(1.12,.13,.66),mat('Oro pechera',(.65,.38,.018)),.05)
  graphic('Tristeza',(0,-.662,3.85),1.1,.72,'sad_badge')
  part='RightArm'
  bar('Asta',(1.96,0,.4),(1.96,0,5.9),.055,silver)
  # Broad curved blade, built as one continuous ribbon.
  verts=[]
  for i in range(17):
   t=i/16;ang=t*1.8
   x=1.96-1.45*math.sin(ang);z=5.9-.9*(1-math.cos(ang));width=.34*(1-t)+.015
   for y in [-.055,.055]:verts.extend([(x,y,z),(x,y,z-width)])
  faces=[]
  for i in range(16):
   a=i*4;b=a+4;faces += [(a,b,b+1,a+1),(a+2,a+3,b+3,b+2),(a,a+2,b+2,b),(a+1,b+1,b+3,a+3)]
  mesh('Hoja de guadana',verts,faces,silver)
  for i in range(18):torus('Cadena',(1.9,-.12,2.4-i*.1),.07,.014,silver,(math.pi/2,0,i%2*math.pi/2))
 else:scars()
def make_guest():
 global part
 basic_body(black,True);part='Head'
 for s in [-1,1]:ell('Ojo rojo',(s*.17,-.568,5.07),(.035,.025,.08),redEye)
 ell('Gorra',(0,.05,5.57),(.64,.58,.32),mat('Gorra marron',(.026,.019,.014)))
 ell('Visera',(0,-.52,5.47),(.7,.55,.035),red)
 graphic('R gorra',(0,-.578,5.63),.35,.36,'guest_cap')
 part='Torso';graphic('ROBLOX',(0,-.481,3.66),1.75,1.17,'guest_logo')
 for s in [-1,1]:
  part='LeftArm' if s<0 else 'RightArm'
  graphic('Logo manga',(s*1.32,-.43,3.6),.64,.64,'guest_cap')
def make_tux():
 global part
 basic_body(yellow,True);part='Head';bpy.data.objects[current+'__Head__Cabeza'].data.materials.clear();bpy.data.objects[current+'__Head__Cabeza'].data.materials.append(yellow)
 graphic('Rostro',(0,-.568,4.96),1.22,1.15,'tux_face')
 ell('Base pelo',(0,.1,5.53),(.72,.6,.35),blond)
 for i in range(-2,3):
  pts=[(i*.24,.2,5.47),(i*.23,.12,5.78),(i*.21-.1,-.02,6.15+(2-abs(i))*.1),(i*.19-.16,-.14,6.27+(2-abs(i))*.09)]
  tube('Tupé',pts,[.15,.19,.17,.025],blond,14)
 part='Torso';cube('Camisa',(0,-.49,3.4),(.75,.035,1.82),white,.01)
 for s in [-1,1]:
  verts=[(s*.32,-.56,4.24),(s*.69,-.56,4.07),(s*.22,-.59,3.2),(s*.1,-.59,3.55)]
  mesh('Solapa satinada',verts,[(0,1,2,3)],mat('Satin negro',(.015,.019,.024),0,.3))
  ell('Lazo',(s*.14,-.6,4.06),(.17,.07,.095),black)
 for i in range(5):ell('Boton',(0,-.526,3.87-i*.28),(.025,.015,.025),black)
 text('Numero','246',(-.64,-.574,3.77),.2,white);scars()
def make_robot():
 global part
 part='Torso'
 for i in range(6):torus('Anillo abdominal',(0,0,2.9+i*.12),.31,.06,steel)
 ell('Pecho mecanico',(0,0,3.75),(.55,.34,.6),gold)
 for s in [-1,1]:
  bar('Tubo costal',(s*.38,-.31,3.22),(s*.5,-.25,4.1),.055,steel)
  for i in range(3):cube('Rejilla',(s*.28,-.359,3.49+i*.12),(.25,.055,.04),steel,.01)
 torus('Panel central',(0,-.36,3.83),.2,.045,gold,(math.pi/2,0,0));cube('Señal verde',(0,-.415,3.83),(.3,.02,.07),green,.015)
 part='Head'
 bar('Cuello',(0,0,4.15),(0,0,4.48),.15,steel)
 ell('Casco',(0,0,4.95),(.45,.34,.62),gold)
 for s in [-1,1]:
  eye=ell('Cuenca',(s*.18,-.31,5.03),(.145,.075,.19),black);eye.rotation_euler.y=s*.28
  eye=ell('Cristal',(s*.18,-.373,5.04),(.1,.035,.13),green);eye.rotation_euler.y=s*.28
  tube('Aleta oreja',[(s*.43,.02,5.08),(s*.55,.08,5.5),(s*.48,.08,5.62)],[.11,.07,.015],gold)
 cube('Cresta',(0,.28,5.72),(.14,.27,2.2),gold,.015)
 cube('Canal verde',(0,.133,5.78),(.055,.025,1.98),green,.005)
 for i in range(15):cube('Runas',(0,.113,4.9+i*.12),(.12,.025,.022),steel,.003)
 for s in [-1,1]:
  part='LeftArm' if s<0 else 'RightArm'
  shoulder=cube('Hombrera',(s*.97,0,4.03),(.63,.58,.43),gold,.11);shoulder.rotation_euler.y=s*.2
  ell('Articulacion hombro',(s*.92,0,3.9),(.22,.22,.22),steel)
  bar('Humeral',(s*1.04,0,3.84),(s*1.2,0,3.2),.15,steel)
  for dx in [-.08,.08]:bar('Piston',(s*1.07+dx,-.17,3.78),(s*1.23+dx,-.17,3.2),.045,silver)
  ell('Codo',(s*1.23,0,3.14),(.2,.22,.2),gold)
  cube('Antebrazo',(s*1.3,0,2.75),(.35,.44,.66),steel,.09)
  cube('Placa antebrazo',(s*1.3,-.24,2.78),(.28,.12,.43),gold,.08)
  for j in range(3):tube('Dedo mecanico',[(s*1.3-.13+j*.13,-.05,2.42),(s*1.3-.13+j*.13,-.11,2.13),(s*1.3-.13+j*.13,-.23,2.11)],[.05,.048,.03],black)
  part='LeftLeg' if s<0 else 'RightLeg'
  ell('Cadera',(s*.35,0,2.62),(.23,.22,.22),steel)
  cube('Muslo',(s*.4,0,2.12),(.38,.48,.74),steel,.08)
  bar('Piston muslo',(s*.53,-.24,2.45),(s*.53,-.24,1.75),.055,silver)
  ell('Rodilla',(s*.43,0,1.65),(.23,.25,.23),gold)
  cube('Espinilla',(s*.46,.02,1.04),(.39,.45,.85),steel,.07)
  cube('Placa amarilla',(s*.46,-.24,1.07),(.27,.09,.62),gold,.055)
  bar('Tobillo',(s*.46,0,.62),(s*.47,0,.3),.12,steel)
  cube('Pie robot',(s*.47,-.23,.2),(.48,.9,.36),steel,.08)
  for j in range(3):cube('Estria bota',(s*.47,-.5+j*.15,.4),(.36,.035,.025),gold,.005)
 scars()
def make_ghost():
 global part
 part='Torso'
 ell('Torso oscuro',(0,0,3.55),(.78,.42,.93),teal)
 # Layered, jagged skirt conceals legs as in the reference.
 for layer in range(2):
  verts=[];n=20
  for i in range(n):
   a=i*2*math.pi/n
   verts.extend([(math.cos(a)*(.65+layer*.03),math.sin(a)*(.4+layer*.03),3.15),(math.cos(a)*(.62+layer*.08),math.sin(a)*(.35+layer*.06),1.35+(i%3)*.19-layer*.08)])
  mesh('Tunica rasgada',verts,[(2*i,2*((i+1)%n),2*((i+1)%n)+1,2*i+1) for i in range(n)],teal)
 ell('Peto plateado',(0,-.29,3.75),(.83,.22,.59),silver)
 torus('Engaste',(0,-.525,4.04),.21,.055,purple,(math.pi/2,0,0));ell('Gema',(0,-.57,4.04),(.155,.065,.18),cyan)
 for s in [-1,1]:
  tube('Ribete pechera',[(0,-.53,3.44),(s*.38,-.52,3.56),(s*.73,-.42,3.94)],[.04,.045,.045],purple)
  pts=[]
  for i in range(17):
   a=i/16*math.pi*2;radius=.14*(1-i/22);pts.append((s*(.39+math.cos(a)*radius),-.515,3.93+math.sin(a)*radius))
  tube('Voluta grabada',pts,[.022]*len(pts),purple,6)
 # Pointed front tabard with silver runic piping.
 verts=[(-.57,-.51,3.46),(.57,-.51,3.46),(.38,-.52,2.35),(0,-.54,1.84),(-.38,-.52,2.35)]
 mesh('Tabardo',verts,[(0,1,2,3,4)],purple)
 for s in [-1,1]:tube('Borde tabardo',[(s*.55,-.54,3.44),(s*.36,-.55,2.38),(0,-.57,1.88)],[.03,.03,.02],silver)
 for i in range(3):tube('Runa frontal',[(-.32+i*.04,-.57,3.25-i*.24),(0,-.58,3.03-i*.24),(.32-i*.04,-.57,3.25-i*.24)],[.025]*3,silver)
 part='Head'
 ell('Capucha',(0,.08,4.97),(.7,.52,.74),purple)
 ell('Vacio de rostro',(0,-.405,4.94),(.5,.12,.52),black)
 tube('Ribete capucha',[(-.5,-.44,4.63),(-.57,-.42,5.11),(-.35,-.4,5.49),(0,-.4,5.63),(.35,-.4,5.49),(.57,-.42,5.11),(.5,-.44,4.63)],[.055]*7,silver)
 for s in [-1,1]:
  eye=ell('Ojo azul',(s*.2,-.526,5.08),(.13,.025,.055),cyan);eye.rotation_euler.y=s*.22
  ell('Pomulo',(s*.27,-.48,4.86),(.2,.08,.11),teal)
  points=[(s*.52,.02,5.4),(s*.77,.03,5.65),(s*.99,.06,6.04),(s*1.04,.08,6.37),(s*.91,.1,6.58)]
  tube('Cuerno oscuro',points[:4],[.16,.15,.105,.06],black,14)
  tube('Punta cyan',points[3:],[.07,.006],cyan,12)
 ell('Mandibula oscura',(0,-.46,4.7),(.28,.11,.16),teal)
 for i in range(4):cube('Diente',(i*.1-.15,-.56,4.65),(.065,.035,.065),steel,.01)
 mesh('Nariz angular',[(-.055,-.55,4.99),(.055,-.55,4.99),(0,-.61,4.83)],[(0,1,2)],black)
 for s in [-1,1]:
  part='LeftArm' if s<0 else 'RightArm'
  ell('Hombrera',(s*1.04,0,4.04),(.48,.5,.34),silver)
  torus('Voluta hombro',(s*1.03,-.45,4.04),.17,.04,purple,(math.pi/2,0,0))
  for j in range(3):
   x=s*(.91+j*.22)
   tube('Espina hombrera',[(x,.08,4.2),(x+s*.12,.08,4.54),(x+s*.08,.09,4.75)],[.13,.075,.008],cyan)
  bar('Brazo',(s*1.1,0,3.89),(s*1.22,0,3.14),.24,teal)
  cube('Brazal',(s*1.23,-.01,3.17),(.55,.6,.73),purple,.14)
  for z in [2.86,3.46]:torus('Aro brazal',(s*1.23,0,z),.28,.04,silver)
  torus('Voluta brazal',(s*1.23,-.32,3.16),.16,.035,silver,(math.pi/2,0,0))
  ell('Mano',(s*1.27,0,2.63),(.23,.22,.3),teal)
  for j in range(3):
   x=s*1.27-.17+j*.17
   tube('Garra oscura',[(x,-.05,2.65),(x,-.15,2.34),(x,-.3,2.22)],[.065,.055,.035],teal)
   tube('Uña azul',[(x,-.25,2.28),(x,-.4,2.12)],[.06,.002],cyan)
 scars()
rigs={};counts={}
def finish(id):
 global objects
 # Convert bevels, text and tubes into real exportable mesh surfaces.
 bpy.ops.object.select_all(action='DESELECT')
 for o in objects:o.select_set(True)
 bpy.context.view_layer.objects.active=objects[0];bpy.ops.object.convert(target='MESH')
 converted=list(bpy.context.selected_objects)
 groups={}
 for o in converted:groups.setdefault(o.get('Anchor','Torso'),[]).append(o)
 joined=[]
 for key,group in groups.items():
  bpy.ops.object.select_all(action='DESELECT')
  for o in group:o.select_set(True)
  bpy.context.view_layer.objects.active=group[0];bpy.ops.object.join();o=bpy.context.object;o.name=id+'__'+key+'_mesh';joined.append((key,o))
 bpy.ops.object.select_all(action='DESELECT')
 data=bpy.data.armatures.new(id+'_skeleton');rig=bpy.data.objects.new(id,data);bpy.context.collection.objects.link(rig)
 rig.select_set(True);bpy.context.view_layer.objects.active=rig;bpy.ops.object.mode_set(mode='EDIT')
 root=data.edit_bones.new('Root');root.head=(0,0,2.7);root.tail=(0,0,3)
 for name,head in anchors.items():
  bone=data.edit_bones.new(name);bone.head=head
  bone.tail=Vector(head)+(Vector((0,0,1)) if name in ['Head','Torso'] else Vector((0,0,-1)))
  bone.parent=data.edit_bones.get('Torso') if name in ['Head','LeftArm','RightArm'] else root
 bpy.ops.object.mode_set(mode='OBJECT')
 for name,o in joined:
  vg=o.vertex_groups.new(name=name);vg.add(list(range(len(o.data.vertices))),1,'REPLACE')
  mod=o.modifiers.new('Rig de referencia','ARMATURE');mod.object=rig;o.parent=rig
 counts[id]=sum(sum(len(p.vertices)-2 for p in o.data.polygons) for _,o in joined)
 bpy.ops.object.select_all(action='DESELECT');rig.select_set(True)
 for _,o in joined:o.select_set(True)
 folder=OUT/id;folder.mkdir(exist_ok=True)
 bpy.ops.export_scene.fbx(filepath=str(folder/(id+'.fbx')),use_selection=True,object_types={'MESH','ARMATURE'},add_leaf_bones=False,bake_anim=False,path_mode='COPY',embed_textures=True,axis_forward='-Z',axis_up='Y')
 bpy.ops.export_scene.gltf(filepath=str(folder/(id+'.glb')),export_format='GLB',use_selection=True,export_animations=False)
 (folder/'anchors.json').write_text(json.dumps(anchors,indent=2))
 rigs[id]=rig
for id,fn in [('pelotocino',lambda:make_bacon(False)),('yellowguy',make_robot),('deathspeaker',make_ghost),('tubers93',lambda:make_bacon(True)),('guest666',make_guest),('baller',make_tux)]:
 start(id);fn();finish(id);print('Built',id,counts[id],flush=True)
# Render stage: physically lit neutral backdrop, no reinterpretation by image generation.
world=bpy.context.scene.world;world.use_nodes=True
world.node_tree.nodes['Background'].inputs[0].default_value=(.12,.14,.18,1)
world.node_tree.nodes['Background'].inputs[1].default_value=.35
bpy.ops.mesh.primitive_plane_add(size=200,location=(0,0,-.02));floor=bpy.context.object;floor.name='Studio floor';floor.data.materials.append(mat('Suelo estudio',(.14,.16,.19),0,.9))
def area(name,loc,energy,size,color):
 d=bpy.data.lights.new(name,'AREA');d.energy=energy;d.shape='DISK';d.size=size;d.color=color
 o=bpy.data.objects.new(name,d);bpy.context.collection.objects.link(o);o.location=loc;o.rotation_euler=(Vector((0,0,3))-o.location).to_track_quat('-Z','Y').to_euler()
area('Key',(-5,-8,10),1100,7,(1,.93,.83));area('Fill',(6,-4,7),850,6,(.78,.87,1));area('Rim',(0,5,9),1400,5,(.6,.77,1))
sc=bpy.context.scene;sc.render.engine='CYCLES';sc.cycles.samples=40;sc.cycles.use_denoising=False
sc.render.resolution_x=900;sc.render.resolution_y=1100;sc.render.resolution_percentage=100
sc.view_settings.view_transform='AgX';sc.view_settings.look='AgX - Medium High Contrast';sc.view_settings.exposure=.15
bpy.ops.object.camera_add();camera=bpy.context.object;sc.camera=camera;camera.data.type='ORTHO';camera.data.ortho_scale=7.8
for id,rig in rigs.items():
 rig.location.x=100
for id,rig in rigs.items():
 if '--refine' in sys.argv and id not in ['yellowguy','deathspeaker']:continue
 rig.location.x=0
 camera.location=(7,-16,8);target=Vector((0,0,3.25));camera.rotation_euler=(target-camera.location).to_track_quat('-Z','Y').to_euler()
 sc.render.filepath=str(OUT/(id+'-reference.png'));bpy.ops.render.render(write_still=True)
 rig.location.x=100
# A separate T-pose scene uses the same rigged meshes and textures.
for i,(id,rig) in enumerate(rigs.items()):
 rig.location=(i*7-17.5,0,0)
 for name in ['LeftArm','RightArm']:
  bone=rig.pose.bones.get(name)
  if bone:
   side=-1 if name=='LeftArm' else 1
   basis=bone.bone.matrix_local.to_quaternion();rot=Vector((0,0,-1)).rotation_difference(Vector((side,0,0)))
   bone.rotation_mode='QUATERNION';bone.rotation_quaternion=basis.inverted()@rot@basis
sc.render.resolution_x=2200;sc.render.resolution_y=900
camera.location=(0,-35,10);camera.rotation_euler=(Vector((0,0,3.3))-camera.location).to_track_quat('-Z','Y').to_euler();camera.data.ortho_scale=43
# Even lighting across the full lineup.
area('Lineup left',(-15,-8,12),3500,15,(1,.95,.88));area('Lineup right',(15,-8,12),3500,15,(.85,.92,1))
sc.render.filepath=str(OUT/'00-lineup-T.png');bpy.ops.render.render(write_still=True)
bpy.ops.file.pack_all();bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'Reference-reconstruction.blend'))
(OUT/'triangles.json').write_text(json.dumps(counts,indent=2))
print('DONE: geometry exports, rigged mesh previews and packed blend',flush=True)
