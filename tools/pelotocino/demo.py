"""Blender playback of the same Luau samples used by the R15 controller."""
import bpy,json,math
from pathlib import Path
from mathutils import Matrix,Vector
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'dist/pelotocino/demo-frames';OUT.mkdir(parents=True,exist_ok=True)
D=json.loads((ROOT/'assets/pelotocino/geometry.json').read_text());A=json.loads((ROOT/'assets/pelotocino/animations.json').read_text())
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'dist/pelotocino/Pelotocino.blend'))
M=Matrix(((1,0,0,0),(0,0,-1,0),(0,1,0,0),(0,0,0,1)));MI=M.inverted()
def T(p):return Matrix.Translation(Vector(p))
def R(v):return Matrix.Rotation(v[0],4,'X')@Matrix.Rotation(v[1],4,'Y')@Matrix.Rotation(v[2],4,'Z')
def sample(key,t):
 frames=A[key];a,b=frames[0],frames[-1]
 for i in range(1,len(frames)):
  if t<=frames[i]['time']:a,b=frames[i-1],frames[i];break
 f=max(0,min(1,(t-a['time'])/max(.001,b['time']-a['time'])))
 return {k:[a['pose'][k][i]+(b['pose'][k][i]-a['pose'][k][i])*f for i in range(6)] for k in a['pose']}
def matrices(key,t):
 pose=sample(key,t);fk={'HumanoidRootPart':T(D['anchors']['HumanoidRootPart'])}
 for name,parent,child,pos in D['joints']:
  v=pose.get('RootJoint'if name=='Root'else name,[0]*6)
  fk[child]=fk[parent]@T(Vector(pos)-Vector(D['anchors'][parent]))@T(v[3:])@R(v[:3])@T(Vector(D['anchors'][child])-Vector(pos))
 return fk
objects={s['name']:bpy.data.objects[s['name']]for s in D['meshes']}
tuft=next(s for s in D['meshes']if s['group']=='tuft');source=objects[tuft['name']];projectile=source.copy();bpy.context.collection.objects.link(projectile);projectile.name='Blender visual projectile';projectile.hide_render=True
lo=Vector(tuple(min(v[i]for v in tuft['vertices'])for i in range(3)));hi=Vector(tuple(max(v[i]for v in tuft['vertices'])for i in range(3)));center=(lo+hi)/2
scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=12;scene.cycles.use_denoising=False;scene.render.resolution_x=640;scene.render.resolution_y=800;scene.render.resolution_percentage=100
scene.world.use_nodes=True;scene.world.node_tree.nodes['Background'].inputs[0].default_value=(.17,.2,.24,1);scene.world.node_tree.nodes['Background'].inputs[1].default_value=.4;scene.view_settings.view_transform='AgX';scene.view_settings.exposure=.4
bpy.ops.mesh.primitive_plane_add(size=100,location=(0,0,.07));ground=bpy.context.object;mat=bpy.data.materials.new('Floor');mat.diffuse_color=(.055,.065,.08,1);ground.data.materials.append(mat)
for loc,power in [((-4,6,9),900),((4,4,7),650),((0,-4,8),800)]:
 d=bpy.data.lights.new('Blender light','AREA');d.energy=power;d.size=5;o=bpy.data.objects.new('Blender light',d);bpy.context.collection.objects.link(o);o.location=loc;o.rotation_euler=(Vector((0,0,3))-o.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add(location=(7,14,6));cam=bpy.context.object;cam.rotation_euler=(Vector((0,0,2.8))-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.type='ORTHO';cam.data.ortho_scale=7.6;scene.camera=cam
mat=bpy.data.materials.new('Titles');mat.diffuse_color=(.8,.85,.9,1)
def text(body,y,size):
 d=bpy.data.curves.new('Caption','FONT');d.body=body;d.align_x='CENTER';d.align_y='CENTER';d.size=size;o=bpy.data.objects.new('Caption',d);bpy.context.collection.objects.link(o);o.data.materials.append(mat);o.rotation_euler=cam.rotation_euler;o.location=Vector((0,0,2.8))+cam.rotation_euler.to_matrix()@Vector((0,y,0));return o
caption=text('PELOTOCINO R15',3.25,.24);text('BLENDER / NO ES ROBLOX STUDIO',-3.1,.16)
frame=0
for key,seconds,label in [('idle',1.0,'IDLE'),('walk',1.1,'CAMINAR'),('run',1.44,'CORRER'),('pan',.72,'SARTEN'),('baconThrow',1.15,'BACON THROW / RAQUETA'),('detector',1.6,'RASTREADOR'),('hit',.4,'RECIBIR GOLPE')]:
 caption.data.body='PELOTOCINO / '+label
 for i in range(max(1,round(seconds*12))):
  t=i/12;duration=A[key][-1]['time'];t=t%duration if key in ['idle','walk','run']else min(t,duration)
  fk=matrices(key,t);throw=key=='baconThrow';pan=key in ['pan','baconThrow'];tracker=key=='detector'
  for spec in D['meshes']:
   o=objects[spec['name']];transform=fk[spec['anchor']];o.hide_render=False
   if spec['group']=='pan':transform=fk['RightHand']@T((0,-.08,0))if pan else fk['UpperTorso']@T((.65,-.25,.93))@R((0,.2,-.22))
   if spec['group']=='tracker':transform=fk['LeftHand']@T((0,-.1,-.16))@R((.1,0,0))if tracker else fk['UpperTorso']@T((-.69,-.28,.36))
   if spec['group']=='tuft'and throw:
    if .12<=t<.36:transform=fk['LeftHand']@T((0,-.08,-.16))@R((0,0,.2))@T((.15,-.4,.2))
    elif .36<=t<.45:
     f=(t-.36)/.09;start=fk['LeftHand']@T((0,-.08,-.16));end=fk['RightHand']@T((0,-.82,-.15));transform=start.lerp(end,f)@T((.15,-.4,.2))
    elif .45<=t<1.02:o.hide_render=True
   o.matrix_world=M@transform@MI
  projectile.hide_render=not(throw and .45<=t<1.05)
  if not projectile.hide_render:
   launch=matrices(key,.45)['RightHand']@Vector((0,-.82,-.15));f=(t-.45)/.6;pos=launch+Vector((0,math.sin(f*math.pi)*1.2,-f*8));projectile.matrix_world=M@T(pos)@R((0,0,f*math.pi*3))@T(-center)@MI
  scene.render.filepath=str(OUT/f'{frame:04}.png');bpy.ops.render.render(write_still=True);frame+=1
 print('Rendered animation:',key,flush=True)
print('Frames:',frame,flush=True)
import hashlib
(OUT.parent/'demo-manifest.json').write_text(json.dumps({
 'renderer':'Blender '+bpy.app.version_string,'studio_executed':False,'fps':12,'frames':frame,
 'geometry_sha256':hashlib.sha256((ROOT/'assets/pelotocino/geometry.json').read_bytes()).hexdigest(),
 'samples_sha256':hashlib.sha256((ROOT/'assets/pelotocino/animations.json').read_bytes()).hexdigest(),
 'motion_sha256':hashlib.sha256((ROOT/'src/shared/PelotocinoMotion.luau').read_bytes()).hexdigest(),
 'frame_sha256':{p.name:hashlib.sha256(p.read_bytes()).hexdigest()for p in sorted(OUT.glob('*.png'))}
},indent=2)+'\n')
