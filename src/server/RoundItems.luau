local RS=game:GetService("ReplicatedStorage")
local Config=require(RS.Shared.ItemConfig)
local World=require(script.Parent.World)
local Items={};Items.__index=Items
function Items.new(world,context)
 local self=setmetatable({c=context,connections={}},Items)
 self.folder=Instance.new("Folder");self.folder.Name="ObjetosDePartida";self.folder.Parent=world.arena
 for i,pos in ipairs(world.itemSpawns) do
  local kind=i%2==1 and "medkit" or "energyDrink"
  local color=kind=="medkit" and Color3.fromRGB(176,57,53) or Color3.fromRGB(73,166,116)
  local part=World.part(self.folder,Config[kind].name,kind=="medkit" and Vector3.new(2.2,1.4,1.6) or Vector3.new(.9,1.7,.9),world.center+pos+Vector3.new(0,1.2,0),color,Enum.Material.Metal)
  if kind=="energyDrink" then part.Shape=Enum.PartType.Cylinder end
  World.label(part,kind=="medkit" and "+ MEDKIT" or "ENERGY")
  local prompt=Instance.new("ProximityPrompt");prompt.ActionText="Recoger";prompt.ObjectText=Config[kind].name;prompt.MaxActivationDistance=9;prompt.Parent=part
  local claimed=false
  table.insert(self.connections,prompt.Triggered:Connect(function(player)
   if claimed or not context.canInteract(player,part) then return end
   local record=context.records()[player];record.items=record.items or {}
   if #record.items>=Config.slots then context.send(player,"message","Tus dos ranuras están ocupadas.");return end
   for _,item in ipairs(record.items) do if item==kind then context.send(player,"message","Solo puedes llevar una unidad de cada objeto.");return end end
   claimed=true;table.insert(record.items,kind);part:Destroy();context.send(player,"message",Config[kind].name.." recogido.")
   context.send(player,"sfx","item")
  end))
 end
 return self
end
function Items:use(player,slot)
 if not self.c.playing(player) or type(slot)~="number" or slot%1~=0 or slot<1 or slot>2 then return end
 local r=self.c.records()[player]
 if r.entry.role~="Superviviente" or r.itemUse or r.channel then return end
 local kind=r.items and r.items[slot]
 if not Config[kind] then return end
 local root,h=self.c.body(player);local now=os.clock()
 if kind=="medkit" then
  if h.Health>=h.MaxHealth then return end
  r.itemUse={kind=kind,slot=slot,started=now,untilTime=now+7,position=root.Position}
  player.Character:SetAttribute("ItemAction","medkit");player.Character:SetAttribute("ItemActionUntil",workspace:GetServerTimeNow()+7)
  self.c.send(player,"message","Usando Medkit: permanece quieto durante 7 segundos.")
 else
  table.remove(r.items,slot);r.drinkUntil=now+6;r.energy.value=100;r.energy.exhausted=false
  player.Character:SetAttribute("ItemAction","drink");player.Character:SetAttribute("ItemActionUntil",workspace:GetServerTimeNow()+1.1)
  self.c.send(player,"message","Energy Drink · 6 segundos de energía infinita y Speed III.")
  self.c.send(player,"sfx","item")
 end
end
function Items:tick()
 local now=os.clock()
 for player,r in pairs(self.c.records()) do
  if r.itemUse then
   if not self.c.playing(player) then r.itemUse=nil
   else
    local root,h=self.c.body(player);local use=r.itemUse
    if (root.Position-use.position).Magnitude>3 or (r.lastDamage or 0)>use.started then r.itemUse=nil;player.Character:SetAttribute("ItemActionUntil",0);self.c.send(player,"message","Medkit interrumpido; conservas el objeto.")
    elseif now>=use.untilTime then
     if r.items[use.slot]=="medkit" then table.remove(r.items,use.slot);h.Health=h.MaxHealth;self.c.send(player,"sfx","item") end
     r.itemUse=nil
    end
   end
  end
 end
end
function Items:destroy()
 for _,connection in ipairs(self.connections) do connection:Disconnect() end
 self.folder:Destroy()
end
return Items
