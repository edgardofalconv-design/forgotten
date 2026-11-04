local RS=game:GetService("ReplicatedStorage")
local Config=require(RS.Shared.AbilityConfig)
local Factory=require(RS.Shared.CharacterFactory)
local Timing=require(RS.Shared.AbilityTiming)
local Abilities={};Abilities.__index=Abilities
function Abilities.new(context)return setmetatable({c=context,zones={},pending={},scheduled={}},Abilities)end
function Abilities:later(player,delay,callback)
 table.insert(self.scheduled,{player=player,record=self.c.records()[player],at=os.clock()+delay,callback=callback})
end
function Abilities:hold(attacker,target,kind,duration,escape)
 if not self.c.playing(target) then return end
 local r=self.c.records()[target];local now=os.clock()
 r.holdUntil=now+duration
 target.Character:SetAttribute("Action",kind);target.Character:SetAttribute("ActionAt",workspace:GetServerTimeNow())
 if escape then
  self.serial=(self.serial or 0)+1
  r.escape={token=tostring(self.serial)..":"..tostring(now),untilTime=now+duration,taps=0,last=-100}
  self.c.send(target,"escape",{token=r.escape.token,duration=duration,required=3,taps=0})
 end
end
function Abilities:struggle(player,token)
 if not self.c.playing(player) then return end
 local r=self.c.records()[player];local escape=r.escape;local now=os.clock()
 if not escape or type(token)~="string" or escape.token~=token or now>escape.untilTime or now-escape.last<.12 then return end
 escape.last=now;escape.taps=escape.taps+1
 if escape.taps>=3 then
  r.escape=nil;r.holdUntil=0
  player.Character:SetAttribute("Action","escape");player.Character:SetAttribute("ActionAt",workspace:GetServerTimeNow())
  self.c.send(player,"escapeClose")
 else self.c.send(player,"escape",{token=token,duration=escape.untilTime-now,required=3,taps=escape.taps}) end
end
function Abilities:enemies(player,range,requireSight)
 local result={};local root=self.c.body(player);if not root then return result end
 local role=self.c.records()[player].entry.role
 for other,r in pairs(self.c.records()) do
  local target=self.c.body(other)
  if other~=player and self.c.playing(other) and r.entry.role~=role and (target.Position-root.Position).Magnitude<=range and (not requireSight or self.c.visible(player,other)) then table.insert(result,other) end
 end
 table.sort(result,function(a,b)return (self.c.body(a).Position-root.Position).Magnitude<(self.c.body(b).Position-root.Position).Magnitude end)
 return result
end
function Abilities:damage(player,target,amount)
 if not self.c.playing(player) or not self.c.playing(target) then return false end
 local records=self.c.records();local source=records[player];local victim=records[target]
 if source.entry.role==victim.entry.role or (victim.invulnerableUntil or 0)>os.clock() then return false end
 local targetRoot,h=self.c.body(target)
 local character=target.Character
 if (victim.shieldUntil or 0)>os.clock() then amount=amount*(1-(victim.shield or 0)) end
 local before=h.Health;victim.lastAttacker=player;victim.lastDamage=os.clock()
 h:TakeDamage(math.max(0,amount));source.damage=(source.damage or 0)+math.min(before,amount)
 self.c.effect({kind="hit",position=targetRoot.Position,color="red",duration=.3})
 if character then character:SetAttribute("DamageAt",workspace:GetServerTimeNow()) end
 return true
end
function Abilities:slow(player,speed,duration)
 local r=self.c.records()[player];if r then
  r.slowSpeed=speed;r.slowUntil=os.clock()+duration
  if player.Character then player.Character:SetAttribute("StunnedUntil",workspace:GetServerTimeNow()+duration) end
 end
end
function Abilities:direction(player,aim)
 local root=self.c.body(player)
 if typeof(aim)=="Vector3" and aim.X==aim.X and aim.Y==aim.Y and aim.Z==aim.Z and aim.Magnitude>.1 and aim.Magnitude<2 then return aim.Unit end
 return root.CFrame.LookVector
end
function Abilities:ray(player,direction,range)
 local root=self.c.body(player)
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={player.Character}
 local hit=workspace:Raycast(root.Position,direction*range,params)
 local point=hit and hit.Position or root.Position+direction*range
 local model=hit and hit.Instance:FindFirstAncestorOfClass("Model")
 return model and game:GetService("Players"):GetPlayerFromCharacter(model),point
