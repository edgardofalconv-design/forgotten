local RS=game:GetService("ReplicatedStorage")
local World=require(script.Parent.World)
local Challenge=require(RS.Shared.ChallengeRules)
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
 local function decor(name,size,pos,tint)
  local part=World.part(self.folder,name,size,pos,tint,Enum.Material.Neon)
  part.CanCollide=false;part.CanTouch=false;part.CanQuery=false;part.CastShadow=false;return part
 end
 for i,pos in ipairs(world.generatorPositions) do
  local base=World.part(self.folder,"Generador "..i,Vector3.new(5,4,3),world.center+pos+Vector3.new(0,2,0),Color3.fromRGB(63,71,75))
  local screen=decor("Panel generador "..i,Vector3.new(3,1,.15),base.Position+Vector3.new(0,.6,-1.6),tones[1])
  local label=World.label(screen,"G"..i.." · CABLES / INTERRUPTORES / CUERDA")
  for n=1,3 do decor("Cable",Vector3.new(.1,1.2,.1),base.Position+Vector3.new(-1+n*.55,-.6,-1.6),tones[n]) end
  local control=prompt(base,"Reparar generador","Generador "..i,function(player)self:open(player,"generator",i)end)
  self.generators[i]={base=base,screen=screen,label=label,prompt=control}
 end
 local kinds={"memory","piano","reflex","maze"}
 local titles={"MEMORIA","PIANO","REFLEJOS","LABERINTO"}
 for i,pos in ipairs(world.puzzlePositions) do
  local base=World.part(self.folder,"Estacion de puzle "..i,Vector3.new(4,3,3),world.center+pos+Vector3.new(0,1.5,0),Color3.fromRGB(57,68,86))
  World.label(base,"ESTACIÓN "..i.." · "..titles[i])
  local capsule=decor("Capsula "..i,Vector3.new(1,1.7,1),base.Position+Vector3.new(0,2.5,0),tones[2])
  capsule.Shape=Enum.PartType.Cylinder;capsule.Transparency=.8
  local pickup=prompt(capsule,"Llevar al depósito","Cápsula de energía",function(player,p)
   if rules:collectCapsule(i,player.UserId) then
    p.Enabled=false;capsule.Transparency=1;player:SetAttribute("CarriedCapsules",rules:carried(player.UserId));callbacks.changed()
    callbacks.send(player,"message","Cápsula recogida. Llévala al depósito junto a la salida.")
   end
  end)
  pickup.Enabled=false
  local solve=prompt(base,"Abrir puzle",titles[i],function(player)self:open(player,"puzzle",i)end)
  self.stations[i]={base=base,capsule=capsule,pickup=pickup,solve=solve,kind=kinds[i]}
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
 self.callbacks.send(player,"challenge",{token=s.token,family=s.family,id=s.id,stage=s.stage,challenge=s.challenge,serverNow=workspace:GetServerTimeNow()})
end
function Objectives:open(player,family,id)
 local source=family=="generator" and self.generators[id] or self.stations[id]
 if not source or self.rules.mode=="LMS" or (family=="generator" and self.rules.generators[id]) or (family=="puzzle" and self.rules.puzzles[id]) then return end
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
  self:cancel(player)
  if s.family=="generator" then
   if self.rules:completeGenerator(s.id) then
    local gen=self.generators[s.id];gen.prompt.Enabled=false;gen.screen.Color=tones[4];gen.label.Text="G"..s.id.." · ACTIVO"
    if self.callbacks.reward then self.callbacks.reward(player,"generator","generator:"..s.id) end
    self.callbacks.changed()
   end
  elseif self.rules:completePuzzle(s.id) then
   local station=self.stations[s.id];station.solve.Enabled=false;station.pickup.Enabled=true;station.capsule.Transparency=0
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
  local station=self.stations[id];station.capsule.Transparency=0;station.pickup.Enabled=self.rules.mode~="LMS"
 end
 player:SetAttribute("CarriedCapsules",0)
end
function Objectives:cancel(player)
 if self.sessions[player] then self.sessions[player]=nil;self.callbacks.send(player,"challengeClose") end
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
