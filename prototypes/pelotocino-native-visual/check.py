"""Local behavior doubles, not Roblox Studio. Run from the full repository."""
from pathlib import Path
import hashlib, json, sys, xml.etree.ElementTree as E

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT/'dist/pelotocino-native-visual'
sys.path.insert(0, str(ROOT/'tools'))
from check_playable import run_lua, FACTORY_MOCK
from export_preview import MOCK
from pelotocino_import.check import SETUP

HARNESS = r'''
vmt.__mul=function(a,b)
 if type(a)=="number"then a,b=b,a end
 if type(b)=="table"then return vec(a.X*b.X,a.Y*b.Y,a.Z*b.Z)end
 return vec(a.X*b,a.Y*b,a.Z*b)
end
vmt.__tostring=function(v)return string.format("%.6f,%.6f,%.6f",v.X,v.Y,v.Z)end
cmt.__tostring=function(c)return tostring(c.p)..":"..table.concat(c.r,",")end
local oldInstance=Instance.new
Instance.new=function(class)
 local o=oldInstance(class);o.Name=class;o.Archivable=true
 if o:IsA("BasePart")then
  o.Size=Vector3.new(1,1,1);o.CFrame=CFrame.new();o.Color=Color3.fromRGB(255,255,255)
  o.Transparency=0;o.Material="Plastic";o.MeshId="";o.TextureID=""
 end
 return o
end
local inherited=omt.__index
omt.__index=function(o,key)
 if key=="IsA"then return function(self,class)
  return inherited(self,"IsA")(self,class)or(class=="LuaSourceContainer"and(self.ClassName=="Script"or self.ClassName=="ModuleScript"or self.ClassName=="LocalScript"))
   or(class=="JointInstance"and(self.ClassName=="Weld"or self.ClassName=="Motor6D"))
 end end
 return inherited(o,key)
end
local clock=0
os.date=function()clock=clock+1;return tostring(clock)end
local running=false
services.RunService={IsStudio=function()return true end,IsRunning=function()return running end}
local selection={}
services.Selection={Get=function()return selection end,Set=function(_,values)selection=values end}
local loadFailure=false
services.ContentProvider={PreloadAsync=function(_,instances,callback)
 assert(#instances==1);callback("local-test-asset",loadFailure and "Failure"or"Success")
end}
CatalogSearchParams={new=function()return {}end}
local infos={
 [9001]={Name="Pal Hair",AssetTypeId=41,Creator={CreatorTargetId=1,CreatorType="User"}},
 [9002]={Name="Blue and Black Motorcycle Shirt",AssetTypeId=11,Creator={CreatorTargetId=1,CreatorType="User"}},
 [9003]={Name="Dark Green Jeans",AssetTypeId=12,Creator={CreatorTargetId=1,CreatorType="User"}},
}
local catalogBlocked=false
services.MarketplaceService={GetProductInfoAsync=function(_,id)
 assert(not catalogBlocked,"catalog blocked");return assert(infos[id])
end}
services.AvatarEditorService={SearchCatalogAsync=function(_,params)
 assert(not catalogBlocked,"catalog blocked")
 assert(params.CreatorId==1 and params.CreatorType=="User"and params.CreatorName==nil)
 local page={}
 for id,info in pairs(infos)do if info.Name==params.SearchKeyword then table.insert(page,{Id=id,Name=info.Name})end end
 return{IsFinished=true,GetCurrentPage=function()return page end}
end}
local changeBody=false
local function appliedDescription()
 local d=Instance.new("HumanoidDescription");d.Torso=7755
 d.SetAccessories=function()end
 return d
end
local function applyDescription(self,d)
 assert(d.Torso==7755,"the original body description must be used")
 assert(d.HairAccessory=="9001"and d.Shirt==9002 and d.Pants==9003)
 assert(d.WidthScale==.8 and d.Face==0)
 local rig=self.Parent
 local shirt=Instance.new("Shirt");shirt.ShirtTemplate="fixture:shirt";shirt.Parent=rig
 local pants=Instance.new("Pants");pants.PantsTemplate="fixture:pants";pants.Parent=rig
 local hair=Instance.new("Accessory");hair.Name="Pal Hair";hair.AccessoryType="Hair";hair.Parent=rig
 local handle=Instance.new("MeshPart");handle.Name="Handle";handle.MeshId="fixture:official-hair";handle.Parent=hair
 if changeBody then rig.UpperTorso.MeshId="fixture:wrong-body"end
end
local function nativeFixture()
 local rig=Instance.new("Model");rig.Name="Rig";rig.Parent=workspace
 local h=Instance.new("Humanoid");h.Parent=rig;h.RigType="R15"
 h.GetAppliedDescription=appliedDescription;h.ApplyDescriptionAsync=applyDescription
 h.AddAccessory=function(self,acc)
  acc.Parent=self.Parent
  local weld=Instance.new("Weld");weld.Name="AccessoryWeld";weld.Parent=acc.Handle
  weld.Part0=acc.Handle;weld.Part1=self.Parent.UpperTorso
  weld.C0=acc.Handle.BodyBackAttachment.CFrame;weld.C1=self.Parent.UpperTorso.BodyBackAttachment.CFrame
 end
 local root=Instance.new("Part");root.Name="HumanoidRootPart";root.Parent=rig;rig.PrimaryPart=root
 for _,name in ipairs({"Head","UpperTorso","LowerTorso","LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand","LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"})do
  local p=Instance.new("MeshPart");p.Name=name;p.MeshId="fixture:"..name;p.Parent=rig
  local joint=Instance.new("Motor6D");joint.Name=name.."Joint";joint.Part0=root;joint.Part1=p;joint.C0=CFrame.new();joint.C1=CFrame.new();joint.Parent=p
 end
 local a=Instance.new("Attachment");a.Name="BodyBackAttachment";a.CFrame=CFrame.new(0,0,.34);a.Parent=rig.UpperTorso
 local script=Instance.new("Script");script.Name="Animate";script.Parent=rig
 return rig
end
local function accessoryFixture()
 local model=Instance.new("Model");model.Name="Imported";model.Parent=workspace
 for _,name in ipairs({"Backpack","Pan","Tracker"})do
  local part=Instance.new("MeshPart");part.Name=name;part.MeshId="fixture:"..name;part.TextureID="fixture:atlas";part.Parent=model
 end
 return model
end
'''

