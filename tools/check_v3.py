"""V3-specific regressions. No Studio/physics/catalog access is claimed."""
from pathlib import Path
import json,math,hashlib
from check_playable import ROOT,run_lua,module
from export_preview import MOCK

def motion():
    tests=r'''
local signatures={}
for id in pairs(Motion.profiles) do
 for _,state in ipairs({"idle","walk","run","sprint","jump","fall","land","hit","stun","death","medkit","drink","repairGenerator"}) do
  for _,phase in ipairs({0,.2,.6,1.1,3}) do
   local p=Motion.sample(id,state,phase,24,"",100,{stateTime=phase})
   assert(p.RootJoint and p.Neck and p.LeftHip and p.RightShoulder)
   for _,v in pairs(p) do for _,number in ipairs(v) do assert(number==number and math.abs(number)<100) end end
  end
 end
 local p=Motion.sample(id,"sprint",.7,24,"",100)
 signatures[id]=string.format("%.4f:%.4f:%.4f",p.LeftHip[1],p.RightShoulder[1],p.RootJoint[1])
 for action,duration in pairs(Motion.durations) do
  for _,time in ipairs({0,.1,duration*.5,duration-.01,duration+1}) do
   local p=Motion.sample(id,"idle",.5,0,action,time)
   for _,v in pairs(p) do for _,n in ipairs(v)do assert(n==n and math.abs(n)<100)end end
  end
 end
 for _,kind in ipairs({"victory","mvp","results"}) do assert(Motion.presentation(id,kind,.5).RightShoulder) end
end
for id,signature in pairs(signatures) do for other,value in pairs(signatures)do if id~=other then assert(signature~=value,id.." has generic motion")end end end
local reach=Motion.sample("pelotocino","idle",0,0,"baconThrow",.2)
local throw=Motion.sample("pelotocino","idle",0,0,"baconThrow",.6)
assert(math.abs(reach.RightShoulder[1]-throw.RightShoulder[1])>.4)
assert(Motion.sample("yellowguy","death",0,0,"",100,{stateTime=1}).RootJoint[3]<-1)
assert(Motion.jointKey("Root")=="RootJoint" and Motion.jointKey("Left Shoulder")=="LeftShoulder")
-- Native R6 and R15 axes must reach forward (-Z), with the same body-space pose.
local pose=Motion.sample("deathspeaker","idle",0,0,"plasma",.42).RightShoulder
local baseline=CFrame.new(pose[4],pose[5],pose[6])*CFrame.Angles(pose[1],pose[2],pose[3])
assert((baseline*CFrame.new(0,-1.5,0)).Position.Z<-.9,"arm is aiming backwards")
for _,basis in ipairs({CFrame.new(),CFrame.Angles(0,math.pi/2,0),CFrame.Angles(-math.pi/2,0,math.pi)}) do
 local joint={C0=CFrame.new(1,.5,0)*basis}
 local transformed=basis*Motion.toTransform(joint,pose)*basis:Inverse()
 for i,v in ipairs(transformed.r)do assert(math.abs(v-baseline.r[i])<1e-6)end
 assert((transformed.Position-baseline.Position).Magnitude<1e-6)
end
local walk=Motion.sample("pelotocino","walk",.8,16,"",100)
assert(walk.LeftHip[1]*walk.LeftShoulder[1]<0,"same-side arm and leg move together")
'''
    run_lua(MOCK+module('PelotocinoMotion.luau','PMotion')+'\nrequire=function(v)return v end;script={Parent={PelotocinoMotion=PMotion}}\n'+module('CharacterMotion.luau','Motion')+tests,'V3: trece estados, clips, ejes R6/R15, ataque hacia delante, muerte, MVP y seis firmas de movimiento')