end
function Abilities:teleport(player,point,look)
 local center=self.c.world.center
 if math.abs(point.X-center.X)>116 or math.abs(point.Z-center.Z)>116 then return false end
 local ignore={}
 for other in pairs(self.c.records()) do if other.Character then table.insert(ignore,other.Character) end end
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances=ignore
 local root=self.c.body(player)
 if workspace:Raycast(root.Position,point-root.Position,params) then return false end
 local floor=workspace:Raycast(point+Vector3.new(0,6,0),Vector3.new(0,-24,0),params)
 if not floor then return false end
 local humanoid=player.Character:FindFirstChildOfClass("Humanoid")
 local height=humanoid.RigType==Enum.HumanoidRigType.R6 and 3.4 or humanoid.HipHeight+root.Size.Y/2+.4
 local position=floor.Position+Vector3.new(0,height,0)
 local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Exclude;overlap.FilterDescendantsInstances=ignore
 for _,part in ipairs(workspace:GetPartBoundsInBox(CFrame.new(position),Vector3.new(2.5,4.5,2.5),overlap)) do if part.CanCollide then return false end end
 Factory.place(player.Character,floor.Position)
 if look then player.Character:PivotTo(CFrame.lookAt(root.Position,Vector3.new(look.X,root.Position.Y,look.Z))) end
 return true
