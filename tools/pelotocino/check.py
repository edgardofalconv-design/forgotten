"""Behavioral checks of the real R15 rig, mesh renderer and original motion.
Roblox services are explicit local doubles. These are not engine tests.
"""
from pathlib import Path
import sys,json,hashlib,zipfile,numpy as np
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from check_playable import run_lua,module,FACTORY_MOCK
from export_preview import MOCK

def art():
 data=json.loads((ROOT/'assets/pelotocino/geometry.json').read_text())
 assert len(data['anchors'])==16 and len(data['joints'])==15
 for m in data['meshes']:
  v=np.array(m['vertices']);f=np.array(m['faces']);n=np.array(m['normals'])
  assert np.isfinite(v).all()and np.isfinite(n).all()
  assert f.min()>=0 and f.max()<len(v)
  a,b,c=v[f[:,0]],v[f[:,1]],v[f[:,2]]
  assert (np.linalg.norm(np.cross(b-a,c-a),axis=1)>1e-9).all(),m['name']
  assert np.min(np.linalg.norm(n,axis=1))>.8,m['name']
  assert len(m['colors'])==len(v)
 groups={m['group'] for m in data['meshes']};assert {'body','hair','tuft','pan','tracker','backpack'}<=groups
 assert sum(len(m['faces'])for m in data['meshes'])<25000
 old=json.loads((ROOT/'backups/pre-pelotocino-protected.json').read_text())
 checked={}
 for name,digest in old.items():
  p=ROOT/'dist'/name
  if p.exists():content=p.read_bytes()
  elif name=='Forgotten.rbxlx' and (ROOT/'dist/Forgotten-Primera-Prueba.zip').exists():
   with zipfile.ZipFile(ROOT/'dist/Forgotten-Primera-Prueba.zip')as z:content=z.read(name)
  else:
   assert not (ROOT/'.git').exists(),'Falta una entrega protegida del repositorio: '+name
   continue
  assert hashlib.sha256(content).hexdigest()==digest,name
  checked[name]=digest
 print('PASS: 15 segmentos, geometría sin triángulos degenerados, equipo y '+str(len(checked))+' entregas históricas presentes protegidas')
 return checked

SETUP=r'''
services.Players={CreateHumanoidModelFromDescriptionAsync=function()error("native engine API unavailable in local tests")end}
services.ReplicatedStorage={FindFirstChild=function()return nil end}
local function clone(o)
 local copy=Instance.new(o.ClassName)
 for k,v in pairs(o.props)do if k~="Parent"and k~="ClassName"then copy.props[k]=v end end
 return copy
end
local oldRead=omt.__index
omt.__index=function(o,k)
 if k=="Clone"then return clone end
 if k=="GetDescendants"then return function(self)
  local out={};for _,n in ipairs(nodes)do local p=n.Parent;while p do if p==self then table.insert(out,n);break end;p=p.Parent end end;return out
 end end
 return oldRead(o,k)
end
local oldFrame=cmt.__index
cmt.__index=function(o,k)
 if k=="ToObjectSpace"then return function(a,b)return a:Inverse()*b end end
 if k=="Lerp"then return function(a,b,t)local r={};for i=1,9 do r[i]=a.r[i]+(b.r[i]-a.r[i])*t end;return cf(a.p:Lerp(b.p,t),r)end end
 return oldFrame(o,k)
end
Color3.new=function(r,g,b)return Color3.fromRGB(r*255,g*255,b*255)end
UDim2.fromOffset=function(x,y)return {x,y}end
Content={fromObject=function(x)return x end}
local meshCount,triangles=0,0
local meshFailure=false
services.AssetService={CreateEditableMesh=function()
 if meshFailure then error("Mesh API deliberately disabled")end
 meshCount=meshCount+1;local ids=0
 local function id()ids=ids+1;return ids end
 return {AddVertex=function(_,v)assert(v.X==v.X);return id()end,AddNormal=function(_,v)assert(v.Magnitude>.8);return id()end,AddUV=id,AddColor=id,
 AddTriangle=function(_,a,b,c)assert(a~=b and b~=c and a~=c);triangles=triangles+1;return id()end,
 SetFaceNormals=function(_,f,n)assert(#n==3)end,SetFaceColors=function(_,f,c)assert(#c==3)end,SetFaceUVs=function(_,f,u)assert(#u==3)end,Destroy=function()end}
end,CreateMeshPartAsync=function(_,content)return Instance.new("MeshPart")end}
workspace={GetServerTimeNow=function()return 100 end}
require=function(v)return v end;script={Parent={}}
'''

