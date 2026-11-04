"""Execute the actual main server script with bounded fake services and clock.
Component behavior is exercised separately in check_v2 / catalog tests.
This verifies orchestration, not Roblox networking or physics.
"""
from check_playable import ROOT, run_lua, module
from check_v2 import COMMON
from export_preview import MOCK

SETUP=r'''
local case=CASE
local roster=Roster
local shared={Roster=Roster,RoundRules=Rules,RoleAssignment=Assignment,Stamina=Stamina,MapCatalog=MapCatalog,EconomyConfig=Economy}
local activeRules
local originalNew=Rules.new
Rules.new=function(practice)local r=originalNew(practice);activeRules=r;return r end
local players={};local list={};local callbacks={};local snapshots={};local result;local restores=0;local mapLoads=0
local function event()return signal()end
players.PlayerAdded=event();players.PlayerRemoving=event()
function players:GetPlayers()return list end
function players:GetPlayerByUserId(id)for _,p in ipairs(list)do if p.UserId==id then return p end end end
function players:GetPlayerFromCharacter(model)for _,p in ipairs(list)do if p.Character==model then return p end end end
local function model(id)
 local m=Instance.new("Model");m.Name=id
 local root=Instance.new("Part",m);root.Name="HumanoidRootPart";root.AssemblyLinearVelocity=Vector3.new();root.CFrame=CFrame.new()
 local h=Instance.new("Humanoid",m);h.Name="Humanoid";h.Health=100;h.MaxHealth=100;h.MoveDirection=Vector3.new();h.Died=event()
 m.FindFirstChildOfClass=function(self,kind)return kind=="Humanoid" and h end
 m.GetAttribute=function()return "Provisional"end
 m.HumanoidRootPart=root
 return m
end
local number=case=="practice" and 1 or case=="lms" and 2 or 3
for id=1,number do
 local p={UserId=id,DisplayName="Player"..id,Parent=players,Character=model("avatar"),CharacterAdded=event(),attributes={}}
 function p:SetAttribute(k,v)self.attributes[k]=v end
 function p:GetAttribute(k)return self.attributes[k]end
 function p:HasAppearanceLoaded()return true end
 list[id]=p
end
local Factory={create=function(entry)return model(entry.id)end,place=function(m,pos)m.HumanoidRootPart.Position=pos+Vector3.new(0,3,0)end}
local Native={consumeSwap=function()return false end,discard=function()end,isRestoredAvatar=function()return false end}
function Native.equip(p,m,id)p.original=p.Character;p.Character=m;p:SetAttribute("CharacterId",id);return true end
function Native.restore(p)if p.original then p.Character=p.original;p.original=nil;restores=restores+1 end end
local remote={OnServerEvent=event()}
local latest
function remote:FireAllClients(kind,data)
 if kind=="state" then latest=data;table.insert(snapshots,{phase=data.phase,mode=data.mode,time=data.remaining,gate=data.gateOpen}) end
 if kind=="results" then result=data end
end
function remote:FireClient()end
local world={center=Vector3.new(0,0,600),lobbyPosition=Vector3.new(0,0,0),spawn={},survivorSpawn=Vector3.new(-90,0,-100),killerSpawn=Vector3.new(90,0,100),refreshNPC=function()end}
world.gate={Position=Vector3.new(0,6,721)}
world.exit={Size=Vector3.new(24,10,6),CFrame={PointToObjectSpace=function(_,p)return p-Vector3.new(0,5,727)end},Touched=event()}
world.setGate=function()end
world.loadMap=function(id)mapLoads=mapLoads+1;world.mapId=id;world.mapName=id end
local objectiveDestroyed=0;local itemsDestroyed=0
local Objectives={new=function(_,rules,cb)
 return {drop=function()end,disableForLMS=function()end,tick=function()end,destroy=function()objectiveDestroyed=objectiveDestroyed+1 end}
end}
local RoundItems={new=function()return {tick=function()end,destroy=function()itemsDestroyed=itemsDestroyed+1 end}end}
local abilityContext
local Abilities={new=function(c)
 abilityContext=c
 return {cast=function()end,tick=function()end,speed=function(_,p,base)return base end,hud=function()return {}end}
end}
local paid={}
local Profiles={new=function()
 return {owner="test",records={},get=function()return nil end,publish=function()end,select=function()end,close=function()end,
 load=function(_,p,ready)ready({lastCharacter="pelotocino"})end,
 reward=function(_,p,receipt,kind)table.insert(paid,{id=p.UserId,kind=kind})end}
end}
shared.CharacterFactory=Factory;shared.CatalogCharacter={load=function()return false end,ready=function()return true end}
shared.NativeRoundCharacter=Native;shared.Cosmetics={apply=function()end}
local rs={Shared=shared,FindFirstChild=function(_,name)if name=="GameEvent" then return remote end end}
services.Players=players;services.ReplicatedStorage=rs;services.RunService={IsStudio=function()return true end}
script={World={build=function()return world end},Objectives=Objectives,Abilities=Abilities,RoundItems=RoundItems,ProfileService=Profiles}
function game:BindToClose(fn)callbacks.close=fn end
workspace.FindFirstChild=function()return nil end
workspace.Raycast=function()return nil end
RaycastParams={new=function()return {}end}
local steps=0;local initialized=false;local prepared=false
task.spawn=function(fn,...)fn(...)end
task.wait=function(dt)
 advance(math.max(dt or 0,1));steps=steps+1
 assert(steps<1000,"Main loop did not finish")
 if not initialized then
  initialized=true
  remote.OnServerEvent:Fire(list[1],"select",case=="practice" and "yellowguy" or "guest666")
  if case=="practice" then remote.OnServerEvent:Fire(list[1],"practice") end
 end
 if latest and latest.phase=="Ronda" then
  if case=="escape" or case=="practice" then
   if not prepared then
    prepared=true
    for i=1,2 do activeRules:completeGenerator(i) end
    for i=1,3 do activeRules:completePuzzle(i);activeRules:collectCapsule(i,99) end
    activeRules:depositCapsules(99)
   end
  end
  if (case=="escape" or case=="practice" or case=="lms") and activeRules.gateOpen then
   for p,r in pairs(abilityContext.records()) do if r.entry.role=="Superviviente" then p.Character.HumanoidRootPart.Position=Vector3.new(0,5,727) end end
  end
  if case=="killerLeaves" and not prepared then
   prepared=true;local p=list[1];p.Parent=nil;players.PlayerRemoving:Fire(p);table.remove(list,1)
  end
 end
 if result and latest and latest.phase=="Lobby" then error("TEST_COMPLETE") end
end
'''

