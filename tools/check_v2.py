"""Behavior tests of actual V2 modules using Lua 5.4 and explicit Roblox API doubles.
Not a replacement for Studio physics, networking, rendering or live DataStores.
"""
from check_playable import ROOT, run_lua, module, FACTORY_MOCK, FACTORY_TESTS, RULE_TESTS
from export_preview import MOCK
import json
from collections import deque

def server(name, variable):
    return '\nlocal '+variable+'=(function()\n'+(ROOT/'src/server'/name).read_text()+'\nend)()\n'

COMMON = r'''
local time=10
os.clock=function()return time end
os.time=function()return math.floor(time)+10000 end
local function advance(dt)time=time+dt end
workspace={GetServerTimeNow=function()return time end}
task={spawn=function()end,wait=function(dt)advance(dt or .1)end}
warn=function()end
require=function(value)return value end
local function signal()
 local handlers={}
 return {Connect=function(_,fn)
  local h={fn=fn,active=true};table.insert(handlers,h)
  return {Disconnect=function()h.active=false end}
 end,Fire=function(_,...)for _,h in ipairs(handlers) do if h.active then h.fn(...) end end end}
end
local oldIndex=omt.__index
omt.__index=function(o,key)
 if key=="Triggered" then o.props[key]=o.props[key] or signal();return o.props[key] end
 if key=="SetAttribute" then return function(self,k,v)self.props[k]=v end end
 if key=="GetAttribute" then return function(self,k)return self.props[k]end end
 return oldIndex(o,key)
end
local oldNew=Instance.new
Instance.new=function(class,parent)
 local o=oldNew(class,parent)
 if class=="ProximityPrompt" then o.Enabled=true end
 if class=="Part" then o.CanCollide=true end
 return o
end
local services={ReplicatedStorage={Shared={}}}
local Shared=services.ReplicatedStorage.Shared
game={JobId="test-session",GetService=function(_,name)return assert(services[name],name)end}
'''
WORLD = (ROOT/'src/server/World.luau').read_text().split('function World.part',1)[1].split('function World.build',1)[0]
WORLD = '\nlocal World={}\nfunction World.part'+WORLD+'\nscript={Parent={World=World}}\n'