end
function Abilities:cast(player,slot,aim)
 if not self.c.playing(player) or type(slot)~="number" or slot%1~=0 then return end
 local record=self.c.records()[player];local list=Config[record.entry.id];local ability=list and list[slot]
 if not ability or record.itemUse or record.channel or (record.holdUntil or 0)>os.clock() then return end
 record.cooldowns=record.cooldowns or {}
 local now=os.clock()
 if (record.cooldowns[ability.id] or 0)>now then return end
 if record.energy.value<ability.cost then self.c.send(player,"message","No tienes suficiente energía.");return end
 local root,h=self.c.body(player);local direction=self:direction(player,aim)
 local enemies=self:enemies(player,ability.range,true)
 local target=enemies[1];local kind=ability.kind
 if (kind=="pull" or kind=="behind") and not target then return end
 if kind=="lastFighter" and self.c.rules().mode~="LMS" and h.Health>35 then self.c.send(player,"message","Last Fighter se activa en LMS o con 35 de vida o menos.");return end
 if (kind=="heal" or kind=="repair") and h.Health>=h.MaxHealth then return end
 if kind=="behind" then
  local otherRoot=self.c.body(target)
  if not self:teleport(player,otherRoot.Position-otherRoot.CFrame.LookVector*6,otherRoot.Position) then self.c.send(player,"message","No hay un lugar libre detrás del objetivo.");return end
 elseif kind=="step" then
  local flat=Vector3.new(direction.X,0,direction.Z)
  if flat.Magnitude<.05 or not self:teleport(player,root.Position+flat.Unit*ability.range,root.Position+direction*40) then return end
  record.invulnerableUntil=now+ability.duration
 end
 record.cooldowns[ability.id]=now+ability.cooldown;record.energy.value=math.max(0,record.energy.value-ability.cost)
 record.abilitiesUsed=(record.abilitiesUsed or 0)+1
 local punching=ability.id=="cane" and (record.caneAwayUntil or 0)>now
 player.Character:SetAttribute("Action",punching and "punch" or ability.id);player.Character:SetAttribute("ActionAt",workspace:GetServerTimeNow())
 self.c.effect({kind=ability.id=="sixthHour" and "transformation" or kind,ability=punching and "punch" or ability.id,model=player.Character,position=root.Position,color=record.entry.role=="Asesino" and "red" or "blue",duration=.45,radius=kind=="areaDamage" and ability.range or 3})
 local function perform()
 if not self.c.playing(player) or self.c.records()[player]~=record then return end
 now=os.clock();root,h=self.c.body(player)
 enemies=self:enemies(player,punching and 6 or ability.range,true);target=enemies[1]
 if kind=="melee" then if target then self:damage(player,target,ability.amount) end
 elseif kind=="behind" and target then
  self:hold(player,target,"grabbed",.55,false)
  local grabbed=target
  self:later(player,.5,function()
   if self.c.playing(grabbed) and self.c.visible(player,grabbed) then
    local victim=self.c.body(grabbed);local source=self.c.body(player)
    if (victim.Position-source.Position).Magnitude<=10 then victim.AssemblyLinearVelocity=source.CFrame.LookVector*18+Vector3.new(0,9,0) end
   end
  end)
 elseif kind=="stun" then if target then self:slow(target,ability.amount,ability.duration) end
 elseif kind=="pull" and target then
  self:damage(player,target,ability.amount);self:slow(target,6,ability.duration)
  local targetRoot=self.c.body(target);local delta=root.Position-targetRoot.Position
  if delta.Magnitude>.1 then targetRoot.AssemblyLinearVelocity=delta.Unit*30+Vector3.new(0,8,0) end
  self.c.effect({kind="beam",position=root.Position,finish=targetRoot.Position,color="red",duration=.35})
 elseif kind=="speed" then record.boostSpeed=ability.amount;record.boostUntil=now+ability.duration
 elseif kind=="heal" then h.Health=math.min(h.MaxHealth,h.Health+ability.amount)
 elseif kind=="repair" then record.channel={kind="repair",untilTime=now+ability.duration,position=root.Position,started=now,amount=ability.amount}
 elseif kind=="shield" then record.shield=ability.amount;record.shieldUntil=now+ability.duration
 elseif kind=="lastFighter" then
  h.Health=math.min(h.MaxHealth,h.Health+ability.amount);record.energy.value=math.max(record.energy.value,50);record.boostSpeed=26;record.boostUntil=now+ability.duration
 elseif kind=="teamShield" or kind=="teamHeal" then
  for other,r in pairs(self.c.records()) do
   local rRoot,otherH=self.c.body(other)
   if self.c.playing(other) and r.entry.role==record.entry.role and (rRoot.Position-root.Position).Magnitude<=ability.range and (other==player or self.c.visible(player,other)) then
    if kind=="teamShield" then r.shield=ability.amount;r.shieldUntil=now+ability.duration
    else otherH.Health=math.min(otherH.MaxHealth,otherH.Health+ability.amount);r.linkUntil=now+ability.duration end
    self.c.effect({kind="beam",position=root.Position,finish=rRoot.Position,color="blue",duration=.4})
   end
  end
 elseif kind=="reveal" then
  local models={}
  for _,other in ipairs(self:enemies(player,ability.range,false)) do table.insert(models,other.Character) end
  self.c.send(player,"reveal",{models=models,duration=ability.duration})
 elseif kind=="bacon" or kind=="caneThrow" then
  local other,point=self:ray(player,direction,ability.range)
  local flight=math.clamp((point-root.Position).Magnitude/45,.12,.8)
  self.c.effect({kind="projectile",projectile=kind=="bacon" and "bacon" or "cane",model=player.Character,position=root.Position,finish=point,duration=flight,color="blue"})
  if kind=="caneThrow" then
   record.caneAwayUntil=now+flight*2+.2
   player.Character:SetAttribute("CaneAwayUntil",workspace:GetServerTimeNow()+flight*2+.2)
   self:later(player,flight,function()
    local hand=self.c.body(player)
    self.c.effect({kind="projectile",projectile="cane",model=player.Character,position=point,finish=hand.Position,duration=flight,returning=true,color="blue"})
   end)
   self:later(player,flight*2+.2,function()
    player.Character:SetAttribute("CaneAwayUntil",0)
    local actionAt=player.Character:GetAttribute("ActionAt") or 0
    if workspace:GetServerTimeNow()-actionAt>.55 then player.Character:SetAttribute("Action","caneRecover");player.Character:SetAttribute("ActionAt",workspace:GetServerTimeNow()) end
   end)
  end
  self:later(player,flight,function()
   self.c.effect({kind="burst",position=point,color="blue",radius=1.4,duration=.25})
   if other and self.c.playing(other) and (self.c.body(other).Position-point).Magnitude<=5 then
    local otherRecord=self.c.records()[other]
    if kind=="bacon" and otherRecord.entry.role==record.entry.role then
     local _,otherH=self.c.body(other);otherH.Health=math.min(otherH.MaxHealth,otherH.Health+ability.amount)
    elseif otherRecord.entry.role~=record.entry.role then self:slow(other,kind=="caneThrow" and ability.amount or 8,ability.duration) end
   end
  end)
 elseif kind=="ray" or kind=="blast" then
  local other,point=self:ray(player,direction,ability.range)
  self.c.effect({kind="beam",position=root.Position,finish=point,color=kind=="blast" and "red" or "blue",duration=.35})
  if kind=="blast" then
   self.c.effect({kind="burst",position=point,color="red",radius=12,duration=.6})
   for _,enemy in ipairs(self:enemies(player,ability.range+12,true)) do
    local r=self.c.body(enemy);if (r.Position-point).Magnitude<=12 then self:damage(player,enemy,ability.amount) end
   end
  elseif other and self.c.playing(other) then
   local otherRecord=self.c.records()[other]
   if otherRecord.entry.role~=record.entry.role then
    self:damage(player,other,ability.amount)
    self:slow(other,8,ability.duration)
   end
  end
 elseif kind=="areaSlow" or kind=="areaDamage" then
  for _,other in ipairs(enemies) do if kind=="areaSlow" then self:slow(other,ability.amount,ability.duration) else self:damage(player,other,ability.amount) end end
 elseif kind=="slam" or kind=="pounce" then
  root.AssemblyLinearVelocity=root.CFrame.LookVector*(kind=="pounce" and 34 or 12)+Vector3.new(0,22,0)
  table.insert(self.pending,{player=player,at=now+.5,range=ability.range,amount=ability.amount,slow=kind=="slam",pounce=kind=="pounce"})
 elseif kind=="fire" then
  local _,point=self:ray(player,direction,18)
  table.insert(self.zones,{player=player,position=point,expires=now+ability.duration,next=now,radius=ability.range,damage=ability.amount})
  self.c.effect({kind="fire",position=point,color="red",radius=ability.range,duration=ability.duration})
 end
 end
 local windup=Timing[ability.id] or 0
 if windup>0 then self:later(player,windup,perform) else perform() end
