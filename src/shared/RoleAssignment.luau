-- Inputs are plain records; server supplies the real connected players.
local Assignment = {}
function Assignment.assign(candidates,roster)
 if #candidates<2 then return nil end
 local byId={}
 for _,entry in ipairs(roster) do byId[entry.id]=entry end
 local pool={}
 for _,candidate in ipairs(candidates) do
  local choice=byId[candidate.choice]
  if choice and choice.role=="Asesino" then table.insert(pool,candidate) end
 end
 if #pool==0 then for _,candidate in ipairs(candidates) do table.insert(pool,candidate) end end
 table.sort(pool,function(a,b)
  if (a.lastKiller or 0)==(b.lastKiller or 0) then return a.key<b.key end
  return (a.lastKiller or 0)<(b.lastKiller or 0)
 end)
 local killer=pool[1]
 local result={}
 for _,candidate in ipairs(candidates) do
  local chosen=byId[candidate.choice]
  local id
  if candidate==killer then id=chosen and chosen.role=="Asesino" and chosen.id or "guest666"
  else id=chosen and chosen.role=="Superviviente" and chosen.id or "pelotocino" end
  table.insert(result,{key=candidate.key,id=id})
 end
 return result,killer.key
end
return Assignment
