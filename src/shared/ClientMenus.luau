local T=require(script.Parent.ClientTheme)
local Preview=require(script.Parent.ClientPreview)
local Shop=require(script.Parent.ShopCatalog)
local Economy=require(script.Parent.EconomyConfig)
local Maps=require(script.Parent.MapCatalog)
local Abilities=require(script.Parent.AbilityConfig)
local Roster=require(script.Parent.Roster)
return function(gui,remote)
 local self={selected="pelotocino",profile=nil,page="play",section="featured",state={phase="Lobby"},currentItem="cosmetic:scarf",quality=true}
 local root=T.frame(gui,"MenuPrincipal",UDim2.fromScale(.03,.2),UDim2.fromScale(.94,.54),T.bg);root.ZIndex=10
 local nav=T.frame(root,"Navegacion",UDim2.fromScale(.015,.025),UDim2.fromScale(.18,.95),T.panel)
 T.label(nav,"Marca","FORGOTTEN",UDim2.fromScale(.03,.02),UDim2.fromScale(.94,.1),21,T.gold)
 T.label(nav,"Edicion","V2 · EL ÚLTIMO REFUGIO",UDim2.fromScale(.03,.13),UDim2.fromScale(.94,.09),10,T.muted)
 local content=T.frame(root,"Contenido",UDim2.fromScale(.21,.025),UDim2.fromScale(.775,.95),T.panel)
 local redraw
 local function equipped(id)
  return self.profile and self.profile.equipped[id] or {skin=id..":base",cosmetic=""}
 end
 local function title(words)T.label(content,"Titulo",words,UDim2.fromScale(.03,.02),UDim2.fromScale(.9,.1),23,T.gold)end
 local function previewCard(id,equipment,pos,size,pose)
  local card=T.frame(content,"Vista",pos,size,T.bg);Preview.show(card,id,equipment,pose);return card
 end
 local function characterList()
  title("PERSONAJES · ELIGE TU HISTORIA")
  local list=T.scroll(content,"Personajes",UDim2.fromScale(.03,.15),UDim2.fromScale(.43,.81))
  for _,entry in ipairs(Roster) do
   local row=T.frame(list,entry.id,UDim2.new(),UDim2.new(1,-6,0,66),entry.id==self.selected and T.edge or T.bg)
   Preview.icon(row,entry.id,UDim2.fromScale(.02,.08),UDim2.fromScale(.17,.84))
   T.button(row,"Elegir",entry.name.."\n"..entry.role,UDim2.fromScale(.22,.08),UDim2.fromScale(.75,.84),function()remote:FireServer("select",entry.id)end,T.panel)
  end
  previewCard(self.selected,equipped(self.selected),UDim2.fromScale(.49,.13),UDim2.fromScale(.48,.53))
  local names={};for _,a in ipairs(Abilities[self.selected]) do table.insert(names,a.name) end
  T.label(content,"Habilidades",table.concat(names," · ").."\nLa apariencia se equipa al comenzar la ronda.",UDim2.fromScale(.49,.68),UDim2.fromScale(.48,.27),14)
 end
 local function shopView(inventory)
  title(inventory and "TU INVENTARIO PERMANENTE" or "TIENDA DEL REFUGIO")
  local sectionNames=inventory and {{"character","Personajes"},{"skin","Skins"},{"cosmetic","Cosméticos"}} or {{"featured","Destacados"},{"character","Personajes"},{"skin","Skins"},{"cosmetic","Cosméticos"}}
  if inventory and self.section=="featured" then self.section="skin" end
  for i,pair in ipairs(sectionNames) do
   T.button(content,pair[1],pair[2],UDim2.fromScale(.03+(i-1)*.235,.14),UDim2.fromScale(.22,.09),function()self.section=pair[1];redraw()end,self.section==pair[1] and T.edge or T.bg)
  end
  local list=T.scroll(content,"Articulos",UDim2.fromScale(.03,.27),UDim2.fromScale(.44,.66))
  local shown={};local item
  for _,candidate in ipairs(Shop) do
   local category=self.section=="featured" and candidate.featured or candidate.kind==self.section
   local own=self.profile and self.profile.owned[candidate.id]
   if category and (candidate.kind~="skin" or candidate.character==self.selected) and (not inventory or own) then
    table.insert(shown,candidate);if candidate.id==self.currentItem then item=candidate end
    local row=T.frame(list,candidate.id,UDim2.new(),UDim2.new(1,-6,0,82),candidate.id==self.currentItem and T.edge or T.bg)
    Preview.icon(row,candidate.character or self.selected,UDim2.fromScale(.02,.1),UDim2.fromScale(.16,.8))
    local price=candidate.mastery and ("Maestría "..Economy.milestoneXP[candidate.tier]) or candidate.included and "Incluido" or (candidate.price.." Coins")
    T.label(row,"Nombre",candidate.name.."\n"..price.." · "..(own and "En inventario" or "Sin desbloquear"),UDim2.fromScale(.2,.03),UDim2.fromScale(.58,.92),13)
    T.button(row,"Ver","VER",UDim2.fromScale(.8,.14),UDim2.fromScale(.18,.7),function()self.currentItem=candidate.id;redraw()end)
   end
  end
  item=item or shown[1]
  if not item then T.label(content,"Vacio","Aún no hay artículos en esta sección.",UDim2.fromScale(.5,.3),UDim2.fromScale(.45,.3),16);return end
  self.currentItem=item.id
  local id=item.character or self.selected;local worn=equipped(id)
  local equipment={skin=item.kind=="skin" and item.id or worn.skin,cosmetic=item.kind=="cosmetic" and item.id or worn.cosmetic}
  previewCard(id,equipment,UDim2.fromScale(.5,.26),UDim2.fromScale(.47,.43))
  local owned=self.profile and self.profile.owned[item.id]
  local requirement=item.mastery and ("Maestría "..(self.profile and self.profile.xp[id] or 0).." / "..Economy.milestoneXP[item.tier]) or "Cosmético · sin ventajas de combate"
  T.label(content,"Requisito",item.name.."\n"..requirement,UDim2.fromScale(.5,.69),UDim2.fromScale(.47,.12),13)
  local action=owned and (item.kind=="character" and "ELEGIR" or "EQUIPAR") or item.mastery and "BLOQUEADO" or "COMPRAR · "..tostring(item.price)
  local buy=T.button(content,"Accion",action,UDim2.fromScale(.5,.83),UDim2.fromScale(.3,.11),function()
   if owned then
    if item.kind=="character" then remote:FireServer("select",item.character)
    else remote:FireServer("equip",id,item.id) end
   elseif not item.mastery then remote:FireServer("buy",item.id) end
  end,owned and T.green or T.edge)
  buy.Active=self.profile~=nil and self.profile.mode~="locked" and (owned or not item.mastery)
  if not self.profile then buy.Text="CARGANDO…" elseif self.profile.mode=="locked" then buy.Text="SOLO LECTURA" end
  T.button(content,"Quitar","QUITAR\nCOSMÉTICO",UDim2.fromScale(.82,.83),UDim2.fromScale(.15,.11),function()remote:FireServer("equip",id,"none")end,T.bg)
 end
 redraw=function()
  T.clear(content)
  if self.page=="characters" then characterList()
  elseif self.page=="shop" or self.page=="inventory" then shopView(self.page=="inventory")
  elseif self.page=="maps" then
   title("ESCENARIOS · VOTA EL PRÓXIMO MAPA")
   local list=T.scroll(content,"Mapas",UDim2.fromScale(.03,.16),UDim2.fromScale(.94,.8))
   for i,map in ipairs(Maps) do
    local row=T.frame(list,map.id,UDim2.new(),UDim2.new(1,-6,0,72),T.bg)
    T.label(row,"Nombre",string.format("%02d",i).."  "..map.name.."\n"..map.description,UDim2.fromScale(.03,.08),UDim2.fromScale(.74,.84),15)
    T.button(row,"Votar","VOTAR",UDim2.fromScale(.8,.16),UDim2.fromScale(.17,.68),function()remote:FireServer("map",map.id)end)
   end
  elseif self.page=="settings" then
   title("ATMÓSFERA Y ACCESIBILIDAD")
   T.button(content,"Efectos",self.quality and "EFECTOS: COMPLETOS" or "EFECTOS: REDUCIDOS",UDim2.fromScale(.08,.25),UDim2.fromScale(.84,.2),function()self.quality=not self.quality;redraw()end)
   T.label(content,"Nota","La opción reducida limita destellos y partículas. Los retratos y canciones definitivos se incorporarán cuando estén disponibles.",UDim2.fromScale(.08,.55),UDim2.fromScale(.84,.3),16,T.muted)
  else
   title("EL CAMPAMENTO ES TU REFUGIO")
   previewCard(self.selected,equipped(self.selected),UDim2.fromScale(.54,.15),UDim2.fromScale(.43,.77))
   T.label(content,"Bienvenida","Explora la cabaña, visita el club house y elige tu personaje.\n\n4 minutos. Repara generadores, resuelve puzles y deposita cápsulas. La salida debe cruzarse físicamente.",UDim2.fromScale(.04,.17),UDim2.fromScale(.46,.46),18)
   T.button(content,"Personajes","ELEGIR PERSONAJE",UDim2.fromScale(.05,.66),UDim2.fromScale(.43,.12),function()self.page="characters";redraw()end,T.green)
   local play=T.button(content,"Practica",self.state.canPractice and "PROBAR SOLO" or "ESPERANDO A LOS JUGADORES",UDim2.fromScale(.05,.81),UDim2.fromScale(.43,.12),function()if self.state.canPractice then remote:FireServer("practice")end end)
   play.Active=self.state.canPractice==true
  end
 end
 for i,page in ipairs({{"play","JUGAR"},{"characters","PERSONAJES"},{"maps","MAPAS"},{"shop","TIENDA"},{"inventory","INVENTARIO"},{"settings","AJUSTES"}}) do
  T.button(nav,page[1],page[2],UDim2.fromScale(.06,.27+(i-1)*.105),UDim2.fromScale(.88,.09),function()self.page=page[1];redraw()end,T.bg)
 end
 T.button(root,"Ocultar","×",UDim2.fromScale(.955,.015),UDim2.fromScale(.035,.07),function()root.Visible=false end)
 function self.open(page) if self.state.phase~="Lobby" then return end;self.page=page or self.page;root.Visible=true;redraw() end
 function self.setProfile(data)self.profile=data;if root.Visible then redraw() end end
 function self.setSelected(id)self.selected=id;if root.Visible then redraw() end end
 function self.setState(state)
  local changed=self.state.phase~=state.phase or self.state.canPractice~=state.canPractice
  self.state=state
  if state.phase~="Lobby" then root.Visible=false elseif changed then root.Visible=true;redraw() end
 end
 function self.effectsEnabled()return self.quality end
 function self.visible()return root.Visible end
 redraw();return self
end