def rig_and_renderer():
 if (ROOT/'src/shared/PelotocinoMeshLibrary.luau').exists():
  from pelotocino_import.check import renderer,installer
  renderer();installer();return
 setup=MOCK+FACTORY_MOCK+SETUP
 for file,var in [('PelotocinoMeshData','Data'),('PelotocinoMotion','Motion'),('PelotocinoRig','Rig')]:
  setup+=module(file+'.luau',var)+'\nscript.Parent.'+file+'='+var+'\n'
 setup+='\nscript.Parent.PelotocinoSurface={apply=function()end,applyHair=function()end}\n'
 setup+=module('PelotocinoRenderer.luau','Renderer')
 tests=r'''
local m=Rig.create();m.Parent=Instance.new("Folder")
assert(m.Humanoid.RigType=="R15"and m.Humanoid.HipHeight==Data.hipHeight)
assert(m:GetAttribute("PelotocinoR15")and m:GetAttribute("CharacterIdentity")=="pelotocino")
local joints=0
for _,n in ipairs(m:GetDescendants())do
 if n:IsA("Motor6D")then joints=joints+1;assert((n.Part0.CFrame*n.C0).Position.X==(n.Part1.CFrame*n.C1).Position.X)end
 if n:IsA("BasePart")then assert(n.Transparency==1)end
end
assert(joints==15 and m.HumanoidRootPart.CanTouch)
Renderer.apply(m);assert(m:GetAttribute("PelotocinoVisualReady"))
assert(#m.PelotocinoMeshAppearance:GetChildren()==#Data.meshes and meshCount==#Data.meshes)
for _,part in ipairs(m.PelotocinoMeshAppearance:GetChildren())do assert(part:IsA("MeshPart")and not part.CanCollide and not part.CanQuery and part.Massless)end
local before=meshCount
local npc=Rig.create();npc.Parent=Instance.new("Folder");Renderer.apply(npc)
assert(meshCount==before,"NPC must reuse cached meshes")
assert(#npc.PelotocinoMeshAppearance:GetChildren()==#m.PelotocinoMeshAppearance:GetChildren())
for _,t in ipairs({0,.119,.12,.25,.359,.36,.449,.45,.7,1.03,1.2})do
 local state=Motion.equipment("baconThrow",t);Renderer.update(m,"baconThrow",t)
 assert(state.tuftInHand==(t>=.12 and t<.36))
 assert(state.tuftTossed==(t>=.36 and t<.45))
 for _,part in ipairs(m.PelotocinoMeshAppearance:GetChildren())do
  if part.Name:find("_tuft_")then assert(part.Transparency==((t>=.45 and t<1.02)and 1 or 0))end
 end
end
m:SetAttribute("TrackerUntil",106);m:SetAttribute("TrackerCount",1);Renderer.update(m,"detector",.7)
assert(m.LeftHand.TrackerReadout.Enabled and m.LeftHand.TrackerReadout:GetChildren()[1].Text=="● SEÑAL DETECTADA")
Renderer.update(m,"",10);assert(not m.LeftHand.TrackerReadout.Enabled)
local projectile=Renderer.projectile(m.Parent);assert(projectile.PrimaryPart:IsA("MeshPart")and #projectile:GetChildren()==1)
for _,state in ipairs({"idle","walk","run","sprint","jump","fall","hit","stun","death"})do
 for i=0,60 do local pose=Motion.sample(state,i*.05,24,"",99,{stateTime=i*.05})
  for _,v in pairs(pose)do for _,n in ipairs(v)do assert(n==n and math.abs(n)<10)end end
 end
end
local walking=Motion.sample("walk",.8,16,"",99)
assert(walking.LeftHip[1]*walking.LeftShoulder[1]<0)
assert(Motion.equipment("pan",.22).pan and Motion.equipment("baconThrow",.45).pan)
'''
 run_lua(setup+tests,'R15 conectado, 25 MeshParts, NPC idéntico, caché, equipo, raqueta y rastreador')
 # Fresh renderer cache with a denied API must not manufacture a cube fallback.
 tests=r'''
meshFailure=true
local m=Rig.create();m.Parent=Instance.new("Folder");Renderer.apply(m)
assert(m:GetAttribute("PelotocinoVisualReady")==false and m.Head:FindFirstChild("PelotocinoMeshNotice"))
assert(not m:FindFirstChild("PelotocinoMeshAppearance"))
'''
 run_lua(setup+tests,'API de mallas denegada: aviso explícito, sin cuerpo de cubos')

if __name__=='__main__':art();rig_and_renderer()