def catalog():
    from check_catalog_character import MOCK as BASE
    setup=r'''
local searches=0;local searchFailure=false;local wrongCreator=false;local requestedBundle
Instance={new=function()return {}end}
Enum.AvatarAssetType={HairAccessory="HairAccessory"};Enum.BundleType={BodyParts="BodyParts"}
CatalogSearchParams={new=function()return {}end}
local Editor={SearchCatalogAsync=function(_,params)
 searches=searches+1;assert(params.CreatorName=="Roblox")
 if searchFailure then error("catalog inaccessible") end
 local name=params.SearchKeyword
 if name=="Pal Hair" then assert(params.AssetTypes[1]=="HairAccessory") else assert(params.BundleTypes[1]=="BodyParts") end
 return {GetCurrentPage=function()return {
  {Name=name,Id=66,CreatorName="Impostor"},
  {Name=name,Id=name=="Pal Hair" and 101 or 202,CreatorName=wrongCreator and "Impostor" or "Roblox"}}
 end}
end}
AssetService.GetBundleDetailsAsync=function(_,id)
 requestedBundle=id;assert(id==202)
 return {Name="Korblox Deathspeaker",Items={{Type="UserOutfit",Id=303}}}
end
Players.GetHumanoidDescriptionFromOutfitIdAsync=function(_,id)assert(id==303);return description()end
Players.CreateHumanoidModelFromDescriptionAsync=function(_,desc,rig)
 if desc.HairAccessory then assert(desc.HairAccessory=="101")end
 return makeModel(rig)
end
local originalService=game.GetService
game.GetService=function(self,name)if name=="AvatarEditorService"then return Editor end;return originalService(self,name)end
'''
    source=(ROOT/'src/shared/AvatarCatalog.luau').read_text()
    tests=r'''
local a=loadAvatarCatalog();assert(a.load())
local yellow=a.clone("yellowguy");assert(yellow.h.RigType=="R6" and yellow:GetAttribute("CharacterIdentity")=="yellowguy")
assert(not yellow:GetAttribute("OfficialCatalogBody") and not a.clone("junkbot"))
local bacon=a.clone("pelotocino");assert(bacon:GetAttribute("OfficialBaconHair") and bacon:GetAttribute("ResolvedHairAssetId")==101)
local death=a.clone("deathspeaker");assert(death.h.RigType=="R15" and death:GetAttribute("OfficialCatalogBody") and death:GetAttribute("ResolvedBundleId")==202)
assert(requestedBundle==202)
local before=searches;assert(not a.load() and searches==before)
time=time+91;assert(not a.load() and searches==before)
searchFailure=true;a=loadAvatarCatalog();assert(a.load())
assert(a.clone("yellowguy") and not a.clone("deathspeaker") and not a.clone("pelotocino"):GetAttribute("OfficialBaconHair"))
before=searches;assert(not a.load() and searches==before)
time=time+91;searchFailure=false;assert(a.load() and a.clone("deathspeaker"))
wrongCreator=true;a=loadAvatarCatalog();assert(a.load());assert(not a.clone("deathspeaker") and not a.clone("pelotocino"):GetAttribute("OfficialBaconHair"))
'''
    run_lua(BASE+setup+'\nlocal function loadAvatarCatalog()\n'+source+'\nend\n'+tests,'V3: búsqueda oficial sin IDs inventados, rechazo de impostor, caché, fallo y recuperación')

def geometry():
    data=json.loads((ROOT/'assets/v3/character-geometry.json').read_text())
    assert set(data)=={'pelotocino','yellowguy','junkbot','deathspeaker','guest666','tubers93'}
    for id,items in data.items():
        for s in items:
            assert all(0<=c<=255 for c in s['color'])
            if 'size' in s:assert all(math.isfinite(x) and x>0 for x in s['size'])
            for p in s.get('vertices',[]):assert len(p)==3 and all(math.isfinite(x) for x in p)
            for f in s.get('faces',[]):
                assert len(set(f))==3 and min(f)>=0 and max(f)<len(s['vertices'])
                a,b,c=(s['vertices'][i] for i in f)
                u=[b[i]-a[i] for i in range(3)];v=[c[i]-a[i] for i in range(3)]
                n=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]
                assert sum(x*x for x in n)>1e-12,(id,s['name'],'degenerate triangle')
    yellow=data['yellowguy'];assert any(s['name']=='Baston' for s in yellow)
    assert not any(s['name'].lower().find('robot')>=0 or s.get('body') for s in yellow)
    assert all('capa' not in s['name'].lower() and 'cuerno' not in s['name'].lower() for s in data['guest666'])
    blade=next(s for s in data['tubers93'] if s['name']=='Hoja curva continua')
    assert blade['anchor']=='RightArm' and max(v[0] for v in blade['vertices'])>2
    for name,digest in json.loads((ROOT/'backups/pre-v3-protected.json').read_text()).items():
        path=ROOT/'dist'/name
        if path.exists():assert hashlib.sha256(path.read_bytes()).hexdigest()==digest,name
    print('PASS: V3: geometría finita, siluetas, bastón/guadaña, Guest sin capa y V1/V2 intactas')

