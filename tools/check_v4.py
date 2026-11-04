"""V4 character/art regressions. Local Lua doubles, not a Studio execution."""
import json,hashlib,math
from check_playable import ROOT,run_lua,module,FACTORY_MOCK
from export_preview import MOCK
from check_v3 import motion,catalog,effects

def visuals():
 data=json.loads((ROOT/'assets/v4/character-geometry.json').read_text())
 profiles=json.loads((ROOT/'assets/v4/rig-proportions.json').read_text())
 assert len(data)==6 and profiles['pelotocino']['torso'][0]==1.44
 assert (profiles['pelotocino']['armX']*2+profiles['pelotocino']['arm'][0])/4<=.71
 yellow=data['yellowguy'];assert sum(s.get('weapon')=='cane' for s in yellow)==3
 assert any('rubio elevado' in s['name'] for s in yellow)
 assert not any('robot' in s['name'].lower() for s in yellow)
 for name,items in data.items():
  for s in items:
   for v in s.get('vertices',[]):assert all(math.isfinite(n) for n in v)
   for face in s.get('faces',[]):
    assert len(set(face))==3 and min(face)>=0 and max(face)<len(s['vertices'])
    a,b,c=[s['vertices'][i] for i in face];u=[b[i]-a[i] for i in range(3)];v=[c[i]-a[i] for i in range(3)]
    cross=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]
    assert sum(n*n for n in cross)>1e-12,(name,s['name'])
 for name,digest in json.loads((ROOT/'backups/pre-v4-protected.json').read_text()).items():
  p=ROOT/'dist'/name
  if p.exists():assert hashlib.sha256(p.read_bytes()).hexdigest()==digest,name
 print('PASS: V4: silueta 30 % más estrecha, Yellow Guy independiente, tres piezas de bastón y geometría válida; entregas protegidas')

def rigs():
 setup=MOCK+FACTORY_MOCK+'\nrequire=function(m)return m end;script={Parent={}}\n'
 for file,var in [('RigProfileData','Profiles'),('RigProportions','Proportions'),('CharacterVisualData','Data'),('VisualGeometry','Geometry'),('FaceData','Faces'),('CharacterVisuals','Visuals'),('Roster','roster')]:
  setup+=module(file+'.luau',var)+'\nscript.Parent.'+file+'='+var+'\n'
 setup+='\nscript.Parent.CatalogCharacter={clone=function()end};script.Parent.AvatarCatalog={clone=function()end};script.Parent.ImportedAppearance={apply=function()return false end};script.Parent.Appearance={}\n'
 tests=r'''
for _,entry in ipairs(roster) do
 nodes={};local m=Factory.create(entry);assert(Factory.validate(m,entry.id))
 local profile=Profiles[entry.id]
 if profile then
  assert(m.Torso.Size.X==profile.torso[1] and m["Right Arm"].Size.X==profile.arm[1])
  assert(math.abs(m.Torso["Right Shoulder"].C0.Position.X-profile.torso[1]/2)<.001)
  assert(math.abs(m.Torso["Right Shoulder"].C1.Position.X+profile.arm[1]/2)<.001)
  assert(m:GetAttribute("RigProportionsVersion")==4)
 end
 if entry.id=="yellowguy" then
  assert(not m.Head:FindFirstChild("ClassicSmile") and m.Head:FindFirstChild("RostroYellowGuyMount"))
  local weapon=0;local appearance=m:FindFirstChild("ForgottenAppearance")
  for _,group in ipairs(appearance:GetChildren())do if group:GetAttribute("WeaponKind")=="cane" then weapon=weapon+1 end end
  assert(weapon==3)
  assert(m["Left Leg"].Color.G<.2 and m.Head.Color.R>.9)
 end
 for _,node in ipairs(m:GetDescendants())do
  if node.Name and node.Name:find("Mount$")then assert(node.Transparency==1 and not node.CanCollide and not node.CanQuery and node.Massless)end
 end
end
'''
 run_lua(setup+module('CharacterFactory.luau','Factory')+tests,'V4: proporciones, hombros, rig conectado, cara propia, ropa oscura y aislamiento del bastón')
 test=r'''
local p=Motion.sample("tubers93","idle",0,0,"scythe",.28).RightShoulder
local tip=(CFrame.Angles(p[1],p[2],p[3])*CFrame.new(0,2,-.65)).Position
assert(tip.Z<-1,"scythe contact points behind the character")
'''
 run_lua(MOCK+module('CharacterMotion.luau','Motion')+test,'V4: filo de guadaña delante del personaje en el contacto')

if __name__=='__main__':
 visuals();rigs();motion();catalog();effects()
