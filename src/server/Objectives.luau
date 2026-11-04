local RS=game:GetService("ReplicatedStorage")
local World=require(script.Parent.World)
local Challenge=require(RS.Shared.ChallengeRules)
local Generator=require(RS.Shared.GeneratorVisuals)
local Objectives={};Objectives.__index=Objectives
local tones={Color3.fromRGB(221,79,70),Color3.fromRGB(74,139,226),Color3.fromRGB(235,195,70),Color3.fromRGB(91,189,124)}
function Objectives.new(world,rules,callbacks)
 local self=setmetatable({rules=rules,callbacks=callbacks,sessions={},connections={},prompts={},stations={},generators={},serial=0,destroyed=false},Objectives)
 self.folder=Instance.new("Folder");self.folder.Name="ObjetivosDeRonda";self.folder.Parent=world.arena
 local function connect(event,fn)table.insert(self.connections,event:Connect(fn))end
 local function prompt(part,action,title,fn)
  local p=Instance.new("ProximityPrompt");p.ActionText=action;p.ObjectText=title;p.MaxActivationDistance=10;p.RequiresLineOfSight=true;p.Parent=part
  table.insert(self.prompts,p)
  connect(p.Triggered,function(player)
   if not self.destroyed and rules.mode~="LMS" and p.Enabled and callbacks.canInteract(player,part) then fn(player,p) end
  end)
  return p
 end
 local function decor(name,size,pos,tint,parent)
  local part=World.part(parent or self.folder,name,size,pos,tint,Enum.Material.Neon)
  part.CanCollide=false;part.CanTouch=false;part.CanQuery=false;part.CastShadow=false;return part
 end
 for i,pos in ipairs(world.generatorPositions) do
  local view=Generator.build(self.folder,world.center+pos,World,i)
  view.prompt=prompt(view.base,"Reparar generador","Generador "..i,function(player)self:open(player,"generator",i)end)
  self.generators[i]=view
 end
 local kinds={"memory","piano","reflex","maze"}
 local titles={"MEMORIA","PIANO","REFLEJOS","LABERINTO"}
 for i,pos in ipairs(world.puzzlePositions) do
  local base=World.part(self.folder,"Estacion de puzle "..i,Vector3.new(4,3,3),world.center+pos+Vector3.new(0,1.5,0),Color3.fromRGB(57,68,86))
  local marquee=decor("Cabecera de estación",Vector3.new(3.7,.65,.12),base.Position+Vector3.new(0,1.03,-1.59),Color3.fromRGB(33,45,50),base)
  marquee.Material=Enum.Material.Metal
  local stationLabel=World.label(marquee,titles[i])
  if i==1 then
   for pad=1,4 do decor("Pulsador de memoria",Vector3.new(.62,.62,.12),base.Position+Vector3.new((pad-2.5)*.8,-.1,-1.58),tones[pad],base) end
  elseif i==2 then
   for key=1,7 do
    local white=decor("Tecla de piano",Vector3.new(.43,1.1,.14),base.Position+Vector3.new((key-4)*.47,-.2,-1.58),Color3.fromRGB(218,219,207),base);white.Material=Enum.Material.SmoothPlastic
    if key%3~=0 then local black=decor("Tecla sostenida",Vector3.new(.22,.6,.1),base.Position+Vector3.new((key-3.6)*.47,.05,-1.7),Color3.fromRGB(24,29,32),base);black.Material=Enum.Material.SmoothPlastic end
   end
  elseif i==3 then
   for lamp=1,3 do
    local bulb=decor("Señal de reflejos",Vector3.new(.72,.72,.14),base.Position+Vector3.new((lamp-2),-.15,-1.6),tones[({1,3,4})[lamp]],base);bulb.Shape=Enum.PartType.Ball
   end
  else
   for row=1,4 do for column=1,6 do
    local tile=decor("Circuito del laberinto",Vector3.new(.44,.3,.08),base.Position+Vector3.new((column-3.5)*.49,.5-row*.34,-1.56),(row+column)%3==0 and tones[2] or Color3.fromRGB(37,56,66),base)
    tile.Material=(row+column)%3==0 and Enum.Material.Neon or Enum.Material.Metal
   end end
  end
  local capsule=decor("Capsula "..i,Vector3.new(1,1.7,1),base.Position+Vector3.new(0,2.5,0),tones[2])
  capsule.Size=Vector3.new(1.7,1,1);capsule.Shape=Enum.PartType.Cylinder;capsule.CFrame=capsule.CFrame*CFrame.Angles(0,0,math.pi/2)
  local capsuleParts={capsule}
  for _,offset in ipairs({-.9,.9}) do
   local cap=decor("Anillo de cápsula",Vector3.new(.18,1.1,1.1),capsule.Position+Vector3.new(0,offset,0),Color3.fromRGB(126,143,148),capsule)
   cap.Shape=Enum.PartType.Cylinder;cap.CFrame=cap.CFrame*CFrame.Angles(0,0,math.pi/2);cap.Material=Enum.Material.Metal;table.insert(capsuleParts,cap)
  end
  local function showCapsule(transparency)for _,piece in ipairs(capsuleParts) do piece.Transparency=transparency end end
  showCapsule(.8)
  local pickup=prompt(capsule,"Llevar al depósito","Cápsula de energía",function(player,p)
   if rules:collectCapsule(i,player.UserId) then
    p.Enabled=false;showCapsule(1);player:SetAttribute("CarriedCapsules",rules:carried(player.UserId));callbacks.changed()
    callbacks.send(player,"message","Cápsula recogida. Llévala al depósito junto a la salida.")
   end
  end)
  pickup.Enabled=false
  local solve=prompt(base,"Abrir puzle",titles[i],function(player)self:open(player,"puzzle",i)end)
  self.stations[i]={base=base,capsule=capsule,pickup=pickup,solve=solve,kind=kinds[i],label=stationLabel,showCapsule=showCapsule,capsuleParts=capsuleParts}
 end
 local depot=World.part(self.folder,"Deposito de capsulas",Vector3.new(7,4,4),world.center+world.depotPosition+Vector3.new(0,2,0),tones[4])
 World.label(depot,"DEPÓSITO DE ENERGÍA\nENTREGA LAS CÁPSULAS AQUÍ")
 prompt(depot,"Depositar cápsulas","Depósito de energía",function(player)
  local deposited=rules:depositCapsules(player.UserId)
  player:SetAttribute("CarriedCapsules",rules:carried(player.UserId))
  callbacks.send(player,"message",#deposited>0 and (#deposited.." cápsula(s) depositadas.") or "No llevas cápsulas.")
  callbacks.changed()
 end)
 return self
end
function Objectives:publish(player,s)
 if s.family=="generator" then
  Generator.progress(self.generators[s.id],s.stage,s.challenge)
  if player.Character then player.Character:SetAttribute("RepairStage",s.stage);player.Character:SetAttribute("RepairPullAt",self.generators[s.id].model:GetAttribute("PullAt") or 0) end
 end
 self.callbacks.send(player,"challenge",{token=s.token,family=s.family,id=s.id,stage=s.stage,challenge=s.challenge,serverNow=workspace:GetServerTimeNow()})
end
function Objectives:open(player,family,id)
 local source=family=="generator" and self.generators[id] or self.stations[id]
 if not source or self.rules.mode=="LMS" or (family=="generator" and self.rules.generators[id]) or (family=="puzzle" and self.rules.puzzles[id]) then return end
 self:cancel(player)
 self.serial=self.serial+1
 local kind=family=="generator" and "wires" or source.kind
 local s={family=family,id=id,base=source.base,stage=1,token=tostring(self.serial)..":"..tostring(workspace:GetServerTimeNow())}
 s.challenge=Challenge.new(kind,workspace:GetServerTimeNow(),math.random)
 self.sessions[player]=s;self:publish(player,s)
end
function Objectives:answer(player,token,value)
 local s=self.sessions[player]
 if self.destroyed or not s or token~=s.token then return end
 if self.rules.mode=="LMS" or not self.callbacks.canInteract(player,s.base)
  or (s.family=="generator" and self.rules.generators[s.id]) or (s.family=="puzzle" and self.rules.puzzles[s.id]) then self:cancel(player);return end
 local result=Challenge.input(s.challenge,value,workspace:GetServerTimeNow())
 if result=="ignored" then return end
 if result=="expired" or result=="wrong" then self:cancel(player);self.callbacks.send(player,"message","Intento fallido. Vuelve a abrir la estación.");return end
 if result=="complete" then
  if s.family=="generator" and s.stage<3 then
   s.stage=s.stage+1;s.challenge=Challenge.new(s.stage==2 and "switches" or "rope",workspace:GetServerTimeNow(),math.random);self:publish(player,s);return
  end
  if s.family=="generator" then Generator.progress(self.generators[s.id],s.stage,s.challenge) end
  self:cancel(player)
  if s.family=="generator" then
   if self.rules:completeGenerator(s.id) then
    local gen=self.generators[s.id];gen.prompt.Enabled=false;gen.screen.Color=tones[4];gen.label.Text="G"..s.id.." · ACTIVO"
    Generator.complete(gen)
    if self.callbacks.reward then self.callbacks.reward(player,"generator","generator:"..s.id) end
    self.callbacks.changed()
   end
  elseif self.rules:completePuzzle(s.id) then
   local station=self.stations[s.id];station.solve.Enabled=false;station.pickup.Enabled=true;station.showCapsule(0);station.label.Text="RESUELTO · RECOGE LA CÁPSULA"
   if self.callbacks.reward then self.callbacks.reward(player,"puzzle","puzzle:"..s.id) end
   self.callbacks.send(player,"message","Puzle resuelto. Recoge la cápsula y llévala al depósito.");self.callbacks.changed()
  end
 else self:publish(player,s) end
end
function Objectives:tick()
 if os.clock()<(self.nextCheck or 0) then return end
 self.nextCheck=os.clock()+1
 for player,s in pairs(self.sessions) do
  if workspace:GetServerTimeNow()>s.challenge.deadline or not self.callbacks.canInteract(player,s.base) then self:cancel(player) end
 end
end
function Objectives:drop(player)
 self:cancel(player)
 for _,id in ipairs(self.rules:dropCapsules(player.UserId)) do
  local station=self.stations[id];station.showCapsule(0);station.pickup.Enabled=self.rules.mode~="LMS"
 end
 player:SetAttribute("CarriedCapsules",0)
end
function Objectives:cancel(player)
 if self.sessions[player] then
  if player.Character then player.Character:SetAttribute("RepairStage",0) end
  self.sessions[player]=nil;self.callbacks.send(player,"challengeClose")
 end
end
function Objectives:disableForLMS()
 for player in pairs(self.sessions) do self:cancel(player) end
 for _,prompt in ipairs(self.prompts) do prompt.Enabled=false end
end
function Objectives:destroy()
 self.destroyed=true
 for player in pairs(self.sessions) do self:cancel(player) end
 for _,connection in ipairs(self.connections) do connection:Disconnect() end
 self.folder:Destroy()
end
return Objectives