def rules_and_rigs():
    # Preserve and extend all V1 assertions; capsule collection now requires deposit.
    tests=RULE_TESTS.replace('r:collectCapsule(i)', 'r:collectCapsule(i,42)')
    tests=tests.replace('assert(not r:collectCapsule(i,42)) end', 'assert(not r:collectCapsule(i,42));r:depositCapsules(42) end')
    tests=tests.replace('assert(r:collectCapsule(i,42)) end', 'assert(r:collectCapsule(i,42));r:depositCapsules(42) end')
    tests=tests.replace('r:collectCapsule(i,42) end', 'r:collectCapsule(i,42);r:depositCapsules(42) end')
    tests+=r'''
local r=Rules.new(false)
r:completeGenerator(1);r:completeGenerator(2)
for i=1,3 do r:completePuzzle(i);assert(r:collectCapsule(i,42)) end
r:tick(r.remaining-60)
assert(r:carried(42)==3 and r.capsuleCount==0 and not r.gateOpen)
assert(#r:depositCapsules(7)==0 and not r.gateOpen)
assert(#r:dropCapsules(42)==3 and r:carried(42)==0)
for i=1,3 do assert(r:collectCapsule(i,7)) end
assert(#r:depositCapsules(7)==3 and r.gateOpen and r.capsuleCount==3)
assert(#r:depositCapsules(7)==0 and #r:dropCapsules(7)==0)
assert(not r:collectCapsule(1,42) and r:carried(7)==0)
energy.value=1;energy.requested=true
Stamina.step(energy,.5,true,true);assert(energy.value==100 and energy.running)
'''
    core=module('RoundRules.luau','Rules')+module('Stamina.luau','Stamina')+module('RoleAssignment.luau','Assignment')+module('Roster.luau','roster')
    run_lua(MOCK+core+tests,'V2: reglas V1 + recoger/depositar/soltar cápsulas, LMS y bebida')
    factory=(MOCK+FACTORY_MOCK+module('Appearance.luau','Appearance')+module('ImportedAppearance.luau','Imported')
        +module('Roster.luau','roster')+'\nscript={Parent={Appearance=Appearance,ImportedAppearance=Imported,CatalogCharacter={clone=function()return nil end},AvatarCatalog={clone=function()return nil end}}}\nrequire=function(m)return m end\n'
        +module('CharacterVisualData.luau','VisualData')+'\nscript.Parent.CharacterVisualData=VisualData\n'
        +module('VisualGeometry.luau','Geometry')+'\nscript.Parent.VisualGeometry=Geometry\n'
        +module('RigProfileData.luau','RigProfiles')+'\nscript.Parent.RigProfileData=RigProfiles\n'
        +module('RigProportions.luau','Proportions')+'\nscript.Parent.RigProportions=Proportions\n'
        +module('FaceData.luau','Faces')+'\nscript.Parent.FaceData=Faces\n'
        +module('CharacterVisuals.luau','Visuals')+'\nscript.Parent.CharacterVisuals=Visuals\n'
        +module('CharacterFactory.luau','Factory')+FACTORY_TESTS+module('Cosmetics.luau','Cosmetics')+r'''
for _,entry in ipairs(roster) do for tier=0,4 do
 nodes={}
 local model=Factory.create(entry);local h=model:FindFirstChildOfClass("Humanoid")
 local health,speed=h.MaxHealth,h.WalkSpeed
 Cosmetics.apply(model,entry.id,{skin=entry.id..(tier==0 and ":base" or ":m"..tier),cosmetic="cosmetic:scarf"})
 assert(model:GetAttribute("Milestone")==tier and h.MaxHealth==health and h.WalkSpeed==speed)
 local claws=0
 for _,part in ipairs(model:FindFirstChild("ForgottenCosmetics"):GetDescendants()) do
  if part:IsA("BasePart") then assert(not part.CanCollide and part.Massless) end
  if part.Name=="Garra maldita" then claws=claws+1 end
  assert(part.Name~="Capa")
 end
 assert(claws==(entry.id=="guest666" and tier>=3 and 6 or 0))
end end
''')
    run_lua(factory,'V2: seis rigs, articulaciones e identidades independientes')

ECONOMY = ('\nscript={Parent={}}\n'+module('EconomyConfig.luau','Economy')+module('ShopCatalog.luau','Shop')
    +'\nscript.Parent.EconomyConfig=Economy;script.Parent.ShopCatalog=Shop\n'+module('ProfileData.luau','Data')+'\nShared.ProfileData=Data\n')

