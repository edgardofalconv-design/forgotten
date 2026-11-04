local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local roster=require(RS.Shared.Roster)
local Rules=require(RS.Shared.RoundRules)
local Assignment=require(RS.Shared.RoleAssignment)
local Stamina=require(RS.Shared.Stamina)
local Factory=require(RS.Shared.CharacterFactory)
local Catalog=require(RS.Shared.CatalogCharacter)
local AvatarCatalog=require(RS.Shared.AvatarCatalog)
local Native=require(RS.Shared.NativeRoundCharacter)
local World=require(script.World)
local Objectives=require(script.Objectives)
local Abilities=require(script.Abilities)
local RoundItems=require(script.RoundItems)
local Profiles=require(script.ProfileService)
local Cosmetics=require(RS.Shared.Cosmetics)
local EconomyConfig=require(RS.Shared.EconomyConfig)
local MapCatalog=require(RS.Shared.MapCatalog)
local mapById={};for _,map in ipairs(MapCatalog) do mapById[map.id]=map end
local byId={}
for _,entry in ipairs(roster) do byId[entry.id]=entry end
local remote=RS:FindFirstChild("GameEvent") or Instance.new("RemoteEvent")
remote.Name="GameEvent";remote.Parent=RS
local world=World.build(roster,remote)
local phase,remaining,roundId="Lobby",15,0
local selected,participants,lastKiller,born,limits={},{},{},{},{}
local rules,objectives,items,abilities
local profiles
local mapVotes,selectionTouched={},{}
local resultsData
local killerUserId,musicKey,result=0,"",""
local practiceRequested=false
local practice=false
local function send(player,kind,data)
 if player.Parent==Players then remote:FireClient(player,kind,data) end
end
profiles=Profiles.new(send)
local function body(player)
 local character=player.Character
 return character and character:FindFirstChild("HumanoidRootPart"),character and character:FindFirstChildOfClass("Humanoid")
end
local function entryFor(player)
 return participants[player] and participants[player].entry or byId[selected[player] or "pelotocino"]
end
local function playing(player)
 local record=participants[player]
 local root,h=body(player)
 return phase=="Ronda" and player.Parent==Players and record and record.status=="Jugando" and root and h and h.Health>0