end
function Abilities:tick()
 local now=os.clock()
 for i=#self.scheduled,1,-1 do
  local item=self.scheduled[i]
  if now>=item.at then
   table.remove(self.scheduled,i)
   if self.c.playing(item.player) and self.c.records()[item.player]==item.record then item.callback() end
  end
 end
 for i=#self.pending,1,-1 do
  local impact=self.pending[i]
  if now>=impact.at then
   if self.c.playing(impact.player) then
    for _,other in ipairs(self:enemies(impact.player,impact.range,true)) do
     self:damage(impact.player,other,impact.amount)
     if impact.slow then self:slow(other,6,2) end
     if impact.pounce and self.c.playing(other) then self:hold(impact.player,other,"pinned",1.6,true) end
    end
    self.c.effect({kind="burst",position=self.c.body(impact.player).Position,color="blue",radius=impact.range,duration=.6})
   end
   table.remove(self.pending,i)
  end
 end
 for i=#self.zones,1,-1 do
  local zone=self.zones[i]
  if now>=zone.expires or not self.c.playing(zone.player) then table.remove(self.zones,i)
  elseif now>=zone.next then
   zone.next=now+1
   for _,other in ipairs(self:enemies(zone.player,60,true)) do if (self.c.body(other).Position-zone.position).Magnitude<=zone.radius then self:damage(zone.player,other,zone.damage) end end
  end
 end
 for player,record in pairs(self.c.records()) do
  if self.c.playing(player) then
   local root,h=self.c.body(player)
   if record.escape and now>=record.escape.untilTime then record.escape=nil;self.c.send(player,"escapeClose") end
   if record.channel then
    local channel=record.channel
    if (record.lastDamage or 0)>channel.started or (root.Position-channel.position).Magnitude>3 then record.channel=nil
    elseif now>=channel.untilTime then h.Health=math.min(h.MaxHealth,h.Health+channel.amount);record.channel=nil end
   end
  end
 end
end
function Abilities:speed(player,base)
 local r=self.c.records()[player];local now=os.clock()
 if (r.holdUntil or 0)>now then return 0 end
 if r.itemUse or r.channel then return 8 end
 if (r.boostUntil or 0)>now then base=math.max(base,r.boostSpeed) end
 if (r.drinkUntil or 0)>now then base=base*require(RS.Shared.ItemConfig).energyDrink.speedMultiplier end
 if (r.slowUntil or 0)>now then base=math.min(base,r.slowSpeed) end
 return base
end
function Abilities:hud(player)
 local r=self.c.records()[player];if not r then return nil end
 local now=os.clock();local cooldowns={};local statuses={}
 for i,a in ipairs(Config[r.entry.id]) do cooldowns[i]=math.max(0,math.ceil((r.cooldowns and r.cooldowns[a.id] or 0)-now)) end
 for key,label in pairs({shieldUntil="ESCUDO",boostUntil="VELOCIDAD",slowUntil="RALENTIZADO",drinkUntil="ENERGÍA INFINITA · SPEED III",linkUntil="VINCULADO",invulnerableUntil="FANTASMA"}) do if (r[key] or 0)>now then table.insert(statuses,label) end end
 if r.itemUse then table.insert(statuses,"MEDKIT · "..math.max(0,math.ceil(r.itemUse.untilTime-now)).." s") end
 if r.channel then table.insert(statuses,"REPARANDO") end
 if r.escape then table.insert(statuses,"PULSA E · ESCAPAR") end
 return {character=r.entry.id,cooldowns=cooldowns,statuses=statuses,items=r.items or {},carried=self.c.rules():carried(player.UserId)}
end
return Abilities