def economy():
    tests=r'''
local p=Data.new();assert(p.coins==100)
local milestones=0;for _,item in ipairs(Shop) do if item.mastery then milestones=milestones+1 end end;assert(milestones==24)
assert(not Data.purchase(p,"unknown") and p.coins==100)
assert(Data.purchase(p,"cosmetic:scarf") and p.coins==50)
assert(not Data.purchase(p,"cosmetic:scarf") and p.coins==50)
assert(not Data.purchase(p,"cosmetic:lantern") and p.coins==50)
assert(not Data.purchase(p,"guest666:m1"))
assert(not Data.equip(p,"yellowguy","junkbot:base"))
assert(Data.equip(p,"yellowguy","cosmetic:scarf"))
assert(Data.equip(p,"yellowguy","none") and p.equipped.yellowguy.cosmetic=="")
assert(not Data.equip(p,"yellowguy","guest666:m4"))
assert(Data.reward(p,"event1","escape","junkbot"))
local coins=p.coins;local xp=p.xp.junkbot
assert(not Data.reward(p,"event1","escape","junkbot") and p.coins==coins and p.xp.junkbot==xp)
for i=2,40 do assert(Data.reward(p,"event"..i,"escape","junkbot")) end
for i=1,4 do assert(p.owned["junkbot:m"..i] and not p.owned["yellowguy:m"..i]) end
assert(Data.equip(p,"junkbot","junkbot:m4"))
local clean=Data.normalize(p);assert(clean.coins==p.coins and clean.equipped.junkbot.skin=="junkbot:m4")
assert(not Data.reward(clean,"event1","escape","junkbot"))
assert(not Data.normalize({version=2,coins=-1}))
assert(not Data.normalize({version=2,coins=0/0}))
assert(not Data.normalize({version=900,coins=0}))
assert(not Data.normalize("corrupt"))
local public=Data.public(p,"session");assert(public.receipts==nil and public.receiptOrder==nil)
'''
    run_lua(MOCK+COMMON+ECONOMY+tests,'economía: compras, saldos, inventario, 24 milestones y recibos repetidos')
    setup=r'''
local storage={};local failing=false;local writes=0
local store={UpdateAsync=function(_,key,transform)
 if failing then error("API disabled") end
 local value=transform(storage[key]);if value~=nil then storage[key]=value;writes=writes+1 end;return value
end}
services.DataStoreService={GetDataStore=function(_,name)assert(name=="FORGOTTEN_Profiles_v2_Studio");return store end}
services.HttpService={GenerateGUID=function()return "guid"end}
services.RunService={IsStudio=function()return true end}
local sent={};local function send(player,kind,value)sent[kind]=value end
local player={UserId=42,Parent=true}
'''
    tests=r'''
local service=Profiles.new(send);service:load(player)
assert(service.records[player].mode=="persistent" and storage.user_42.session.owner==service.owner)
assert(service:purchase(player,"cosmetic:scarf"));assert(service:save(player,false))
assert(storage.user_42.data.coins==50)
-- A competing server cannot load or mutate the active profile.
game.JobId="second-server"
local second=Profiles.new(send);second:load(player)
assert(second.records[player].mode=="locked" and not second:purchase(player,"cosmetic:badge"))
local before=writes;second:close(player);assert(writes==before)
service:close(player);assert(storage.user_42.session==nil and service.records[player]==nil)
second:load(player);assert(second:get(player).coins==50 and second.records[player].mode=="persistent")
assert(second:reward(player,"round:1:objective:1","generator","junkbot"))
second:save(player,false)
assert(storage.user_42.data.coins==62)
assert(not second:reward(player,"round:1:objective:1","generator","junkbot"))
-- An expired/lost lease must never overwrite another server's record.
storage.user_42.session.owner="third-server"
before=writes;assert(not second:save(player,false));assert(writes==before and second.records[player].mode=="locked")
-- API disabled: session-only purchases never overwrite the stored balance.
failing=true
local fallback=Profiles.new(send);fallback:load(player)
assert(fallback.records[player].mode=="session")
assert(fallback:purchase(player,"cosmetic:scarf"))
fallback:close(player);assert(storage.user_42.data.coins==62)
failing=false
storage.user_42={version=900,data={version=900,coins=2}}
before=writes
local incompatible=Profiles.new(send);incompatible:load(player);incompatible:close(player)
assert(writes==before and storage.user_42.version==900)
'''
    run_lua(MOCK+COMMON+ECONOMY+setup+server('ProfileService.luau','Profiles')+tests,'persistencia simulada: sesión, bloqueo, guardado, liberación y fallo sin sobrescritura')