end
local function snapshot()
 local scoreboard={}
 for player,record in pairs(participants) do if player.Parent==Players then
  table.insert(scoreboard,{userId=player.UserId,name=player.DisplayName,character=record.entry.id,status=record.status,score=record.objectives*100+math.floor(record.damage),role=record.entry.role})
 end end
 table.sort(scoreboard,function(a,b)return a.userId<b.userId end)
 return {phase=phase,remaining=math.ceil(rules and phase=="Ronda" and rules.remaining or remaining),
  mode=rules and rules.mode or "Normal",roundId=roundId,generators=rules and rules.generatorCount or 0,
  capsules=rules and rules.capsuleCount or 0,puzzles=rules and rules.puzzleCount or 0,
  gateOpen=rules and rules.gateOpen or false,killerUserId=killerUserId,musicKey=musicKey,result=result,
  mapId=world.mapId,mapName=world.mapName,results=resultsData,scoreboard=scoreboard,
  canPractice=RunService:IsStudio() and #Players:GetPlayers()==1 and phase=="Lobby"}
end
local function broadcast() remote:FireAllClients("state",snapshot()) end
local function changed()
 if rules then world.setGate(rules.gateOpen,rules.mode) end
 broadcast()
end
local function canInteract(player,part)
 if not playing(player) or entryFor(player).role~="Superviviente" then return false end
 if (participants[player].holdUntil or 0)>os.clock() then return false end
 local root=body(player)
 if (root.Position-part.Position).Magnitude>12 then return false end
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={player.Character}
 local hit=workspace:Raycast(root.Position,part.Position-root.Position,params)
 return not hit or hit.Instance==part
end
local function inExit(player)
 local root=body(player)
 if not root then return false end
 local localPos=world.exit.CFrame:PointToObjectSpace(root.Position)
 return math.abs(localPos.X)<=world.exit.Size.X/2 and math.abs(localPos.Y)<=world.exit.Size.Y/2+1
  and math.abs(localPos.Z)<=world.exit.Size.Z/2 and root.Position.Z>world.gate.Position.Z+2
end
local function returnToLobby(player)
 Native.restore(player)
 player:SetAttribute("InRound",false);player:SetAttribute("CharacterId",nil)
 player:SetAttribute("Energy",100);player:SetAttribute("SkillCooldown",0)
 local root,h=body(player)
 if root and h and h.Health>0 then Factory.place(player.Character,world.lobbyPosition) end
end
local function tryEscape(player)
 if not rules or not playing(player) then return end
 local record=participants[player]
 if rules:canEscape(record.entry.role=="Superviviente",inExit(player)) then
  record.status="Escapó";record.energy.requested=false
  if objectives then objectives:drop(player) end
  if not practice then profiles:reward(player,profiles.owner..":"..roundId..":escape:"..player.UserId,"escape",record.entry.id) end
  send(player,"message","¡Escapaste atravesando la salida! Espera la siguiente ronda en el campamento.")
  returnToLobby(player)
  player:SetAttribute("RoundStatus","Escapó")
  changed()
 end
end
local exitConnection
local function connectExit()
 if exitConnection then exitConnection:Disconnect() end
 exitConnection=world.exit.Touched:Connect(function(hit)
  local model=hit:FindFirstAncestorOfClass("Model")
  local player=model and Players:GetPlayerFromCharacter(model)
  if player then tryEscape(player) end
 end)
end
connectExit()
local function aliveCounts()
 local survivors,killers,escaped=0,0,0
 local last
 for player,record in pairs(participants) do
  if record.status=="Escapó" then escaped=escaped+1 end
  if playing(player) then
   if record.entry.role=="Asesino" then killers=killers+1 else survivors=survivors+1;last=player end
  end
 end
 return survivors,killers,escaped,last
end
local function updateLMS()
 if not rules then return end
 local survivors,_,_,last=aliveCounts()
 if rules:updateSurvivors(survivors) then
  local killer=Players:GetPlayerByUserId(killerUserId)
  musicKey="lastHope"
  if killer and last then
   if entryFor(killer).id=="guest666" and entryFor(last).id=="deathspeaker" then musicKey="brokenFriendship"
   elseif entryFor(killer).id=="tubers93" and entryFor(last).id=="pelotocino" then musicKey="baconLMS" end
  end
  if objectives then objectives:disableForLMS() end
  remote:FireAllClients("message","ÚLTIMO SUPERVIVIENTE · 1:30. La salida abre a 0:00; debes atravesarla.")
  changed()
 end
end
local function visible(attacker,target)
 local a=body(attacker);local b=body(target)
 if not a or not b then return false end
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={attacker.Character}
 local hit=workspace:Raycast(a.Position,b.Position-a.Position,params)
 return not hit or hit.Instance:IsDescendantOf(target.Character)
end
local context={records=function()return participants end,playing=playing,body=body,visible=visible,
 canInteract=canInteract,send=send,rules=function()return rules end,world=world,
 effect=function(data)remote:FireAllClients("effect",data)end}
abilities=Abilities.new(context)
local function useSkill(player,slot,aim) abilities:cast(player,slot or 1,aim) end
local function attack(player,aim)
 if playing(player) and entryFor(player).role=="Asesino" then abilities:cast(player,1,aim) end
end
remote.OnServerEvent:Connect(function(player,action,value,extra)
 if type(action)~="string" then return end
 -- Server-side rate limit, including puzzle input and character selection.
 local now=os.clock()
 local limit=limits[player] or {at=now,tokens=20}
 limit.tokens=math.min(20,limit.tokens+(now-limit.at)*10);limit.at=now;limits[player]=limit
 if action=="sprint" and value==false then
  if participants[player] then participants[player].energy.requested=false end
  return
 end
 if limit.tokens<1 then return end
 limit.tokens=limit.tokens-1
 if action=="ready" then send(player,"selected",selected[player] or "pelotocino");send(player,"state",snapshot());profiles:publish(player)
 elseif action=="select" then
  if phase~="Lobby" or type(value)~="string" or not byId[value] then return end
  selected[player]=value;selectionTouched[player]=true;profiles:select(player,value);player:SetAttribute("SelectedCharacterId",value);send(player,"selected",value)
 elseif action=="map" then
  if phase=="Lobby" and type(value)=="string" and mapById[value] then mapVotes[player]=value;send(player,"message","Mapa elegido: "..mapById[value].name) end
 elseif action=="buy" then
  if phase=="Lobby" and type(value)=="string" then local _,message=profiles:purchase(player,value);send(player,"message",message) end
 elseif action=="equip" then
  if phase=="Lobby" and type(value)=="string" and type(extra)=="string" then local _,message=profiles:equip(player,value,extra);send(player,"message",message) end
 elseif action=="profile" then profiles:publish(player)
 elseif action=="item" then if items then items:use(player,value) end
 elseif action=="practice" then
  if RunService:IsStudio() and phase=="Lobby" and #Players:GetPlayers()==1 then practiceRequested=true;remaining=3 end
 elseif action=="sprint" then
  if playing(player) and type(value)=="boolean" then participants[player].energy.requested=value end
 elseif action=="skill" then useSkill(player,value,extra)
 elseif action=="attack" then attack(player,value)
 elseif action=="struggle" then abilities:struggle(player,value)
 elseif action=="challenge" then if objectives then objectives:answer(player,value,extra) end
 elseif action=="challengeCancel" then if objectives then objectives:cancel(player) end end
end)
local function addPlayer(player)
 selected[player]="pelotocino"
 player:SetAttribute("SelectedCharacterId","pelotocino");player:SetAttribute("Energy",100)
 player:SetAttribute("InRound",false);player:SetAttribute("RoundStatus","Lobby")
 player.RespawnLocation=world.spawn
 local function spawned(character)
  if Native.consumeSwap(player,character) then return end
  Native.discard(player)
  born[player]=os.clock()
  local record=participants[player]
  if record and record.status=="Jugando" then record.status="Eliminado";record.energy.requested=false end
  player:SetAttribute("CharacterId",nil);player:SetAttribute("InRound",false)
  player:SetAttribute("RoundStatus",phase=="Ronda" and "Espectador" or "Lobby")
  if objectives then objectives:drop(player) end
 end
 player.CharacterAdded:Connect(spawned)
 if player.Character then spawned(player.Character) end
 task.spawn(function()
  profiles:load(player,function(data)
   if phase=="Lobby" and not selectionTouched[player] and byId[data.lastCharacter] then
    selected[player]=data.lastCharacter;player:SetAttribute("SelectedCharacterId",data.lastCharacter);send(player,"selected",data.lastCharacter)
   end
  end)
 end)
end
Players.PlayerAdded:Connect(addPlayer)
for _,player in ipairs(Players:GetPlayers()) do addPlayer(player) end
Players.PlayerRemoving:Connect(function(player)
 if objectives then objectives:drop(player) end
 task.spawn(function()profiles:close(player)end)
 mapVotes[player]=nil;selectionTouched[player]=nil
 if participants[player] then participants[player].status="Abandonó" end
 Native.discard(player);selected[player]=nil;born[player]=nil;limits[player]=nil;lastKiller[player.UserId]=nil
end)
local previews=RS:FindFirstChild("CharacterPreviews") or Instance.new("Folder");previews.Name="CharacterPreviews";previews.Parent=RS
local function refreshPreview(entry)
 local old=previews:FindFirstChild(entry.id);if old then old:Destroy() end
 local model=Factory.create(entry);model.Name=entry.id;model.HumanoidRootPart.Anchored=true;model.Parent=previews
end
for _,entry in ipairs(roster) do refreshPreview(entry) end
local catalogNPCUpdated=false
local function preloadCatalog()
 if Catalog.load() and not catalogNPCUpdated then
  for index,entry in ipairs(roster) do if entry.id=="junkbot" then world.refreshNPC(index);refreshPreview(entry) end end
  catalogNPCUpdated=true
 end
end
task.spawn(preloadCatalog)
local function preloadAvatars()
 if AvatarCatalog.load() then
  for index,entry in ipairs(roster) do
   if entry.id~="junkbot" then world.refreshNPC(index);refreshPreview(entry) end
  end
 end
end
task.spawn(preloadAvatars)
local function candidates()
 local list={}
 for _,player in ipairs(Players:GetPlayers()) do
  local root,h=body(player)
  local ready=player:HasAppearanceLoaded() or Native.isRestoredAvatar(player.Character) or os.clock()-(born[player] or os.clock())>8
  if root and h and h.Health>0 and ready then
   table.insert(list,{key=player.UserId,choice=selected[player],lastKiller=lastKiller[player.UserId] or 0})
  end
 end
 return list
end
local function chooseMap(list)
 local choice=MapCatalog[(roundId%#MapCatalog)+1].id;local votes={};local best=0
 for _,candidate in ipairs(list) do
  local player=Players:GetPlayerByUserId(candidate.key);local id=player and mapVotes[player]
  if id then votes[id]=(votes[id] or 0)+1 end
 end
 for _,map in ipairs(MapCatalog) do if (votes[map.id] or 0)>best then best=votes[map.id];choice=map.id end end
 return choice
end
local function beginRound(list,isPractice)
 world.loadMap(chooseMap(list));connectExit()
 roundId=roundId+1
 local plan,killer=Assignment.assign(list,roster)
 if isPractice then
  local chosen=byId[list[1].choice]
  plan={{key=list[1].key,id=chosen.role=="Superviviente" and chosen.id or "pelotocino"}};killer=0
 end
 if not plan then return false end
 participants={};rules=Rules.new(isPractice);practice=isPractice;killerUserId=killer;musicKey="";result="";resultsData=nil
 abilities.zones={};abilities.pending={};abilities.scheduled={}
 phase="Ronda"
 local survivorIndex=0
 for _,assignment in ipairs(plan) do
  local player=Players:GetPlayerByUserId(assignment.key)
  if player then
   local entry=byId[assignment.id]
   local model=Factory.create(entry)
   local data=profiles:get(player)
   local equipment=data and data.equipped[entry.id] or {skin=entry.id..":base",cosmetic=""}
   Cosmetics.apply(model,entry.id,equipment)
   local status=model:GetAttribute("ModelStatus")
   local display=entry.name..(model:GetAttribute("Placeholder") and " [provisional]" or "")
   if Native.equip(player,model,entry.id,display,entry.role=="Asesino" and 18 or 16) then
    local record={entry=entry,status="Jugando",energy=Stamina.new(),cooldowns={},items={},played=0,objectives=0,damage=0,eliminations=0,equipment=equipment}
    participants[player]=record
    local _,h=body(player)
    record.death=h.Died:Connect(function()
     if participants[player]==record and record.status=="Jugando" then
      record.status="Eliminado";record.energy.requested=false;player:SetAttribute("InRound",false);player:SetAttribute("RoundStatus","Eliminado")
      if objectives then objectives:drop(player) end
      local attacker=record.lastAttacker and participants[record.lastAttacker]
      if attacker and attacker.entry.role=="Asesino" then attacker.eliminations=attacker.eliminations+1 end
     end
    end)
    player:SetAttribute("InRound",true);player:SetAttribute("RoundStatus","Jugando");player:SetAttribute("ModelStatus",status)
    if entry.role=="Asesino" then
     lastKiller[player.UserId]=roundId
     Factory.place(model,world.center+world.killerSpawn)
    else
     survivorIndex=survivorIndex+1
     Factory.place(model,world.center+world.survivorSpawn+Vector3.new(((survivorIndex-1)%12)*7,0,math.floor((survivorIndex-1)/12)*5))
    end
    send(player,"message",(isPractice and "PRÁCTICA INDIVIDUAL: sin asesino ni LMS.\n" or "").."Juegas como "..entry.name.." · "..tostring(status)..(entry.id~=selected[player] and "\nAsignación automática para equilibrar los equipos; tu elección se conserva." or ""))
   end
  end
 end
 objectives=Objectives.new(world,rules,{canInteract=canInteract,send=send,changed=changed,reward=function(player,kind,event)
  local r=participants[player]
  if r then
   r.objectives=r.objectives+1
   send(player,"sfx","objective")
   if not practice then profiles:reward(player,profiles.owner..":"..roundId..":"..event..":"..player.UserId,kind,r.entry.id) end
  end
 end})
 items=RoundItems.new(world,context)
 updateLMS();changed()
 return true
end
local function finishRound(message,ending)
 local survivors,killers,escaped=aliveCounts()
 local killerVictory=not practice and killers>0 and escaped==0 and (ending=="timeout" or ending=="noSurvivors")
 local rows={};local mvp,mvpScore=nil,-1
 for player,record in pairs(participants) do
  local score=record.objectives*100+math.floor(record.damage)+(record.status=="Escapó" and 300 or 0)+record.eliminations*150
  if player.Parent==Players then
   local row={userId=player.UserId,name=player.DisplayName,character=record.entry.id,status=record.status,score=score,equipment=record.equipment,role=record.entry.role}
   table.insert(rows,row)
   if score>mvpScore then mvp=player;mvpScore=score end
   if not practice and record.played>=EconomyConfig.participationSeconds then profiles:reward(player,profiles.owner..":"..roundId..":participation:"..player.UserId,"participation",record.entry.id) end
   if killerVictory and record.entry.role=="Asesino" and playing(player) then
    profiles:reward(player,profiles.owner..":"..roundId..":killerWin:"..player.UserId,"killerWin",record.entry.id)
    row.victory=true
   end
   if record.status=="Jugando" then
    record.status=row.victory and "Victoria" or ending=="killerInactive" and "Interrumpida" or record.entry.role=="Superviviente" and "No escapó" or "Fin de ronda"
    row.status=record.status
   end
  end
 end
 if mvp and not practice and mvpScore>0 then profiles:reward(mvp,profiles.owner..":"..roundId..":mvp:"..mvp.UserId,"mvp",participants[mvp].entry.id) end
 table.sort(rows,function(a,b)if a.score==b.score then return a.userId<b.userId end;return a.score>b.score end)
 resultsData={rows=rows,mvp=mvp and mvp.UserId or 0,message=message,practice=practice,map=world.mapName,roundId=roundId}
 phase="Fin";remaining=8;musicKey="";result=message
 if objectives then objectives:destroy();objectives=nil end
 if items then items:destroy();items=nil end
 for player,record in pairs(participants) do
  if record.death then record.death:Disconnect() end
  if player.Parent==Players then returnToLobby(player);player:SetAttribute("RoundStatus",record.status);player:SetAttribute("CarriedCapsules",0) end
 end
 world.setGate(false,"Normal");broadcast();remote:FireAllClients("results",resultsData)
 for t=8,1,-1 do remaining=t;broadcast();task.wait(1) end
 participants={};rules=nil;phase="Lobby";remaining=15;killerUserId=0;practice=false;practiceRequested=false
end
game:BindToClose(function()
 for player in pairs(profiles.records) do task.spawn(function()profiles:close(player)end) end
 local untilTime=os.clock()+25
 while next(profiles.records) and os.clock()<untilTime do task.wait(.1) end
end)
while true do
 local list=candidates()
 if #list<2 and not (practiceRequested and #list==1 and #Players:GetPlayers()==1 and RunService:IsStudio()) then
  remaining=15;broadcast();task.wait(1)
 else
  if practiceRequested and #list==1 and remaining>3 then remaining=3 end
  local start=os.clock()
  broadcast();task.wait(1);remaining=remaining-(os.clock()-start)
  if remaining<=0 then
   list=candidates()
   local solo=practiceRequested and #list==1 and #Players:GetPlayers()==1 and RunService:IsStudio()
   if (#list>=2 or solo) and beginRound(list,solo) then
    local previous=os.clock();local nextBroadcast=0
    local outcome,ending
    while phase=="Ronda" do
     local now=os.clock();local dt=now-previous;previous=now
     for player,record in pairs(participants) do
      if playing(player) then
       local root,h=body(player)
       local horizontal=Vector3.new(root.AssemblyLinearVelocity.X,0,root.AssemblyLinearVelocity.Z).Magnitude
       record.played=record.played+dt
       local value,running=Stamina.step(record.energy,dt,horizontal>.5 or h.MoveDirection.Magnitude>.1,(record.drinkUntil or 0)>now)
       player:SetAttribute("Energy",math.floor(value))
       local base=running and (record.entry.role=="Asesino" and 25 or 24) or (record.entry.role=="Asesino" and 18 or 16)
       h.WalkSpeed=abilities:speed(player,base)
       tryEscape(player)
      end
     end
     abilities:tick();if items then items:tick() end;if objectives then objectives:tick() end
     local survivors,killers,escaped=aliveCounts()
     if survivors==0 then outcome="Fin de partida · "..escaped.." superviviente(s) escaparon.";ending="noSurvivors";break end
     if not practice and killers==0 then outcome="Partida interrumpida: el asesino ya no está activo.";ending="killerInactive";break end
     updateLMS()
     rules:tick(dt);world.setGate(rules.gateOpen,rules.mode)
     if rules.expired then outcome="Tiempo agotado · "..escaped.." superviviente(s) escaparon.";ending="timeout";break end
     if now>=nextBroadcast then broadcast();for player in pairs(participants) do if playing(player) then send(player,"combat",abilities:hud(player)) end end;nextBroadcast=now+.25 end
     task.wait(.1)
    end
    finishRound(outcome or "Partida finalizada.",ending)
   else remaining=15;practiceRequested=false end
  end
 end
 if phase=="Lobby" and not Catalog.ready() then task.spawn(preloadCatalog) end
 if phase=="Lobby" then task.spawn(preloadAvatars) end
end
