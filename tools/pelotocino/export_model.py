"""R15 model + NPC + real KeyframeSequences; meshes instantiate through Roblox APIs.
Never claims the resulting files have been opened in Studio here.
"""
from pathlib import Path
import json,math,struct,base64,xml.etree.ElementTree as E
import numpy as np
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'dist/pelotocino';OUT.mkdir(exist_ok=True)
DATA=json.loads((ROOT/'assets/pelotocino/geometry.json').read_text())
ANIM=json.loads((ROOT/'assets/pelotocino/animations.json').read_text())
serial=0
def item(parent,cls,name):
 global serial
 serial+=1;n=E.SubElement(parent,'Item',{'class':cls,'referent':'RBX_P_'+str(serial)});props=E.SubElement(n,'Properties');prop(n,'string','Name',name);return n
def prop(item,kind,name,value):
 n=E.SubElement(item.find('Properties'),kind,{'name':name});n.text=str(value).lower() if isinstance(value,bool)else str(value);return n
def vector(item,name,xyz):
 n=E.SubElement(item.find('Properties'),'Vector3',{'name':name})
 for k,v in zip(['X','Y','Z'],xyz):E.SubElement(n,k).text=str(v)
def frame(item,name,pos=(0,0,0),rot=(0,0,0)):
 x,y,z=rot;cx,sx,cy,sy,cz,sz=math.cos(x),math.sin(x),math.cos(y),math.sin(y),math.cos(z),math.sin(z)
 R=np.array([[1,0,0],[0,cx,-sx],[0,sx,cx]])@np.array([[cy,0,sy],[0,1,0],[-sy,0,cy]])@np.array([[cz,-sz,0],[sz,cz,0],[0,0,1]])
 n=E.SubElement(item.find('Properties'),'CoordinateFrame',{'name':name})
 for k,v in zip(['X','Y','Z'],pos):E.SubElement(n,k).text=str(v)
 for i in range(3):
  for j in range(3):E.SubElement(n,f'R{i}{j}').text=str(float(R[i,j]))
def ref(item,name,target):prop(item,'Ref',name,target.attrib['referent'])
def attributes(node,values):
 b=struct.pack('<I',len(values))
 for key,value in values.items():
  k=key.encode();b+=struct.pack('<I',len(k))+k
  if isinstance(value,bool):b+=b'\x03'+bytes([int(value)])
  elif isinstance(value,str):v=value.encode();b+=b'\x02'+struct.pack('<I',len(v))+v
  else:b+=b'\x06'+struct.pack('<d',value)
 prop(node,'BinaryString','AttributesSerialize',base64.b64encode(b).decode())
def sequences(parent):
 folder=item(parent,'Folder','AnimSaves')
 for name,frames in ANIM.items():
  seq=item(folder,'KeyframeSequence',name);prop(seq,'bool','Loop',name in ['idle','walk','run','sprint']);prop(seq,'token','Priority',0 if name=='idle'else 1 if name in ['walk','run','sprint']else 2)
  for index,sample in enumerate(frames):
   k=item(seq,'Keyframe','Keyframe');prop(k,'float','Time',sample['time'])
   parentPose=item(k,'Pose','HumanoidRootPart');prop(parentPose,'float','Weight',0)
   poses={'HumanoidRootPart':parentPose}
   for joint,p0,p1,point in DATA['joints']:
    pose=item(poses[p0],'Pose',p1);poses[p1]=pose
    values=sample['pose'].get('RootJoint'if joint=='Root'else joint,[0]*6)
    frame(pose,'CFrame',values[3:6],values[:3]);prop(pose,'float','Weight',1)
   if name in ['pan','baconThrow'] and index==min(range(len(frames)),key=lambda i:abs(frames[i]['time']-(.22 if name=='pan'else .45))):
    marker=item(k,'KeyframeMarker','Contact'if name=='pan'else'BaconRelease');prop(marker,'string','Value','server-timing-reference')
 return folder
