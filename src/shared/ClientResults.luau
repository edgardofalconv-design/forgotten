local T=require(script.Parent.ClientTheme)
local Preview=require(script.Parent.ClientPreview)
return function(gui)
 local frame=T.frame(gui,"Resultados",UDim2.fromScale(.08,.16),UDim2.fromScale(.84,.62),T.bg);frame.Visible=false;frame.ZIndex=30
 local function show(data,scoreboard)
  T.clear(frame);frame.Visible=true
  T.button(frame,"Cerrar","×",UDim2.fromScale(.92,.02),UDim2.fromScale(.06,.09),function()frame.Visible=false end)
  local me=game:GetService("Players").LocalPlayer.UserId
  local heading=scoreboard and "MARCADOR" or data.practice and "PRÁCTICA FINALIZADA" or "RESULTADOS"
  local featured
  for _,row in ipairs(data.rows or {}) do
   if row.userId==me and not scoreboard and not data.practice then
    heading=row.victory and "VICTORIA DEL ASESINO" or row.status=="Escapó" and "ESCAPASTE" or row.role=="Superviviente" and "NO LOGRASTE ESCAPAR" or "FIN DE RONDA"
   end
   if row.userId==data.mvp then featured=row end
  end
  T.label(frame,"Titulo",heading,UDim2.fromScale(.03,.03),UDim2.fromScale(.86,.09),24,T.gold)
  T.label(frame,"Mapa",data.map or "",UDim2.fromScale(.03,.13),UDim2.fromScale(.9,.07),15,T.muted)
  local list=T.scroll(frame,"Jugadores",UDim2.fromScale(.03,.24),UDim2.fromScale(.54,.64))
  if scoreboard then list.Size=UDim2.fromScale(.94,.64) end
  for i,row in ipairs(data.rows or {}) do
   local line=T.frame(list,tostring(row.userId),UDim2.new(),UDim2.new(1,-6,0,64),row.userId==data.mvp and T.edge or T.panel)
   Preview.icon(line,row.character,UDim2.fromScale(.02,.07),UDim2.fromScale(.13,.86))
   T.label(line,"Jugador",i..". "..row.name.."\n"..row.status,UDim2.fromScale(.18,.04),UDim2.fromScale(.57,.92),14)
   T.label(line,"Puntos",tostring(row.score or 0),UDim2.fromScale(.77,.1),UDim2.fromScale(.2,.8),20,T.gold)
  end
  featured=featured or (data.rows or {})[1]
  if featured and not scoreboard then
   local preview=T.frame(frame,"MVP",UDim2.fromScale(.6,.24),UDim2.fromScale(.37,.54),T.panel)
   Preview.show(preview,featured.character,featured.equipment,featured.victory and "victory" or not scoreboard and "mvp" or nil)
   T.label(frame,"Destacado",(scoreboard and "" or "MVP · ")..featured.name,UDim2.fromScale(.6,.81),UDim2.fromScale(.37,.09),17,T.gold)
  end
  T.label(frame,"Mensaje",data.message or "",UDim2.fromScale(.03,.91),UDim2.fromScale(.94,.07),13,T.muted)
 end
 return {show=show,hide=function()frame.Visible=false end,visible=function()return frame.Visible end}
end