CHALLENGES=r'''
local function random(a,b)return a end
for _,kind in ipairs({"memory","piano","wires"}) do
 local s=Challenge.new(kind,time,random)
 if kind=="memory" then assert(Challenge.input(s,s.sequence[1],time)=="ignored") end
 time=s.readyAt+.2
 for i,value in ipairs(s.sequence) do advance(.2);assert(Challenge.input(s,value,time)==(i==#s.sequence and "complete" or "progress")) end
 s=Challenge.new(kind,time,random);time=s.readyAt+.2;assert(Challenge.input(s,4,time)=="wrong")
end
local s=Challenge.new("switches",time,random)
assert(Challenge.input(s,0,time)=="ignored")
for i,v in ipairs({1,3,4}) do advance(.2);assert(Challenge.input(s,v,time)==(i==3 and "complete" or "progress")) end
s=Challenge.new("reflex",time,random);assert(Challenge.input(s,"hit",time)=="wrong")
s=Challenge.new("reflex",time,random);time=s.readyAt+.5;assert(Challenge.input(s,"hit",time)=="complete")
s=Challenge.new("reflex",time,random);time=s.readyAt+1.3;assert(Challenge.input(s,"hit",time)=="wrong")
s=Challenge.new("rope",time,random)
for i=1,3 do time=s.readyAt+.9;assert(Challenge.input(s,"pull",time)==(i==3 and "complete" or "progress")) end
for maze=1,2 do
 s=Challenge.new("maze",time,function()return maze end)
 local queue={{x=2,y=2,path={}}};local seen={["2,2"]=true};local path
 for _,node in ipairs(queue) do
  if node.x==6 and node.y==6 then path=node.path;break end
  for key,delta in pairs({up={0,-1},down={0,1},left={-1,0},right={1,0}}) do
   local x,y=node.x+delta[1],node.y+delta[2];local k=x..","..y
   if s.grid[y] and s.grid[y]:sub(x,x)=="0" and not seen[k] then
    seen[k]=true;local p={table.unpack(node.path)};table.insert(p,key);table.insert(queue,{x=x,y=y,path=p})
   end
  end
 end
 assert(path,"Maze has no solution")
 for i,key in ipairs(path) do advance(.2);assert(Challenge.input(s,key,time)==(i==#path and "complete" or "progress")) end
end
s=Challenge.new("wires",time,random);assert(Challenge.input(s,1,time+61)=="expired")
'''

def challenges_and_objectives():
    base=MOCK+COMMON+module('ChallengeRules.luau','Challenge')+'\nShared.ChallengeRules=Challenge\n'
    run_lua(base+CHALLENGES,'siete minijuegos: secuencias, reflejos, cuerda, interruptores y dos laberintos resolubles')
    base += '\nColorSequence={new=function(c)return c end};services.CollectionService={AddTag=function(m)end}\n'+module('GeneratorVisuals.luau','Generator')+'\nShared.GeneratorVisuals=Generator\n'
    tests=r'''
local p1={UserId=1,Character=Instance.new("Model"),SetAttribute=function()end};local p2={UserId=2,SetAttribute=function()end}
local near={[p1]=true,[p2]=true};local messages={};local rewards=0
local rules=Rules.new(false)
local world={arena=Instance.new("Model"),center=Vector3.new(),depotPosition=Vector3.new(0,0,10),generatorPositions={},puzzlePositions={}}
for i=1,4 do world.generatorPositions[i]=Vector3.new(i*10,0,0);world.puzzlePositions[i]=Vector3.new(i*10,0,20) end
local o=Objectives.new(world,rules,{canInteract=function(p)return near[p]end,send=function(p,k,v)messages[p]={kind=k,data=v}end,changed=function()end,reward=function()rewards=rewards+1 end})
local function answer(p,value)local s=o.sessions[p];o:answer(p,s.token,value)end
o.generators[1].prompt.Triggered:Fire(p1)
local s=o.sessions[p1];assert(s and s.challenge.kind=="wires")
assert(p1.Character:GetAttribute("RepairStage")==1)
local gen=o.generators[1];assert(gen.base.CanCollide and gen.base.Transparency==1 and not gen.smoke.Enabled)
local parts=0;for _,part in ipairs(gen.model:GetChildren()) do if part:IsA("BasePart") then parts=parts+1;if part~=gen.base then assert(not part.CanCollide and not part.CanQuery)end end end
assert(parts>30 and parts<65)
o:answer(p1,"forged-token",1);assert(s.challenge.step==1)
for _,v in ipairs(s.challenge.sequence) do advance(.2);answer(p1,v) end
assert(s.stage==2 and s.challenge.kind=="switches")
assert(p1.Character:GetAttribute("RepairStage")==2 and gen.model:GetAttribute("RepairStage")==2)
for _,v in ipairs({1,3,4}) do advance(.2);answer(p1,v) end
assert(s.stage==3)
for i=1,3 do time=s.challenge.readyAt+.9;answer(p1,"pull") end
assert(rules.generatorCount==1 and rules.remaining==230 and rewards==1)
assert(gen.model:GetAttribute("Running") and gen.smoke.Enabled and p1.Character:GetAttribute("RepairStage")==0)
o.generators[1].prompt.Triggered:Fire(p2);assert(not o.sessions[p2])
o.stations[1].pickup.Triggered:Fire(p1);assert(rules:carried(1)==0)
o.stations[1].solve.Triggered:Fire(p1);o.stations[1].solve.Triggered:Fire(p2)
s=o.sessions[p1];time=s.challenge.readyAt+.2
local oldToken=o.sessions[p2].token
for _,v in ipairs(s.challenge.sequence) do advance(.2);answer(p1,v) end
assert(rules.puzzleCount==1 and rewards==2 and rules.remaining==225)
o:answer(p2,oldToken,1);assert(not o.sessions[p2] and rewards==2)
o.stations[1].pickup.Triggered:Fire(p1);o.stations[1].pickup.Triggered:Fire(p2)
assert(rules:carried(1)==1 and rules:carried(2)==0 and rules.capsuleCount==0)
for _,piece in ipairs(o.stations[1].capsuleParts)do assert(piece.Transparency==1)end
o:drop(p1);assert(rules:carried(1)==0 and o.stations[1].pickup.Enabled)
for _,piece in ipairs(o.stations[1].capsuleParts)do assert(piece.Transparency==0)end
o.stations[1].pickup.Triggered:Fire(p2)
o.prompts[#o.prompts].Triggered:Fire(p2)
assert(rules.capsuleCount==1 and rules:carried(2)==0)
o:drop(p2);assert(not o.stations[1].pickup.Enabled)
o.stations[2].solve.Triggered:Fire(p1);near[p1]=false;answer(p1,1);assert(not o.sessions[p1])
near[p1]=true;o.stations[2].solve.Triggered:Fire(p1);advance(61);o:tick();assert(not o.sessions[p1])
o.stations[2].solve.Triggered:Fire(p1);rules:updateSurvivors(1);o:disableForLMS()
assert(not o.sessions[p1] and rules.remaining==90)
for _,prompt in ipairs(o.prompts) do assert(not prompt.Enabled) end
o:destroy();o.generators[2].prompt.Triggered:Fire(p1);assert(rules.generatorCount==1)
'''
    run_lua(base+WORLD+module('RoundRules.luau','Rules')+server('Objectives.luau','Objectives')+tests,'controlador objetivos: distancia, tokens, tres etapas, depósitos, abandonos y duplicados')