def model_export(npc):
 root=E.Element('roblox',version='4');m=item(root,'Model','Pelotocino_NPC'if npc else'Pelotocino_R15')
 attributes(m,{'PelotocinoR15':True,'CharacterIdentity':'pelotocino','NPC':npc,'Placeholder':False,'ModelStatus':'R15 · MeshParts al ejecutar · Studio pendiente'})
 parts={}
 for name,xyz in DATA['anchors'].items():
  part=item(m,'Part',name);parts[name]=part
  size=[1.4,2,.75]if name=='HumanoidRootPart'else [1.3,1.18,1.06]if name=='Head'else [1.25,1.10,.68]if name=='UpperTorso'else [1.1,.55,.64]if name=='LowerTorso'else [.65,.44,.98]if'Foot'in name else [.45,.45,.4]if'Hand'in name else [.5,.7,.5]if'Arm'in name else [.6,.9,.65]
  vector(part,'size',size);frame(part,'CFrame',xyz)
  for key,val in [('Transparency',1)]:prop(part,'float',key,val)
  for key,val in [('Anchored',name=='HumanoidRootPart'),('CanCollide',name in ['UpperTorso','LowerTorso']),('CanTouch',name=='HumanoidRootPart'),('CanQuery',True),('Massless',name!='HumanoidRootPart'),('CastShadow',False)]:prop(part,'bool',key,val)
  prop(part,'token','TopSurface',0);prop(part,'token','BottomSurface',0)
 ref(m,'PrimaryPart',parts['HumanoidRootPart'])
 for joint,p0,p1,xyz in DATA['joints']:
  motor=item(parts[p0],'Motor6D',joint);ref(motor,'Part0',parts[p0]);ref(motor,'Part1',parts[p1])
  for p,propname in [(p0,'C0'),(p1,'C1')]:
   pos=(np.array(xyz)-np.array(DATA['anchors'][p])).tolist();frame(motor,propname,pos)
   a=item(parts[p],'Attachment',joint+'RigAttachment');frame(a,'CFrame',pos)
 for name,part in [('RightGripAttachment','RightHand'),('LeftGripAttachment','LeftHand'),('HairAttachment','Head'),('BodyBackAttachment','UpperTorso'),('BaconRelease','RightHand')]:
  a=item(parts[part],'Attachment',name);frame(a,'CFrame',[0,-.82,-.15]if name=='BaconRelease'else[0,0,0])
 h=item(m,'Humanoid','Humanoid');prop(h,'token','RigType',1);prop(h,'float','HipHeight',DATA['hipHeight']);prop(h,'float','WalkSpeed',16);prop(h,'float','MaxHealth',100);prop(h,'float','Health',100);prop(h,'bool','AutomaticScalingEnabled',False);prop(h,'bool','BreakJointsOnDeath',False);prop(h,'string','DisplayName','Pelotocino');item(h,'Animator','Animator')
 package=item(m,'Folder','PelotocinoPackage')
 for name in ['PelotocinoMeshData','PelotocinoMotion','PelotocinoRenderer','PelotocinoSurface','PelotocinoRig']:
  module=item(package,'ModuleScript',name);prop(module,'ProtectedString','Source',(ROOT/'src/shared'/(name+'.luau')).read_text())
 for file,name,context in [('Standalone.client.luau','PelotocinoAnimate',2),('Standalone.server.luau','PelotocinoPreview',1)]:
  script=item(m,'Script',name);prop(script,'token','RunContext',context);prop(script,'ProtectedString','Source',(ROOT/'tools/pelotocino'/file).read_text())
 sequences(m)
 out=OUT/('Pelotocino-NPC.rbxmx'if npc else'Pelotocino-R15.rbxmx');E.indent(root);E.ElementTree(root).write(out,encoding='utf-8',xml_declaration=True)
 return out
if __name__=='__main__':
 if (ROOT/'src/shared/PelotocinoMeshLibrary.luau').exists():raise SystemExit('Entrega anterior protegida: usa tools/pelotocino_import/export.py')
 for npc in [False,True]:print(model_export(npc))
 root=E.Element('roblox',version='4');sequences(root);E.indent(root);E.ElementTree(root).write(OUT/'Pelotocino-Animations.rbxmx',encoding='utf-8',xml_declaration=True)