def load(name, variable):
    return '\nlocal '+variable+'=(function()\n'+(HERE/name).read_text()+'\nend)()\n'

TESTS = r'''
assert(Catalog.validate(infos[9001],Config.Resources.Hair))
for _,bad in ipairs({
 {Name="Pal Hair",AssetTypeId=41,Creator={CreatorTargetId=42,CreatorType="User"}},
 {Name="Pal Hair",AssetTypeId=41,Creator={CreatorTargetId=1,CreatorType="Group"}},
 {Name="Fake Hair",AssetTypeId=41,Creator={CreatorTargetId=1,CreatorType="User"}},
 {Name="Pal Hair",AssetTypeId=11,Creator={CreatorTargetId=1,CreatorType="User"}},
})do assert(not pcall(Catalog.validate,bad,Config.Resources.Hair))end
infos[9004]=infos[9001];assert(not pcall(Catalog.resolveOne,Config.Resources.Hair));infos[9004]=nil
local rig=nativeFixture();local imported=accessoryFixture()
assert(Workshop.validateRig(rig))
rig:SetAttribute("PelotocinoR15",true);assert(not pcall(Workshop.validateRig,rig));rig:SetAttribute("PelotocinoR15",nil)
local joint=rig.LeftHand.LeftHandJoint;local originalP1=joint.Part1;joint.Part1=nil
assert(not pcall(Workshop.validateRig,rig));joint.Part1=originalP1
local function stages()
 local count=0;for _,n in ipairs(workspace:GetChildren())do if n.Name:find("PelotocinoVisual_")then count=count+1 end end;return count
end
running=true;assert(not pcall(Workshop.install,rig,imported));running=false
catalogBlocked=true;assert(not pcall(Workshop.install,rig,imported));catalogBlocked=false;assert(stages()==0)
loadFailure=true;assert(not pcall(Workshop.install,rig,imported));loadFailure=false;assert(stages()==0)
local tracker=imported.Tracker;tracker.Parent=nil
assert(not pcall(Workshop.install,rig,imported));tracker.Parent=imported
local duplicate=tracker:Clone();duplicate.Parent=imported
assert(not pcall(Workshop.install,rig,imported));duplicate:Destroy()
changeBody=true;assert(not pcall(Workshop.install,rig,imported));changeBody=false;assert(stages()==0)
-- End-to-end decisions with native Roblox calls replaced by explicit fixtures.
selection={rig,imported};local stage=Workshop.install()
assert(stage:GetAttribute("ReadyForVisualReview")and not stage:GetAttribute("AppearanceApproved"))
local a,b=stage.Pelotocino_Visual,stage.Pelotocino_NPC_Visual
assert(Workshop.assertSameAppearance(a,b))
assert(a.Pelotocino_Backpack.Handle.AccessoryWeld.Part1==a.UpperTorso)
assert(b.Pelotocino_Backpack.Handle.AccessoryWeld.Part1==b.UpperTorso)
assert(#stage.Equipo_SoloVisual:GetChildren()==2)
assert(rig:FindFirstChild("Animate")and not a:FindFirstChild("Animate"))
assert(not rig:FindFirstChildOfClass("Shirt")and #imported:GetChildren()==3)
assert(workspace:GetAttribute("PelotocinoVisualActive")==stage.Name)
for _,part in ipairs(a:GetDescendants())do if part:IsA("BasePart")then assert(part.Anchored and not part.CanCollide)end end
b.Pelotocino_Backpack.Handle.TextureID="fixture:wrong"
assert(not pcall(Workshop.assertSameAppearance,a,b))
local again=Workshop.install(rig,imported);assert(again~=stage and stages()==2)
'''