def items_and_abilities():
    setup=MOCK+COMMON+WORLD+module('ItemConfig.luau','ItemConfig')+module('AbilityConfig.luau','AbilityConfig')+module('AbilityTiming.luau','AbilityTiming')+module('Stamina.luau','Stamina')+r'''
Shared.AbilityTiming=AbilityTiming
Shared.ItemConfig=ItemConfig;Shared.AbilityConfig=AbilityConfig;Shared.CharacterFactory={}
local vindex=vmt.__index
vmt.__index=function(a,k)if k=="Unit" then return a/a.Magnitude end;return vindex(a,k)end
typeof=function(value)return getmetatable(value)==vmt and "Vector3" or type(value)end
local function player(id,x)
 local model=Instance.new("Model")
 local root={Position=Vector3.new(x,3,0),CFrame={LookVector=Vector3.new(1,0,0)}}
 local h={Health=50,MaxHealth=100,TakeDamage=function(self,n)self.Health=math.max(0,self.Health-n)end}
 return {UserId=id,Character=model,root=root,h=h}
end
local p=player(1,0);local killer=player(2,5);local ally=player(3,7)
local records={
 [p]={entry={id="yellowguy",role="Superviviente"},items={},energy=Stamina.new(),status=true},
 [killer]={entry={id="guest666",role="Asesino"},energy=Stamina.new(),status=true},
 [ally]={entry={id="pelotocino",role="Superviviente"},energy=Stamina.new(),status=true}}
local inRange=true;local sight=true;local messages={};local effects=0
local context={records=function()return records end,playing=function(player)return records[player].status and player.h.Health>0 end,
 body=function(player)return player.root,player.h end,visible=function()return sight end,
 canInteract=function(player)return inRange and records[player].entry.role=="Superviviente"end,
 send=function(player,kind,data)messages[kind]=data end,effect=function()effects=effects+1 end,rules=function()return {mode="Normal",carried=function()return 0 end}end}
'''
    tests=r'''
local world={arena=Instance.new("Model"),center=Vector3.new(),itemSpawns={Vector3.new(),Vector3.new(),Vector3.new(),Vector3.new()}}
local items=Items.new(world,context)
local prompts={};for _,n in ipairs(nodes) do if n.ClassName=="ProximityPrompt" then table.insert(prompts,n) end end
inRange=false;prompts[1].Triggered:Fire(p);assert(#records[p].items==0)
inRange=true;prompts[1].Triggered:Fire(p);prompts[3].Triggered:Fire(p);assert(#records[p].items==1)
prompts[2].Triggered:Fire(p);assert(#records[p].items==2)
prompts[4].Triggered:Fire(p);assert(#records[p].items==2)
items:use(p,0);assert(not records[p].itemUse)
items:use(p,1);advance(6.9);items:tick();assert(p.h.Health==50 and #records[p].items==2)
advance(.1);items:tick();assert(p.h.Health==100 and #records[p].items==1)
items:use(p,1);assert(#records[p].items==0 and records[p].drinkUntil==time+6)
local untilTime=records[p].drinkUntil
records[p].energy.requested=true
advance(5.9);Stamina.step(records[p].energy,.5,true,untilTime>time);assert(records[p].energy.value==100)
advance(.2);Stamina.step(records[p].energy,.5,true,untilTime>time);assert(records[p].energy.value<100)
prompts[3].Triggered:Fire(p);p.h.Health=30;items:use(p,1);p.root.Position=Vector3.new(4,3,0);advance(1);items:tick()
assert(not records[p].itemUse and #records[p].items==1 and p.h.Health==30)
items:use(p,1);advance(.1);records[p].lastDamage=time;items:tick();assert(not records[p].itemUse and #records[p].items==1)
local a=Abilities.new(context);p.root.Position=Vector3.new(0,3,0);p.h.Health=100;killer.h.Health=100
-- Invalid casts, unavailable energy, line of sight and repeated cooldowns.
local energy=records[p].energy.value
a:cast(p,"1");a:cast(p,100);a:cast(p,0/0);assert(records[p].energy.value==energy)
records[p].energy.value=0;a:cast(p,1);assert(not records[killer].slowUntil)
records[p].energy.value=100;sight=false;a:cast(p,1);advance(.3);a:tick();assert(not records[killer].slowUntil)
advance(20);sight=true;a:cast(p,1);advance(.3);a:tick();assert(records[killer].slowUntil==time+3)
local cooldown=records[p].cooldowns.cane;local after=records[p].energy.value
a:cast(p,1);assert(records[p].cooldowns.cane==cooldown and records[p].energy.value==after)
a:cast(p,2);assert(records[p].shield==.5)
ally.root.Position=Vector3.new(30,3,0)
a:cast(killer,1);assert(p.h.Health==100);advance(.3);a:tick();assert(p.h.Health==87.5 and ally.h.Health==50)
a:cast(killer,1);assert(p.h.Health==87.5)
assert(not a:damage(p,ally,50) and ally.h.Health==50)
records[p].invulnerableUntil=time+1;assert(not a:damage(killer,p,50))
advance(2);sight=false;a:cast(killer,1);advance(.3);a:tick();assert(p.h.Health==87.5)
records[killer].status=false;advance(5);a:cast(killer,1);assert(p.h.Health==87.5)
records[p].drinkUntil=time+6;assert(a:speed(p,16)==16*1.35)
records[p].itemUse={};assert(a:speed(p,16)==8);records[p].itemUse=nil
local count=0
for id,list in pairs(AbilityConfig) do if id~="keys" then for _,skill in ipairs(list) do assert(skill.cooldown>0 and skill.cost>=0 and skill.provisional);count=count+1 end end end
assert(count==26 and effects>0)
-- Exercise every ability through the real cast dispatcher, with deterministic ray hits.
a.ray=function()return killer,killer.root.Position end
a.teleport=function()return true end
for id,list in pairs(AbilityConfig) do if id~="keys" then
 for slot,skill in ipairs(list) do
  advance(100)
  local role=(id=="guest666" or id=="tubers93") and "Asesino" or "Superviviente"
  records[p]={entry={id=id,role=role},energy=Stamina.new(),status=true,items={}}
  records[killer]={entry={id="guest666",role=role=="Asesino" and "Superviviente" or "Asesino"},energy=Stamina.new(),status=true}
  records[ally]={entry={id="pelotocino",role=role},energy=Stamina.new(),status=true}
  p.h.Health=30;killer.h.Health=100;ally.h.Health=50;sight=true
  local before=effects
  a:cast(p,slot)
  assert(records[p].cooldowns[skill.id]>time and effects>before,id..":"..skill.id)
  advance(.6);a:tick();advance(.2);a:tick()
  if skill.kind=="repair" then advance(2);a:tick();assert(p.h.Health==55 and not records[p].channel) end
  if skill.kind=="melee" or skill.kind=="ray" or skill.kind=="slam" or skill.kind=="pounce" or skill.kind=="pull" or skill.kind=="blast" or skill.kind=="areaDamage" or skill.kind=="fire" then assert(killer.h.Health<100,skill.id) end
  if skill.kind=="reveal" then assert(messages.reveal and #messages.reveal.models==1) end
  if skill.kind=="stun" or skill.kind=="areaSlow" or skill.kind=="bacon" then assert(records[killer].slowUntil>time) end
  if skill.kind=="shield" or skill.kind=="teamShield" then assert(records[p].shieldUntil>time) end
  if skill.kind=="speed" then assert(a:speed(p,16)==28) end
  if skill.kind=="heal" or skill.kind=="teamHeal" or skill.kind=="lastFighter" then assert(p.h.Health>30) end
 end
end end
-- V3 timing: an attack cannot hit before its pose contact, twice, or in a later life.
records[p]={entry={id="guest666",role="Asesino"},energy=Stamina.new(),status=true,items={}}
records[killer]={entry={id="pelotocino",role="Superviviente"},energy=Stamina.new(),status=true}
records[ally].entry.role="Asesino";p.h.Health=100;killer.h.Health=100;sight=true
a:cast(p,1);advance(.1);a:tick();assert(killer.h.Health==100)
advance(.13);a:tick();assert(killer.h.Health==75)
a:tick();assert(killer.h.Health==75)
advance(2);a:cast(p,1);records[p].status=false;advance(.3);a:tick();assert(killer.h.Health==75)
records[p].status=true;advance(2);a:cast(p,1)
local previous=records[p];records[p]={entry=previous.entry,energy=Stamina.new(),status=true,items={}}
advance(.3);a:tick();assert(killer.h.Health==75)
-- Escape input is scoped to the pinned victim, expires, and is rate-limited.
a:hold(p,killer,"pinned",1.6,true)
local token=records[killer].escape.token
assert(a:speed(killer,16)==0)
a:struggle(killer,"forged");assert(records[killer].escape.taps==0)
a:struggle(killer,token);a:struggle(killer,token);assert(records[killer].escape.taps==1)
advance(.15);a:struggle(killer,token);advance(.15);a:struggle(killer,token)
assert(not records[killer].escape and a:speed(killer,16)==16)
a:hold(p,killer,"pinned",1.6,true);advance(2);a:tick();assert(not records[killer].escape)
items:destroy()
'''
    run_lua(setup+server('RoundItems.luau','Items')+server('Abilities.luau','Abilities')+tests,'objetos y combate: ranuras, 7 s, cancelación, bebida 6 s, alcance, energía, escudos y cooldowns')

