local DataStore=game:GetService("DataStoreService")
local HttpService=game:GetService("HttpService")
local RS=game:GetService("ReplicatedStorage")
local Data=require(RS.Shared.ProfileData)
local Profiles={}
Profiles.__index=Profiles
function Profiles.new(send)
 local self=setmetatable({records={},send=send,owner=game.JobId~="" and game.JobId or HttpService:GenerateGUID(false)},Profiles)
 local ok,store=pcall(function()return DataStore:GetDataStore(game:GetService("RunService"):IsStudio() and "FORGOTTEN_Profiles_v2_Studio" or "FORGOTTEN_Profiles_v2")end)
 if ok then self.store=store end
 task.spawn(function()
  while true do
   task.wait(45)
   for player,record in pairs(self.records) do if record.mode=="persistent" and not record.closing then task.spawn(function()self:save(player,false)end) end end
  end
 end)
 return self
end
function Profiles:publish(player)
 local r=self.records[player]
 if r and r.data then self.send(player,"profile",Data.public(r.data,r.mode)) end
end
function Profiles:load(player,onReady)
 local record={mode="loading",revision=0};self.records[player]=record
 local loaded,reason
 for attempt=1,3 do
  if not self.store then break end
  local ok,result=pcall(function()
   return self.store:UpdateAsync("user_"..player.UserId,function(old)
    local now=os.time()
    if old and type(old)~="table" then reason="Perfil incompatible";return nil end
    if old and old.session and old.session.owner~=self.owner and old.session.expires>now then reason="Otra sesión está guardando tu progreso";return nil end
    local data,errorText=Data.normalize(old and old.data)
    if old and old.data==nil then reason="Perfil incompatible";return nil end
    if not data then reason=errorText;return nil end
    return {version=2,data=data,session={owner=self.owner,expires=now+180},updatedAt=now}
   end)
  end)
  if ok and result and result.session and result.session.owner==self.owner then loaded=result;break end
  if ok and reason then break end
  reason="Guardado no disponible"
  if attempt<3 then task.wait(attempt*.5) end
 end
 if loaded then record.mode="persistent";record.data=loaded.data;record.expires=loaded.session.expires
 else
  record.mode=reason=="Otra sesión está guardando tu progreso" and "locked" or "session"
  record.data=Data.new()
  if record.mode=="locked" then record.data.coins=0 end
 end
 if record.closing or not player.Parent then self:close(player);return end
 self:publish(player)
 if record.mode~="persistent" then self.send(player,"message",record.mode=="locked" and "El progreso está abierto en otra sesión. La tienda queda bloqueada." or "Modo de sesión: las monedas y compras de esta prueba no se guardarán. El progreso existente no se sobrescribe.") end
 if onReady then onReady(record.data) end
end
function Profiles:get(player)
 local r=self.records[player]
 return r and r.data
end
function Profiles:mutable(player)
 local r=self.records[player]
 if not r or not r.data or r.closing or r.mode=="locked" or r.mode=="loading" then return nil end
 if r.mode=="persistent" and os.time()>=r.expires then r.mode="locked";self:publish(player);return nil end
 return r
end
function Profiles:purchase(player,id)
 local r=self:mutable(player);if not r then return false,"La tienda espera a que tu progreso esté disponible." end
 local ok,message=Data.purchase(r.data,id)
 if ok then r.revision=r.revision+1;self:publish(player) end
 return ok,message
end
function Profiles:equip(player,character,id)
 local r=self:mutable(player);if not r then return false,"El inventario no está disponible." end
 local ok,message=Data.equip(r.data,character,id)
 if ok then r.revision=r.revision+1;self:publish(player) end
 return ok,message
end
function Profiles:select(player,id)
 local r=self:mutable(player)
 if r and Data.select(r.data,id) then r.revision=r.revision+1 end
end
function Profiles:reward(player,receipt,kind,character)
 local r=self:mutable(player);if not r then return false end
 local ok,coins,unlocked=Data.reward(r.data,receipt,kind,character)
 if ok then
  r.revision=r.revision+1;self:publish(player)
  self.send(player,"reward",{coins=coins,reason=kind,unlocked=unlocked})
 end
 return ok
end
function Profiles:save(player,release)
 local r=self.records[player]
 if not r or r.mode~="persistent" or not self.store or r.saving then return false end
 r.saving=true
 local snapshot=Data.normalize(r.data)
 local ok,result=pcall(function()
  return self.store:UpdateAsync("user_"..player.UserId,function(old)
   if not old or not old.session or old.session.owner~=self.owner or old.session.expires<=os.time() then return nil end
   local session
   if not release then session={owner=self.owner,expires=os.time()+180} end
   return {version=2,data=snapshot,session=session,updatedAt=os.time()}
  end)
 end)
 r.saving=false
 if ok and result then
  if not release then r.expires=result.session.expires end
  return true
 end
 if ok then r.mode="locked";self:publish(player) else warn("No se pudo guardar el perfil de "..player.UserId.."; se mantiene pendiente.") end
 return false
end
function Profiles:close(player)
 local r=self.records[player];if not r then return end
 r.closing=true
 if r.mode=="loading" then return end
 local deadline=os.clock()+12
 while r.saving and os.clock()<deadline do task.wait(.1) end
 if r.mode=="persistent" then
  for attempt=1,3 do if self:save(player,true) then break end;task.wait(.5) end
 end
 self.records[player]=nil
end
return Profiles
