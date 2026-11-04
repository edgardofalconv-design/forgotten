-- Nine authored procedural layouts. Only the active map is instantiated.
local Maps={}
local palettes={
 island={ground={139,126,88},wall={105,80,55},accent={116,176,183},material="Sand"},
 pizza={ground={89,78,69},wall={123,58,47},accent={211,161,72},material="Concrete"},
 heights={ground={63,69,76},wall={100,111,122},accent={131,180,201},material="Concrete"},
 lab={ground={73,86,89},wall={115,135,133},accent={95,196,160},material="Metal"},
 manor={ground={73,66,57},wall={68,49,63},accent={176,126,75},material="WoodPlanks"},
 town={ground={57,90,62},wall={122,75,64},accent={212,174,78},material="Grass"},
 factory={ground={65,68,62},wall={88,86,69},accent={174,153,65},material="Concrete"},
 arcade={ground={42,40,56},wall={55,42,72},accent={152,95,192},material="SmoothPlastic"},
 arena={ground={98,77,59},wall={87,93,108},accent={201,111,54},material="WoodPlanks"}}
local function color(v)return Color3.fromRGB(v[1],v[2],v[3])end
function Maps.build(parent,definition,World)
 local model=Instance.new("Model");model.Name="Mapa_"..definition.id;model.Parent=parent
 local center=Vector3.new(0,0,600)
 local palette=palettes[definition.theme]
 local ground,wall,accent=color(palette.ground),color(palette.wall),color(palette.accent)
 local generators={Vector3.new(-62,0,-60),Vector3.new(62,0,-60),Vector3.new(-62,0,60),Vector3.new(62,0,60)}
 local puzzles={Vector3.new(-18,0,-78),Vector3.new(94,0,0),Vector3.new(18,0,78),Vector3.new(-94,0,0)}
 local function p(name,size,x,y,z,tint,material,decor)
  local part=World.part(model,name,size,center+Vector3.new(x,y,z),tint or wall,material or Enum.Material.Concrete)
  part.CastShadow=not decor
  if decor then part.CanCollide=false;part.CanTouch=false;part.CanQuery=false end
  return part
 end
 local function sign(text,x,y,z,width)
  local panel=p("Cartel "..text,Vector3.new(width or 12,3,.25),x,y,z,wall,Enum.Material.Metal,true)
  World.label(panel,text);return panel
 end
 local function clear(x,z)
  for _,positions in ipairs({generators,puzzles}) do
   for _,v in ipairs(positions) do if (Vector3.new(x,0,z)-v).Magnitude<9 then return false end end
  end
  return true
 end
 local function crate(x,z,kind)
  if not clear(x,z) then return end
  local part=p(kind or "Caja de cobertura",Vector3.new(5,4,5),x,2,z,wall:Lerp(accent,.15),Enum.Material.WoodPlanks)
  p("Herraje",Vector3.new(5.1,.15,5.1),x,3.5,z,accent,Enum.Material.Metal,true)
  return part
 end
 local function tableAt(x,z)
  if not clear(x,z) then return end
  p("Mesa",Vector3.new(7,.4,4),x,2.8,z,accent,Enum.Material.WoodPlanks)
  for _,dx in ipairs({-2.8,2.8}) do p("Pata",Vector3.new(.4,2.7,.4),x+dx,1.35,z,wall,Enum.Material.Metal) end
  for _,dz in ipairs({-3.5,3.5}) do p("Asiento",Vector3.new(4,1.8,1.4),x,.9,z+dz,wall,Enum.Material.WoodPlanks) end
 end
 local function lamp(x,z,tint)
  p("Poste",Vector3.new(.5,10,.5),x,5,z,wall,Enum.Material.Metal)
  local bulb=p("Luz ambiental",Vector3.new(1.4,.4,1.4),x,10.1,z,tint or accent,Enum.Material.Neon,true)
  local light=Instance.new("PointLight");light.Color=tint or accent;light.Brightness=.65;light.Range=24;light.Shadows=false;light.Parent=bulb
 end
 local function building(x,z,title,roof)
  p("Suelo "..title,Vector3.new(64,.3,64),x,.15,z,ground:Lerp(accent,.1),Enum.Material[palette.material])
  -- Four open doors, creating loops instead of dead ends.
  for _,side in ipairs({-1,1}) do
   for _,offset in ipairs({-19,19}) do
    p("Pared "..title,Vector3.new(26,12,1),x+offset,6,z+side*32,wall)
    p("Pared "..title,Vector3.new(1,12,26),x+side*32,6,z+offset,wall)
   end
   p("Dintel",Vector3.new(12,3,1),x,10.5,z+side*32,wall)
   p("Dintel",Vector3.new(1,3,12),x+side*32,10.5,z,wall)
  end
  if roof then p("Techo "..title,Vector3.new(65,.7,65),x,12.6,z,wall:Lerp(Color3.fromRGB(15,19,24),.4)) end
  sign(title,x,10,z-32.6,16)
  for _,dx in ipairs({-20,20}) do
   p("Ventanal",Vector3.new(9,3,.12),x+dx,7,z-32.6,accent,Enum.Material.Glass,true).Transparency=.35
  end
 end
 local function stairs(x,z,height)
  local count=math.ceil(height/.55)
  for i=1,count do p("Escalón",Vector3.new(7,i*height/count,1.6),x,i*height/count/2,z+(i-1)*1.6,accent,Enum.Material.Metal) end
  return z+(count-1)*1.6
 end
 p("Suelo estructural",Vector3.new(262,2,262),0,-1,0,ground,Enum.Material[palette.material])
 for _,x in ipairs({-121,121}) do p("Límite lateral",Vector3.new(2,30,244),x,15,0,wall) end
 p("Límite norte",Vector3.new(244,30,2),0,15,-121,wall)
 for _,x in ipairs({-67,67}) do p("Límite sur",Vector3.new(108,30,2),x,15,121,wall) end
 p("Camino transversal",Vector3.new(238,.07,13),0,.04,0,ground:Lerp(Color3.fromRGB(167,159,141),.3),Enum.Material.Concrete,true)
 p("Camino central",Vector3.new(13,.07,238),0,.05,0,ground:Lerp(Color3.fromRGB(167,159,141),.3),Enum.Material.Concrete,true)
 local titles={island={"REFUGIO DEL FARO","ALMACÉN DEL MUELLE","ESTACIÓN COSTERA","RADIO DE EMERGENCIA"},pizza={"COMEDOR","COCINA","ESCENARIO","ALMACÉN"},heights={"TORRE NORTE","OFICINAS","ARCHIVO","TORRE SUR"},lab={"CULTIVOS","CUARENTENA","REACTOR","OBSERVACIÓN"},manor={"BIBLIOTECA","COMEDOR","SALÓN","GALERÍA"},town={"CASA ROJA","CASA AZUL","TALLER","CENTRO VECINAL"},factory={"MONTAJE","FUNDICIÓN","REPUESTOS","EMBALAJE"},arcade={"RETRO ZONE","PIXEL HALL","GLITCH ROOM","BACKSTAGE"},arena={"VESTUARIO A","VESTUARIO B","TÚNEL OESTE","TÚNEL ESTE"}}
 for i,position in ipairs(generators) do
  local x,z=position.X,position.Z
  building(x,z,titles[definition.theme][i],definition.theme~="heights" and definition.theme~="island" and definition.theme~="arena")
  if definition.theme=="pizza" or definition.theme=="manor" then
   for _,dx in ipairs({-18,18}) do for _,dz in ipairs({-18,18}) do tableAt(x+dx,z+dz) end end
   if definition.theme=="pizza" then
    p("Mostrador",Vector3.new(16,4,4),x-16,2,z+25,accent)
    for n=1,4 do p("Caja de pizza",Vector3.new(3,.35,3),x-24+n*4,4.3,z+25,Color3.fromRGB(187,154,109),Enum.Material.Wood,true) end
   else
    for n=1,5 do
     p("Estantería",Vector3.new(7,8,2),x-25+(n-1)*12,4,z+27,wall,Enum.Material.WoodPlanks)
     for shelf=1,3 do p("Libros",Vector3.new(6,1.5,1.2),x-25+(n-1)*12,shelf*2,z+25.5,accent:Lerp(ground,n/8),Enum.Material.Wood,true) end
    end
   end
  elseif definition.theme=="lab" then
   for _,dx in ipairs({-20,20}) do for _,dz in ipairs({-20,20}) do
    local tank=p("Cámara de muestras",Vector3.new(5,8,5),x+dx,4,z+dz,accent,Enum.Material.Glass)
    tank.Shape=Enum.PartType.Cylinder;tank.Transparency=.45
    p("Muestra suspendida",Vector3.new(1.5,4,1.5),x+dx,4,z+dz,Color3.fromRGB(93,138,96),Enum.Material.Neon,true)
   end end
   tableAt(x-20,z);tableAt(x+20,z)
  elseif definition.theme=="factory" then
   for _,dx in ipairs({-19,19}) do
    p("Cinta transportadora",Vector3.new(8,2,32),x+dx,1,z,Color3.fromRGB(35,40,38),Enum.Material.Metal)
    for n=-3,3 do p("Rodillo",Vector3.new(8.2,.35,.6),x+dx,2.2,z+n*4,accent,Enum.Material.Metal,true) end
    p("Prensa",Vector3.new(10,6,7),x+dx,3,z+21,wall,Enum.Material.Metal)
   end
  elseif definition.theme=="arcade" then
   for _,dx in ipairs({-22,22}) do for dz=-22,22,11 do
    p("Máquina arcade",Vector3.new(4,6,4),x+dx,3,z+dz,wall,Enum.Material.Metal)
    p("Pantalla corrupta",Vector3.new(3,2,.16),x+dx,4,z+dz-2.12,accent:Lerp(Color3.fromRGB(80,211,176),i/5),Enum.Material.Neon,true)
   end end
   for dx=-24,24,8 do for dz=-24,24,8 do p("Baldosa",Vector3.new(7.9,.05,7.9),x+dx,.32,z+dz,(dx+dz)%16==0 and wall or ground,Enum.Material.SmoothPlastic,true) end end
  elseif definition.theme=="heights" then
   p("Azotea accesible",Vector3.new(66,1,66),x,13,z,wall)
   for _,dx in ipairs({-20,20}) do p("Ventilación",Vector3.new(9,3,7),x+dx,15,z+16,accent,Enum.Material.Metal) end
   for _,dx in ipairs({-20,20}) do crate(x+dx,z+15);tableAt(x+dx,z-15) end
  elseif definition.theme=="arena" then
   for n=1,4 do p("Grada",Vector3.new(25,n*.7,3),x,n*.35,z-25+n*3,accent,Enum.Material.WoodPlanks) end
   for _,dx in ipairs({-20,20}) do crate(x+dx,z+18,"Taquillas") end
  else
   for _,dx in ipairs({-21,21}) do for _,dz in ipairs({-20,20}) do crate(x+dx,z+dz) end end
   tableAt(x-20,z)
  end
 end
 if definition.theme=="heights" then
  local top=stairs(-105,-106,13.6)
  p("Acceso a azotea",Vector3.new(45,.5,8),-83,13.6,top,accent,Enum.Material.Metal)
  p("Puente entre torres",Vector3.new(66,.5,8),0,13.6,-60,accent,Enum.Material.Metal)
 elseif definition.theme=="manor" then
  local top=stairs(-25,10,8)
  p("Balcón del vestíbulo",Vector3.new(49,.5,16),0,8,top,wall,Enum.Material.WoodPlanks)
  sign("EL RETRATO OLVIDADO",0,12,top+7,18)
 elseif definition.theme=="island" then
  p("Litoral",Vector3.new(260,.1,15),0,.08,-112,Color3.fromRGB(41,91,110),Enum.Material.Glass,true).Transparency=.35
  for n=1,16 do p("Tablón del muelle",Vector3.new(12,.2,2.8),20,.3,-122+n*2.8,wall,Enum.Material.WoodPlanks) end
  local top=stairs(102,-106,10)
  p("Torre de observación",Vector3.new(16,.6,16),102,10,top,wall,Enum.Material.WoodPlanks)
  for _,x in ipairs({96,108}) do p("Soporte de torre",Vector3.new(1,10,1),x,5,top+5,wall,Enum.Material.Wood) end
 elseif definition.theme=="arena" then
  p("Cancha",Vector3.new(22,.1,96),0,.1,0,Color3.fromRGB(165,117,72),Enum.Material.WoodPlanks,true)
  for _,z in ipairs({-47,47}) do
   p("Poste de aro",Vector3.new(.6,9,.6),0,4.5,z,accent,Enum.Material.Metal)
   p("Tablero",Vector3.new(7,4,.4),0,8,z,Color3.fromRGB(202,211,206))
   p("Aro",Vector3.new(3,.2,2),0,6.5,z-1.2,accent,Enum.Material.Neon,true)
  end
 elseif definition.theme=="town" then
  for _,x in ipairs({-13,13}) do for z=-65,65,26 do
   p("Árbol del parque",Vector3.new(1.5,8,1.5),x,4,z,wall,Enum.Material.Wood)
   p("Copa redondeada",Vector3.new(7,9,7),x,11,z,Color3.fromRGB(45,88,59),Enum.Material.Grass,true).Shape=Enum.PartType.Ball
  end end
 end
 for _,x in ipairs({-108,108}) do for _,z in ipairs({-90,0,90}) do lamp(x,z) end end
 sign(definition.name:upper(),0,12,-116,34)
 local gate=p("Puerta de salida",Vector3.new(26,12,1.2),0,6,121,Color3.fromRGB(112,44,39))
 local gateText=World.label(gate,"SALIDA CERRADA")
 local exit=p("Umbral fisico de escape",Vector3.new(24,10,6),0,5,127,Color3.fromRGB(62,189,121),Enum.Material.Neon,true)
 exit.Transparency=.8;exit.CanTouch=true
 local function setGate(open,mode)
  gate.CanCollide=not open;gate.Transparency=open and .88 or 0
  gateText.Text=open and "SALIDA ABIERTA · ATRAVIÉSALA" or mode=="LMS" and "LMS · ABRE A 0:00" or "SALIDA\n2 GENERADORES + 3 CÁPSULAS DEPOSITADAS\nRELOJ ≤ 1:00"
 end
 setGate(false,"Normal")
 return {arena=model,center=center,gate=gate,exit=exit,setGate=setGate,mapId=definition.id,mapName=definition.name,
  generatorPositions=generators,puzzlePositions=puzzles,depotPosition=Vector3.new(0,0,102),
  survivorSpawn=Vector3.new(-90,0,-108),killerSpawn=Vector3.new(100,0,100),
  itemSpawns={Vector3.new(-104,0,-48),Vector3.new(104,0,48),Vector3.new(20,0,-100),Vector3.new(-20,0,100),Vector3.new(-12,0,24),Vector3.new(24,0,-24)}}
end
return Maps
