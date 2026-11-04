-- Pure profile transactions: no network/yields inside purchases or reward grants.
local Config=require(script.Parent.EconomyConfig)
local Catalog=require(script.Parent.ShopCatalog)
local Data={}
local items={};local characters={}
for _,item in ipairs(Catalog) do items[item.id]=item;if item.kind=="character" then characters[item.character]=true end end
local function integer(value,maximum)
 return type(value)=="number" and value==value and value>=0 and value<=maximum and value%1==0
end
function Data.new()
 local p={version=2,coins=Config.starterCoins,owned={},equipped={},xp={},receipts={},receiptOrder={},lastCharacter="pelotocino"}
 for _,item in ipairs(Catalog) do if item.included then p.owned[item.id]=true end end
 for id in pairs(characters) do p.equipped[id]={skin=id..":base",cosmetic=""};p.xp[id]=0 end
 return p
end
function Data.normalize(raw)
 if raw==nil then return Data.new() end
 if type(raw)~="table" or raw.version~=2 or not integer(raw.coins,Config.maxCoins) then return nil,"Perfil incompatible; no se sobrescribe." end
 local p=Data.new();p.coins=raw.coins
 for id in pairs(items) do if type(raw.owned)=="table" and raw.owned[id]==true then p.owned[id]=true end end
 for id in pairs(characters) do
  local xp=type(raw.xp)=="table" and raw.xp[id]
  if integer(xp,Config.maxCoins) then p.xp[id]=xp end
  local e=type(raw.equipped)=="table" and raw.equipped[id]
  if type(e)=="table" then
   local skin=items[e.skin]
   if skin and skin.kind=="skin" and skin.character==id and p.owned[e.skin] then p.equipped[id].skin=e.skin end
   if e.cosmetic=="" or items[e.cosmetic] and items[e.cosmetic].kind=="cosmetic" and p.owned[e.cosmetic] then p.equipped[id].cosmetic=e.cosmetic end
  end
 end
 if characters[raw.lastCharacter] then p.lastCharacter=raw.lastCharacter end
 if type(raw.receiptOrder)=="table" then
  for i=math.max(1,#raw.receiptOrder-Config.receiptLimit+1),#raw.receiptOrder do
   local id=raw.receiptOrder[i]
   if type(id)=="string" and #id<180 and not p.receipts[id] then p.receipts[id]=true;table.insert(p.receiptOrder,id) end
  end
 end
 return p
end
function Data.purchase(p,id)
 local item=type(id)=="string" and items[id]
 if not item then return false,"Artículo desconocido." end
 if p.owned[id] then return false,"Ya lo tienes." end
 if item.mastery then return false,"Se desbloquea mediante maestría." end
 if not integer(item.price,Config.maxCoins) or p.coins<item.price then return false,"No tienes suficientes monedas." end
 p.coins=p.coins-item.price;p.owned[id]=true
 return true,"Compra completada."
end
function Data.equip(p,character,id)
 if not characters[character] or not p.equipped[character] then return false,"Personaje desconocido." end
 if id=="none" then p.equipped[character].cosmetic="";return true,"Cosmético retirado." end
 local item=type(id)=="string" and items[id]
 if not item or not p.owned[id] then return false,"No posees ese artículo." end
 if item.kind=="skin" and item.character==character then p.equipped[character].skin=id
 elseif item.kind=="cosmetic" then p.equipped[character].cosmetic=id
 else return false,"Ese artículo pertenece a otro personaje." end
 return true,"Apariencia equipada."
end
function Data.reward(p,receipt,kind,character)
 local coins=Config.rewards[kind]
 if type(receipt)~="string" or #receipt>=180 or p.receipts[receipt] or not coins or not characters[character] then return false,0,{} end
 p.receipts[receipt]=true;table.insert(p.receiptOrder,receipt)
 while #p.receiptOrder>Config.receiptLimit do p.receipts[table.remove(p.receiptOrder,1)]=nil end
 local before=p.coins;p.coins=math.min(Config.maxCoins,p.coins+coins)
 p.xp[character]=math.min(Config.maxCoins,p.xp[character]+(Config.mastery[kind] or 0))
 local unlocked={}
 for tier,required in ipairs(Config.milestoneXP) do
  local id=character..":m"..tier
  if p.xp[character]>=required and not p.owned[id] then p.owned[id]=true;table.insert(unlocked,id) end
 end
 return true,p.coins-before,unlocked
end
function Data.select(p,id)
 if not characters[id] then return false end
 p.lastCharacter=id;return true
end
function Data.public(p,mode)
 return {coins=p.coins,owned=p.owned,equipped=p.equipped,xp=p.xp,lastCharacter=p.lastCharacter,mode=mode,currency=Config.currency}
end
return Data
