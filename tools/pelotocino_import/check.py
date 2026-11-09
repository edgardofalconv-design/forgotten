"""Behavioral checks with explicit Roblox API doubles; not a Studio test."""
from pathlib import Path
import sys,re,json,hashlib
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from check_playable import run_lua,module,FACTORY_MOCK
from export_preview import MOCK

SETUP=r'''
local time=100;os.clock=function()return time end
Color3.new=function(r,g,b)return Color3.fromRGB(r*255,g*255,b*255)end
UDim2.fromOffset=function(x,y)return {x,y}end
local oldIndex=omt.__index
local function clone(source)
 local all=source:GetDescendants();table.insert(all,1,source);local copies={}
 for _,n in ipairs(all)do copies[n]=Instance.new(n.ClassName)end
 for _,n in ipairs(all)do
  local c=copies[n]
  for k,v in pairs(n.props)do
   if k=="attributes"then c.props.attributes={};for a,b in pairs(v)do c.props.attributes[a]=b end
   elseif k~="Parent"then c.props[k]=copies[v]or v end
  end
  if n~=source then c.Parent=copies[n.Parent]end
 end
 return copies[source]
end
omt.__index=function(o,k)
 if k=="Clone"then return clone end
 if k=="FindFirstChild"then return function(self,name,recursive)
  for _,n in ipairs(recursive and self:GetDescendants()or self:GetChildren())do if n.Name==name then return n end end
 end end
 if k=="Destroy"then return function(self)
  local all=self:GetDescendants();for _,n in ipairs(all)do n.Parent=nil;n.props.ClassName="Destroyed"end
  self.Parent=nil;self.props.ClassName="Destroyed"
 end end
 if k=="PivotTo"then return function(self,frame)
  local change=frame*self.PrimaryPart.CFrame:Inverse()
  for _,n in ipairs(self:GetDescendants())do if n:IsA("BasePart")then n.CFrame=change*n.CFrame end end
 end end
 return oldIndex(o,k)
end
local oldFrame=cmt.__index
cmt.__index=function(o,k)
 if k=="ToObjectSpace"then return function(a,b)return a:Inverse()*b end end
 if k=="Lerp"then return function(a,b,t)local r={};for i=1,9 do r[i]=a.r[i]+(b.r[i]-a.r[i])*t end;return cf(a.p:Lerp(b.p,t),r)end end
 return oldFrame(o,k)
end
services.Players={CreateHumanoidModelFromDescriptionAsync=function()error("native Studio rig API not present in local doubles")end}
services.AssetService=setmetatable({},{__index=function()error("AssetService MUST NOT be used by imported Pelotocino")end})
local RS=Instance.new("Folder");RS.Name="ReplicatedStorage";services.ReplicatedStorage=RS
local SS=Instance.new("Folder");SS.Name="ServerStorage";services.ServerStorage=SS
workspace=Instance.new("Folder");workspace.Name="Workspace";workspace.GetServerTimeNow=function()return time end
require=function(v)return v end;script={Parent={}}
'''

def setup():
 s=MOCK+FACTORY_MOCK+SETUP
 for name,var in [('PelotocinoMeshData','Data'),('PelotocinoMotion','Motion'),('PelotocinoRig','Rig'),('PelotocinoMeshLibrary','Library'),('PelotocinoRenderer','Renderer')]:
  s+=module(name+'.luau',var)+'\nscript.Parent.'+name+'='+var+'\n'
 return s+r'''
local function imported()
 local folder=Instance.new("Model");folder.Name="FBX"
 for i,spec in ipairs(Data.meshes)do
  local part=Instance.new("MeshPart");part.Name=spec.name;part.MeshId="rbxassetid://"..(1000+i);part.TextureID="rbxassetid://2000"
  local _,size=Library.bounds(spec);part.Size=size;part.CFrame=CFrame.new();part.Parent=folder
 end
 return folder
end
local bank=imported();bank.Name="PelotocinoImportedMeshes";bank.Parent=RS
'''

