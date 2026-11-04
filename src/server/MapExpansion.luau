-- V4 districts extend the existing layouts. Four doors and unobstructed cross
-- aisles in each district provide alternative chase routes around cover.
local Expansion={}
local districts={
 island={"PUESTO DE RADIO","CASA DEL GUARDACOSTAS","TALLER DE BARCAS","DEPÓSITO DEL FARO"},
 pizza={"HORNO INDUSTRIAL","SALÓN DE CUMPLEAÑOS","CÁMARA FRIGORÍFICA","MUELLE DE REPARTO"},
 heights={"CENTRAL DE ASCENSORES","OFICINAS ABANDONADAS","CENTRO DE DATOS","ESTUDIO DE RADIO"},
 lab={"AISLAMIENTO","BANCO DE MUESTRAS","SALA DE TURBINAS","ARCHIVO CLÍNICO"},
 manor={"INVERNADERO","BIBLIOTECA PRIVADA","SALA DE MÚSICA","COCHERAS"},
 town={"LAVANDERÍA","TALLER DEL BARRIO","TERMINAL DE AUTOBÚS","ALMACÉN VECINAL"},
 factory={"MANTENIMIENTO","ALMACÉN DE BOBINAS","CONTROL INDUSTRIAL","NAVE DE REPUESTOS"},
 arcade={"SALA LAN","BÓVEDA DE PREMIOS","SERVIDORES","TALLER DE REPARACIÓN"},
 arena={"GIMNASIO","ENFERMERÍA","TIENDA DEL ESTADIO","SALA DE ENTRENAMIENTO"}}