def effects():
    from check_v2 import COMMON
    setup=r'''
local previousWrite=omt.__newindex
omt.__newindex=function(o,k,v)
 if k=="Position" or k=="Size" and (o.ClassName=="Part" or o.ClassName=="WedgePart" or o.ClassName=="MeshPart") then assert(getmetatable(v)==vmt,"Expected Vector3: "..k) end
 previousWrite(o,k,v)
end
local previousRead=omt.__index
omt.__index=function(o,k)
 if k=="PivotTo" then return function(self,frame)self.PrimaryPart.CFrame=frame end end
 return previousRead(o,k)
end
ColorSequence={new=function(c)return c end}
NumberSequence={new=function(v)return v end};NumberSequenceKeypoint={new=function(t,v)return {t,v}end}
NumberRange={new=function(a,b)return {a,b}end}
TweenInfo={new=function(d)return d end}
local cleanup={};local delays={}
local originalRead=omt.__index
omt.__index=function(o,k)if k=="Emit" then return function(_,count)assert(count>0 and count<=20)end end;return originalRead(o,k)end
task.delay=function(d,fn)table.insert(delays,fn)end
services.Debris={AddItem=function(_,item,d)assert(d>0);table.insert(cleanup,item)end}
services.TweenService={Create=function()return {Play=function()end}end}
services.SoundService={}
services.RunService={RenderStepped=signal()}
script={Parent={Music={sfx={}}}}
'''
    tests=r'''
local fx=CreateEffects(function()return true end)
local actor=Instance.new("Model");actor.Parent=workspace
local hand=Instance.new("Part");hand.Name="Right Arm";hand.CFrame=CFrame.new(0,3,0);hand.Parent=actor
local torso=Instance.new("Part");torso.Name="Torso";torso.CFrame=CFrame.new(0,3,0);torso.Parent=actor
for _,ability in ipairs({"plasma","overdrive","selfRepair"}) do fx.effect({kind="skill",ability=ability,model=actor,position=Vector3.new(0,3,0)}) end
for _,ability in ipairs({"scythe","spin","cane","pan","claw","punch"}) do
 fx.effect({kind="melee",ability=ability,model=actor,position=Vector3.new(),color="red"})
end
local trails=0
for _,n in ipairs(nodes)do if n.ClassName=="Trail" then
 trails=trails+1;assert(n.Attachment0.Parent==hand and n.Attachment1.Parent==hand)
 assert(n.Lifetime==.15)
end end
assert(trails==5)
for _,kind in ipairs({"bacon","cane"}) do
 fx.effect({kind="projectile",projectile=kind,position=Vector3.new(0,3,0),finish=Vector3.new(0,3,-10),duration=.5})
end
advance(.25);services.RunService.RenderStepped:Fire()
local flying=0
for _,n in ipairs(nodes)do if n.ClassName=="Model" and n.Name and n.Name:find("Proyectil")then
 flying=flying+1;assert(n.PrimaryPart.Position.Y>3 and math.abs(n.PrimaryPart.Position.Z+5)<.01)
 local expected=n.Name=="Proyectil_cane" and "Empuñadura curva" or "Mechón Bacon 0"
 assert(n:FindFirstChild(expected),"missing authored projectile geometry")
 if n.Name=="Proyectil_cane" then assert(#n:GetChildren()==4,"cane projectile must not include the avatar or hair") end
end end
assert(flying==2 and #cleanup>=17)
advance(.3);services.RunService.RenderStepped:Fire()
for _,fn in ipairs(delays)do fn()end
'''
    source=MOCK+COMMON+setup+module('CharacterVisualData.luau','Data')+'\nscript.Parent.CharacterVisualData=Data\n'
    source+=module('VisualGeometry.luau','Geometry')+'\nscript.Parent.VisualGeometry=Geometry\n'
    run_lua(source+module('ClientEffects.luau','CreateEffects')+tests,'V3: estelas locales, tipos Vector3, proyectiles propios, arco y final de vuelo simulados')

if __name__=='__main__':
    motion();catalog();geometry();effects()