def renderer():
 tests=r'''
local m=Rig.create();m.Parent=workspace
local state=Library.attach(m)
assert(#state.parts==25 and #state.folder:GetChildren()==25)
-- Baked rigs are visible even BEFORE any client renderer is started.
for _,part in ipairs(state.folder:GetChildren())do assert(part:IsA("MeshPart")and part.Transparency==0 and not part.CanCollide)end
local original=state.folder;assert(Renderer.apply(m)and m.PelotocinoMeshAppearance==original)
assert(not m.Head:FindFirstChild("PelotocinoMeshNotice")and m:GetAttribute("PelotocinoVisualReady"))
local npc=Rig.create();npc.Parent=workspace;assert(Renderer.apply(npc))
for _,spec in ipairs(Data.meshes)do
 local a=m.PelotocinoMeshAppearance:FindFirstChild(spec.name);local b=npc.PelotocinoMeshAppearance:FindFirstChild(spec.name)
 assert(a.MeshId==b.MeshId and a.TextureID==b.TextureID and (a.Size-b.Size).Magnitude<.0001)
end
for _,t in ipairs({0,.119,.12,.25,.359,.36,.449,.45,.7,1.03,1.2})do
 Renderer.update(m,"baconThrow",t)
 for _,spec in ipairs(Data.meshes)do if spec.group=="tuft"then
  assert(m.PelotocinoMeshAppearance:FindFirstChild(spec.name).Transparency==((t>=.45 and t<1.02)and 1 or 0))
 end end
end
m:SetAttribute("TrackerUntil",106);m:SetAttribute("TrackerCount",1);Renderer.update(m,"detector",.7)
assert(m.LeftHand.TrackerReadout.Enabled)
local projectile=Renderer.projectile(workspace);assert(projectile.PrimaryPart:IsA("MeshPart")and projectile.PrimaryPart.MeshId~="")
-- A portable, already-baked model does not need a global library to remain visible.
bank.Parent=nil;local portable=m:Clone();portable.Parent=workspace
assert(Renderer.apply(portable)and not portable.Head:FindFirstChild("PelotocinoMeshNotice"))
-- Missing import remains diagnosable, and a later replicated library is retried.
local missing=Rig.create();missing.Parent=workspace;assert(not Renderer.apply(missing))
assert(not missing:FindFirstChild("PelotocinoMeshAppearance")and missing:GetAttribute("PelotocinoSetupError"))
bank.Parent=RS;time=time+2;Renderer.update(missing,"",100)
assert(missing:GetAttribute("PelotocinoVisualReady")and not missing.Head:FindFirstChild("PelotocinoMeshNotice"))
-- Incomplete or renamed imports must never silently become a cube body.
local bad=imported();bad:GetChildren()[1]:Destroy();local _,errors=Library.inspect(bad,true);assert(#errors>0)
local copy=bank:GetChildren()[1]:Clone();copy.Parent=bank
local _,duplicates=Library.inspect(bank,true);assert(#duplicates>0);copy:Destroy()
local image=bank:GetChildren()[1].TextureID;bank:GetChildren()[1].TextureID=""
local _,textures=Library.inspect(bank,true);assert(#textures>0);bank:GetChildren()[1].TextureID=image
'''
 run_lua(setup()+tests,'MeshParts persistentes visibles, jugador/NPC idénticos, montaje conservado, combate visual, reintento y cero AssetService')

def installer():
 s=setup()+r'''
local running=false;local preloadFails=false;local selection={};local waypoint=0;local preloadCalls=0
services.RunService={IsStudio=function()return true end,IsRunning=function()return running end}
services.Selection={Get=function()return selection end,Set=function(_,v)selection=v end}
services.ChangeHistoryService={SetWaypoint=function()waypoint=waypoint+1 end}
services.ContentProvider={PreloadAsync=function(_,assets,callback)
 preloadCalls=preloadCalls+1;assert(#assets==25)
 for _,part in ipairs(assets)do callback(part.MeshId,preloadFails and Enum.AssetFetchStatus.Failure or Enum.AssetFetchStatus.Success)end
end}
RS.Shared={PelotocinoMeshLibrary=Library,PelotocinoMeshData=Data}
local templates=Instance.new("Folder");templates.Name="PelotocinoSetupTemplates";templates.Parent=SS
local t=Rig.create();t.Name="Pelotocino_R15";t.Parent=templates
local n=Rig.create();n.Name="Pelotocino_NPC";n:SetAttribute("NPC",true);n.Parent=templates
'''
 s+='\nlocal Installer=(function()\n'+(ROOT/'tools/pelotocino_import/StudioInstall.luau').read_text()+'\nend)()\n'
 tests=r'''
local source=imported();source.Parent=workspace;selection={source}
running=true;assert(not pcall(Installer.install));assert(preloadCalls==0 and waypoint==0);running=false
preloadFails=true;assert(not pcall(Installer.install));assert(RS.PelotocinoImportedMeshes==bank and not workspace:FindFirstChild("PelotocinoRevision"));preloadFails=false
local result=Installer.install(source)
assert(result.meshCount==25 and waypoint==2 and result.library.Parent==RS)
assert(bank.Parent==result.backup and SS.CharacterModels.pelotocino:GetAttribute("PelotocinoImported"))
assert(source.Parent==result.backup,"unrigged source must not remain as a collidable duplicate in Workspace")
for _,model in ipairs({result.playable,result.npc,SS.CharacterModels.pelotocino})do
 assert(#model.PelotocinoMeshAppearance:GetChildren()==25)
 for _,part in ipairs(model.PelotocinoMeshAppearance:GetChildren())do assert(part.Transparency==0)end
end
local first=result.library;local oldReview=workspace.PelotocinoRevision
result=Installer.install(source)
assert(first.Parent==result.backup and oldReview.Parent==result.backup and result.library~=first)
local broken=imported();broken:GetChildren()[1].MeshId=""
assert(not pcall(Installer.install,broken));assert(RS.PelotocinoImportedMeshes==result.library)
'''
 run_lua(s+tests,'instalador: solo edición, validación de descarga, instalación de 25 mallas y backups sin sobrescritura')

def protected():
 expected=json.loads((ROOT/'backups/pre-pelotocino-import-protected.json').read_text());checked={}
 for name,digest in expected.items():
  p=ROOT/name
  if not p.exists():
   assert not(ROOT/'.git').exists(),'Entrega anterior ausente: '+name
   continue
  assert hashlib.sha256(p.read_bytes()).hexdigest()==digest,name
  checked[name]=digest
 for filename in ['PelotocinoRenderer.luau','PelotocinoMeshLibrary.luau']:
  text=(ROOT/'src/shared'/filename).read_text()
  assert not re.search(r'(CreateEditableMesh|CreateMeshPartAsync|CreateEditableImage|CreateSurfaceAppearanceAsync)\s*\(',text)
 print('PASS: '+str(len(checked))+' archivos anteriores intactos; Pelotocino no crea mallas/imágenes en partidas')
 return checked

if __name__=='__main__':protected();renderer();installer()