function Expansion.extend(model,definition,helpers,palette)
 local p,sign,building=helpers.part,helpers.sign,helpers.building
 local wall=Color3.fromRGB(palette.wall[1],palette.wall[2],palette.wall[3])
 local accent=Color3.fromRGB(palette.accent[1],palette.accent[2],palette.accent[3])
 local dark=wall:Lerp(Color3.fromRGB(26,31,35),.55)
 local positions={Vector3.new(-138,0,-138),Vector3.new(138,0,-138),Vector3.new(-138,0,138),Vector3.new(138,0,138)}
 local points={}
 local function details(x,z,index)
  local theme=definition.theme
  -- Side partitions leave the center and every doorway free.
  for _,side in ipairs({-1,1}) do
   p("Tabique con paso lateral",Vector3.new(15,7,.65),x+side*20,3.5,z+5,wall)
   p("Moldura de distrito",Vector3.new(25,.2,.25),x+side*18,1,z+31,accent,Enum.Material.Metal,true)
   local cx=x+side*21
   if theme=="lab" or theme=="factory" then
    for _,dz in ipairs({-19,22}) do
     local tank=p(theme=="lab" and "Contenedor de aislamiento" or "Bobina de mantenimiento",Vector3.new(6,4,4),cx,3,z+dz,accent,Enum.Material.Metal)
     tank.Shape=Enum.PartType.Cylinder;tank.CFrame=tank.CFrame*CFrame.Angles(0,0,math.pi/2)
     p("Zócalo de máquina",Vector3.new(7,.6,6),cx,.3,z+dz,dark,Enum.Material.Metal)
     p("Panel de diagnóstico",Vector3.new(2,1,.12),cx,4,z+dz-3,accent,Enum.Material.Neon,true)
    end
   elseif theme=="pizza" then
    p("Horno de ladrillo",Vector3.new(9,6,7),cx,3,z-21,wall,Enum.Material.Brick)
    p("Boca del horno",Vector3.new(6,3,.15),cx,2.7,z-24.6,dark,Enum.Material.Metal,true)
    helpers.tableAt(cx,z+21)
    for n=1,3 do p("Bandeja de cocina",Vector3.new(2,.08,2),cx-3+n*1.5,3.08,z+21,accent,Enum.Material.Metal,true) end
   elseif theme=="arcade" or theme=="heights" then
    for _,dz in ipairs({-21,21}) do
     p("Bastidor electrónico",Vector3.new(5,8,3),cx,4,z+dz,dark,Enum.Material.Metal)
     for slot=1,4 do
      p("Equipo y rejilla",Vector3.new(4.4,1.25,.2),cx,slot*1.6,z+dz-1.6,wall,Enum.Material.Metal,true)
      p("Indicador de equipo",Vector3.new(.16,.16,.1),cx+1.6,slot*1.6,z+dz-1.75,accent,Enum.Material.Neon,true)
     end
    end
   elseif theme=="manor" then
    for _,dz in ipairs({-22,23}) do
     p("Librería antigua",Vector3.new(10,8,2),cx,4,z+dz,dark,Enum.Material.WoodPlanks)
     for shelf=1,3 do
      p("Balda de madera",Vector3.new(10,.16,2.5),cx,shelf*2,z+dz-.2,accent,Enum.Material.WoodPlanks,true)
      for book=1,5 do p("Libro olvidado",Vector3.new(.8,1.3,1.2),cx-4+book*1.4,shelf*2+.7,z+dz-.7,wall:Lerp(accent,book/7),Enum.Material.Fabric,true) end
     end
    end
   elseif theme=="arena" then
    for _,dz in ipairs({-21,22}) do
     p("Banco de entrenamiento",Vector3.new(11,2.2,3),cx,1.1,z+dz,dark,Enum.Material.Fabric)
     p("Bastidor de taquillas",Vector3.new(10,7,2),cx,3.5,z+dz+4,wall,Enum.Material.Metal)
     for door=1,3 do p("Puerta de taquilla",Vector3.new(2.9,6,.12),cx-6+door*3,3.5,z+dz+2.9,accent,Enum.Material.Metal,true) end
    end
   else
    helpers.tableAt(cx,z-21)
    helpers.crate(cx-3,z+21,"Suministros del distrito");helpers.crate(cx+4,z+25,"Cobertura de almacén")
    p("Tablón de anuncios",Vector3.new(8,5,.25),cx,7,z+31,accent,Enum.Material.WoodPlanks,true)
   end
  end
  local ceiling=p("Luminaria de distrito",Vector3.new(2,.2,2),x,11.5,z,accent,Enum.Material.Neon,true)
  local light=Instance.new("PointLight");light.Color=accent;light.Brightness=.7;light.Range=35;light.Shadows=false;light.Parent=ceiling
  sign("SECTOR "..index.." · DOBLE RUTA",x,9,z+31,20)
  if definition.theme=="heights" then
   for _,side in ipairs({-1,1}) do
    local top=helpers.stairs(x+side*35,z-25,13.6)
    p("Paso a cubierta exterior",Vector3.new(14,.5,8),x+side*30,13.6,top,wall,Enum.Material.Metal)
   end
  end
 end
 for index,position in ipairs(positions) do
  local x,z=position.X,position.Z
  building(x,z,districts[definition.theme][index],true)
  details(x,z,index)
  table.insert(points,{name=districts[definition.theme][index],position=position})
 end
 -- Ring roads connect the old center, four new districts and outer escape routes.
 for _,side in ipairs({-1,1}) do
  p("Ruta perimetral horizontal",Vector3.new(374,.06,10),0,.045,side*100,dark,Enum.Material.Concrete,true)
  p("Ruta perimetral vertical",Vector3.new(10,.06,374),side*100,.045,0,dark,Enum.Material.Concrete,true)
  p("Paseo exterior horizontal",Vector3.new(374,.06,10),0,.045,side*180,dark,Enum.Material.Concrete,true)
  p("Paseo exterior vertical",Vector3.new(10,.06,374),side*180,.045,0,dark,Enum.Material.Concrete,true)
  for _,offset in ipairs({-60,60}) do
   helpers.crate(side*158,offset,"Cobertura de ruta exterior")
   helpers.crate(offset,side*158,"Cobertura de ruta exterior")
   helpers.lamp(side*100,offset)
  end
 end
 -- Vegetation remains outside objective approaches, with no decorative collision.
 if definition.theme=="island" or definition.theme=="manor" or definition.theme=="town" then
  for _,x in ipairs({-159,-126,126,159}) do for _,z in ipairs({-55,55}) do
   local trunk=p("Tronco exterior",Vector3.new(12,1.1,1.1),x,6,z,wall,Enum.Material.Wood)
   trunk.Shape=Enum.PartType.Cylinder;trunk.CFrame=trunk.CFrame*CFrame.Angles(0,0,math.pi/2)
   for layer=1,3 do
    local crown=p("Vegetación exterior",Vector3.new(10-layer,6,10-layer),x,10+layer*2,z,Color3.fromRGB(36,65+layer*4,45),Enum.Material.Grass,true)
    crown.Shape=Enum.PartType.Ball
   end
  end end
 end
 return {points=points,generatorPositions={positions[1],Vector3.new(62,0,-60),Vector3.new(-62,0,60),positions[4]},
  puzzlePositions={Vector3.new(-18,0,-78),positions[2],Vector3.new(18,0,78),positions[3]}}
end
return Expansion
