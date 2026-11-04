local items={}
local names={pelotocino="Pelotocino",yellowguy="Yellow Guy",junkbot="Junkbot",deathspeaker="Korblox Deathspeaker",guest666="Guest 666",tubers93="Tubers93"}
local order={"pelotocino","yellowguy","junkbot","deathspeaker","guest666","tubers93"}
for _,id in ipairs(order) do
 table.insert(items,{id="character:"..id,name=names[id],kind="character",character=id,price=0,included=true})
 table.insert(items,{id=id..":base",name="Principal · "..names[id],kind="skin",character=id,tier=0,price=0,included=true})
 for tier=1,4 do table.insert(items,{id=id..":m"..tier,name="Milestone "..tier.." · "..names[id],kind="skin",character=id,tier=tier,mastery=true,provisional=true}) end
end
for _,item in ipairs({
 {id="cosmetic:scarf",name="Bufanda del refugio",kind="cosmetic",price=50,style="scarf",featured=true},
 {id="cosmetic:lantern",name="Linterna del explorador",kind="cosmetic",price=80,style="lantern",featured=true},
 {id="cosmetic:badge",name="Insignia del campamento",kind="cosmetic",price=35,style="badge"},
 {id="cosmetic:radio",name="Radio de recuerdo",kind="cosmetic",price=65,style="radio"}
}) do table.insert(items,item) end
return items