TESTS=r'''
local ok,message=pcall(runMain)
assert(not ok and tostring(message):find("TEST_COMPLETE"),tostring(message))
assert(result and objectiveDestroyed==1 and itemsDestroyed==1 and mapLoads==1)
local sawNormal,sawLMS,sawOpen=false,false,false
for _,s in ipairs(snapshots) do
 if s.phase=="Ronda" and s.mode=="Normal" and s.time==240 then sawNormal=true end
 if s.phase=="Ronda" and s.mode=="LMS" and s.time==90 then sawLMS=true end
 if s.phase=="Ronda" and s.gate then sawOpen=true end
end
if case=="lms" then assert(sawLMS and sawOpen) end
if case=="escape" or case=="timeout" then assert(sawNormal) end
if case=="practice" then assert(result.practice and #paid==0 and restores==1) end
if case=="escape" or case=="practice" or case=="lms" then
 local escaped=0
 for _,row in ipairs(result.rows) do if row.role=="Superviviente" then assert(row.status=="Escapó");escaped=escaped+1 end end
 assert(escaped==(case=="escape" and 2 or 1))
end
if case=="timeout" then
 local wins=0
 for _,row in ipairs(result.rows) do
  if row.role=="Asesino" then assert(row.victory and row.status=="Victoria");wins=wins+1 else assert(row.status=="No escapó") end
 end
 local rewards=0;for _,p in ipairs(paid)do if p.kind=="killerWin" then rewards=rewards+1 end end
 assert(wins==1 and rewards==1 and not sawOpen)
end
if case=="killerLeaves" then
 for _,row in ipairs(result.rows) do assert(row.status=="Interrumpida" and not row.victory) end
end
for _,p in ipairs(list)do assert(not p:GetAttribute("InRound") and p.Character.HumanoidRootPart.Position.Z==0)end
'''

def main():
    core=module('Roster.luau','Roster')+module('RoundRules.luau','Rules')+module('RoleAssignment.luau','Assignment')+module('Stamina.luau','Stamina')+module('MapCatalog.luau','MapCatalog')+module('EconomyConfig.luau','Economy')
    source=(ROOT/'src/server/init.server.luau').read_text()
    for case in ['practice','escape','lms','timeout','killerLeaves']:
        run_lua(MOCK+COMMON+core+SETUP.replace('CASE',repr(case))+'\nlocal function runMain()\n'+source+'\nend\n'+TESTS,'orquestación del servidor real con dobles: '+case)

if __name__=='__main__':main()