def maps():
    target='/tmp/forgotten-v2-map-check.json'
    tests=r'''
local output=assert(io.open(PATH,'w'));output:write('[')
for index,definition in ipairs(Catalog) do
 nodes={}
 local world=Maps.build(Instance.new("Folder"),definition,World)
 assert(#world.generatorPositions==4 and #world.puzzlePositions==4 and #world.itemSpawns==6)
 assert(world.center.Z==600 and world.gate.CanCollide)
 world.setGate(true,"Normal");assert(not world.gate.CanCollide)
 world.setGate(false,"LMS");assert(world.gate.CanCollide)
 local positions={world.survivorSpawn,world.killerSpawn,world.depotPosition,Vector3.new(0,0,world.gate.Position.Z-world.center.Z-4)}
 assert(world.playableHalf==186 and #world.pointsOfInterest==4)
 for _,point in ipairs(world.pointsOfInterest) do table.insert(positions,point.position) end
 for _,list in ipairs({world.generatorPositions,world.puzzlePositions,world.itemSpawns}) do for _,p in ipairs(list) do table.insert(positions,p) end end
 if index>1 then output:write(',') end
 output:write('{"id":',quote(definition.id),',"half":',tostring(world.playableHalf+2),',"points":[')
 for i,p in ipairs(positions) do if i>1 then output:write(',')end;output:write(json({p.X,p.Z}))end
 output:write('],"parts":[')
 local first=true;local count=0
 for _,n in ipairs(nodes) do if n.ClassName=="Part" then
  count=count+1
  if n.CanCollide then
   if not first then output:write(',')end;first=false
   output:write(json({n.Position.X,n.Position.Y,n.Position.Z-world.center.Z,n.Size.X,n.Size.Y,n.Size.Z}))
  end
 end end
 assert(count>300 and count<1100)
 output:write('],"count":',tostring(count),'}')
end
output:write(']');output:close()
'''.replace('PATH',repr(target))
    run_lua(MOCK+COMMON+WORLD+module('MapCatalog.luau','Catalog')+server('MapExpansion.luau','Expansion')+'\nscript.Parent.MapExpansion=Expansion\n'+server('Maps.luau','Maps')+tests,'nueve mapas: constructores, distritos V4, geometría, objetivos, objetos y salida')
    summaries=[]
    for layout in json.loads(open(target).read()):
        # Conservative 2D navigation test at body height with 1.5-stud radius.
        obstacles=[p for p in layout['parts'] if p[1]+p[4]/2>.6 and p[1]-p[4]/2<5.5]
        step=2
        def blocked(x,z):
            return any(abs(x-p[0])<p[3]/2+1.5 and abs(z-p[2])<p[5]/2+1.5 for p in obstacles)
        half=layout['half']
        # Rasterize conservative obstacle bounds instead of testing every cell
        # against every part. Same 1.5-stud clearance, appropriate for larger maps.
        cells={(x,z) for x in range(-half,half+1,step) for z in range(-half,half+1,step)}
        for p in obstacles:
            for x in range(max(-half,int((p[0]-p[3]/2-1.5)//step)*step),min(half,int((p[0]+p[3]/2+1.5)//step)*step)+1,step):
                for z in range(max(-half,int((p[2]-p[5]/2-1.5)//step)*step),min(half,int((p[2]+p[5]/2+1.5)//step)*step)+1,step):
                    if abs(x-p[0])<p[3]/2+1.5 and abs(z-p[2])<p[5]/2+1.5:cells.discard((x,z))
        start=tuple(layout['points'][0]);assert start in cells,(layout['id'],'spawn blocked')
        seen={start};queue=deque([start])
        while queue:
            x,z=queue.popleft()
            for p in ((x+step,z),(x-step,z),(x,z+step),(x,z-step)):
                if p in cells and p not in seen:seen.add(p);queue.append(p)
        for x,z in layout['points']:
            assert any(abs(x-a)<=3 and abs(z-b)<=3 for a,b in seen),(layout['id'],'unreachable',x,z)
        summaries.append(f"{layout['id']}={layout['count']}")
    print('PASS: rutas 2D desde spawn a todos los objetivos, objetos y salida; piezas: '+', '.join(summaries))

if __name__=='__main__':
    rules_and_rigs()
    economy()
    challenges_and_objectives()
    items_and_abilities()
    maps()