def main():
    for p in HERE.glob('*.py'): compile(p.read_text(), str(p), 'exec')
    for p in HERE.glob('*.luau'): run_lua(p.read_text(), p.name+' syntax', execute=False)
    source = MOCK+FACTORY_MOCK+SETUP+HARNESS+load('Config.luau','Config')+'script.Parent.Config=Config\n'
    source += load('Catalog.luau','Catalog')+'script.Parent.Catalog=Catalog\n'+load('Workshop.luau','Workshop')+TESTS
    run_lua(source, 'official resource checks, R15 validation, rollback, same appearance, isolated install (API doubles)')
    workshop = (HERE/'Workshop.luau').read_text()
    for forbidden in ['CreateEditableMesh', 'CreateMeshPartAsync', 'CreateHumanoidModel', 'Instance.new("Part")',
                      'Instance.new("MeshPart")', 'AnimationTrack', 'LoadAnimation']:
        assert forbidden not in workshop
    for path in [OUT/'Pelotocino-R15-Taller.rbxlx', OUT/'Herramientas-Pelotocino-R15.rbxmx']:
        tree = E.parse(path); nodes = tree.findall('.//Item')
        refs = [n.attrib['referent'] for n in nodes]; assert len(refs) == len(set(refs))
        assert not tree.findall('.//Item[@class="Humanoid"]'), 'Do not ship a fake body'
        assert not tree.findall('.//Item[@class="MeshPart"]'), 'Accessories require official import'
        for n in nodes:
            if n.attrib['class'] == 'ModuleScript':
                name = n.find("Properties/string[@name='Name']").text
                assert n.find('Properties/ProtectedString').text == (HERE/(name+'.luau')).read_text()
    meta = json.loads((OUT/'accesorios/manifest.json').read_text())
    assert meta['geometry_max_error_fbx_round_trip'] < 1e-5 and not meta['studio_executed']
    assert meta['groups'] == ['Backpack','Pan','Tracker'] and meta['triangles'] == 5020
    for name, expected in meta['files'].items():
        assert hashlib.sha256((OUT/'accesorios'/name).read_bytes()).hexdigest() == expected
    original = json.loads((ROOT/'assets/pelotocino/geometry.json').read_text())
    actual = json.loads((OUT/'accesorios/accesorios-source.json').read_text())['meshes']
    for s in actual:
        old = next(m for m in original['meshes'] if m['name'] == s['name'])
        assert s['group'] in ['backpack', 'pan', 'tracker']
        assert all(s[k] == old[k] for k in ['vertices','faces','normals','colors'])
    result = 'PASS: local API doubles, Lua syntax, native-body guard, rollback, identical visual copies, XML, accessory-only FBX/UV/textures.\nNOT RUN: Roblox Studio, official catalog loading, Avatar Setup, live appearance/screenshots.\n'
    (OUT/'VALIDACION.txt').write_text(result)
    print(result)

if __name__ == '__main__': main()
