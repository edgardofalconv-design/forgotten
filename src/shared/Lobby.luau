-- Cabaña original de Forgotten inspirada en las referencias del autor.
-- Geometría detallada y materiales nativos; mapas PBR originales opcionales en assets/textures.
return function(world, roster, remote, variants, createNPCs)
 variants=variants or {}
 local lobby=Instance.new("Model")
 lobby.Name="CabanaDelUltimoRefugio";lobby.Parent=world
 local C={wood=Color3.fromRGB(86,61,44),trim=Color3.fromRGB(44,33,28),floor=Color3.fromRGB(121,88,59),stone=Color3.fromRGB(102,100,91),cream=Color3.fromRGB(194,174,140),green=Color3.fromRGB(48,68,59),gold=Color3.fromRGB(168,124,59)}
 local function part(name,size,pos,color,material,rotation)
  local p=Instance.new("Part")
  p.Name=name;p.Size=size;p.CFrame=CFrame.new(pos)*(rotation or CFrame.new())
  p.Color=color;p.Material=material or Enum.Material.Wood
  p.Anchored=true;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
  p.Parent=lobby
  if p.Material==Enum.Material.Wood then p.Material=Enum.Material.WoodPlanks end
  if p.Material==Enum.Material.Metal then p.Reflectance=.12 end
  if variants[p.Material] then p.MaterialVariant=variants[p.Material] end
  return p
 end
 local function decor(p) p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;return p end
 local function text(p,words,face)
  local gui=Instance.new("SurfaceGui");gui.Face=face or Enum.NormalId.Front;gui.CanvasSize=Vector2.new(600,300);gui.Parent=p
  local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1
  t.Text=words;t.TextColor3=C.cream;t.Font=Enum.Font.Garamond;t.TextScaled=true;t.TextWrapped=true;t.Parent=gui
 end
 local function lamp(pos,pendant)
  if pendant then decor(part("Cadena de farol",Vector3.new(.15,5,.15),pos+Vector3.new(0,3,0),C.trim,Enum.Material.Metal)) end
  local glow=decor(part("Luz ambar",Vector3.new(1.1,1.4,1.1),pos,Color3.fromRGB(255,204,129),Enum.Material.Neon))
  local l=Instance.new("PointLight");l.Color=Color3.fromRGB(255,204,149);l.Brightness=1.2;l.Range=23;l.Shadows=true;l.Parent=glow
  for _,dy in {-0.85,.85} do decor(part("Marco de farol",Vector3.new(1.5,.25,1.5),pos+Vector3.new(0,dy,0),C.trim,Enum.Material.Metal)) end
 end
 local function rail(a,b)
  local length=(b-a).Magnitude
  local center=(a+b)/2
  local orientation=CFrame.lookAt(center,b)
  local top=part("Pasamanos",Vector3.new(.45,.45,length),center+Vector3.new(0,3.5,0),C.trim)
  top.CFrame=CFrame.new(top.Position)*orientation.Rotation
  local n=math.max(1,math.floor(length/2.5))
  for i=0,n do part("Barrote",Vector3.new(.3,3.5,.3),a:Lerp(b,i/n)+Vector3.new(0,1.7,0),C.cream) end
 end
 -- Sala de doble altura y entramado de madera.
 part("Base",Vector3.new(180,2,180),Vector3.new(0,-2,0),Color3.fromRGB(29,43,34),Enum.Material.Grass)
 part("Suelo estructural",Vector3.new(84,1,72),Vector3.new(0,0,0),C.floor)
 for x=-40,40,4 do
  for j=0,5 do
   local z=-30+j*12
   local plank=part("Tablon de roble",Vector3.new(3.94,.12,11.92),Vector3.new(x,.56,z),C.floor:Lerp(C.trim,((x+40)/4+j*3)%7/40),Enum.Material.WoodPlanks)
   for _,dz in {-5.4,5.4} do
    for _,dx in {-1.4,1.4} do decor(part("Clavo enrasado",Vector3.new(.085,.025,.085),Vector3.new(x+dx,.64,z+dz),C.trim,Enum.Material.Metal)) end
   end
  end
 end
 -- Troncos apilados. Fachada con puerta y huecos acristalados.
 for y=1.5,31.5,2 do
  part("Tronco trasero",Vector3.new(84,1.95,1.5),Vector3.new(0,y,36),C.wood,Enum.Material.WoodPlanks)
  for _,x in {-42,42} do part("Tronco lateral",Vector3.new(1.5,1.95,72),Vector3.new(x,y,0),C.wood,Enum.Material.WoodPlanks) end
  if y<15 then
   for _,x in {-26,26} do part("Fachada",Vector3.new(32,1.95,1.5),Vector3.new(x,y,-36),C.wood) end
  elseif y>=19.5 and y<=25.5 then
   for _,section in {{-34,16},{.5,25},{34.5,15}} do
    part("Pared entre ventanas",Vector3.new(section[2],1.95,1.5),Vector3.new(section[1],y,-36),C.wood)
   end
  else part("Dintel de fachada",Vector3.new(84,1.95,1.5),Vector3.new(0,y,-36),C.wood) end
 end
 for _,x in {-40,-20,0,40} do part("Pilar maestro",Vector3.new(1.4,32,1.4),Vector3.new(x,16,34.5),C.trim) end
 for _,x in {-41,41} do part("Viga longitudinal",Vector3.new(1.8,1.8,74),Vector3.new(x,32,0),C.trim) end
 local angle=math.atan(10/43)
 for _,side in {-1,1} do
  part("Faldon de tejado",Vector3.new(44.2,1,76),Vector3.new(side*21.5,37,0),C.trim,Enum.Material.WoodPlanks,CFrame.Angles(0,0,-side*angle))
 end
 for z=-30,30,20 do
  part("Tirante",Vector3.new(82,.8,.8),Vector3.new(0,31.5,z),C.trim)
  for _,side in {-1,1} do part("Cercha",Vector3.new(44,.8,.8),Vector3.new(side*21,36.5,z),C.trim,nil,CFrame.Angles(0,0,-side*angle)) end
  part("Pendolon",Vector3.new(.7,10,.7),Vector3.new(0,37,z),C.trim)
 end
 -- Entrepiso en L: escalera izquierda y galería del fondo.
 part("Entrepiso lateral",Vector3.new(20,1,24),Vector3.new(-31,16,23),C.floor,Enum.Material.WoodPlanks)
 part("Galeria",Vector3.new(62,1,12),Vector3.new(10,16,30),C.floor,Enum.Material.WoodPlanks)
 for _,pos in {Vector3.new(-21,8,12),Vector3.new(-21,8,24),Vector3.new(5,8,24),Vector3.new(39,8,24)} do part("Soporte del entrepiso",Vector3.new(1,16,1),pos,C.trim) end
 for i=1,20 do
  local height=i*.8
  part("Escalon "..i,Vector3.new(9,height,1.5),Vector3.new(-31,height/2+.5,-19+(i-1)*1.5),C.floor)
 end
 part("Descansillo de escalera",Vector3.new(9,1,1.5),Vector3.new(-31,16,10.75),C.floor)
 rail(Vector3.new(-36,1,-19),Vector3.new(-36,16,10))
 rail(Vector3.new(-26,1,-19),Vector3.new(-26,16,10))
 rail(Vector3.new(-21,16.5,12),Vector3.new(-21,16.5,24))
 rail(Vector3.new(-20,16.5,24),Vector3.new(40,16.5,24))
 -- Ventanales, cortinas y acceso siempre abierto.
 for _,x in {-19,20} do
  local glass=decor(part("Ventana nocturna",Vector3.new(11,8,.25),Vector3.new(x,23,-36.9),Color3.fromRGB(57,84,103),Enum.Material.Glass))
  glass.Transparency=.25
  for _,dx in {-6,0,6} do decor(part("Marco de ventana",Vector3.new(.4,9,.7),Vector3.new(x+dx,23,-37.1),C.trim)) end
  for _,dy in {-4.5,4.5} do decor(part("Marco horizontal",Vector3.new(12,.4,.7),Vector3.new(x,23+dy,-37.1),C.trim)) end
  for _,dx in {-7,7} do decor(part("Cortina",Vector3.new(1.4,10,.5),Vector3.new(x+dx,23,-35.2),C.cream,Enum.Material.Fabric)) end
 end
 part("Felpudo",Vector3.new(15,.15,7),Vector3.new(0,.8,-31),C.green,Enum.Material.Fabric)
 local welcome=decor(part("Cartel del refugio",Vector3.new(17,3,.3),Vector3.new(0,17,-34.9),C.trim))
 text(welcome,"FORGOTTEN\nEL ULTIMO REFUGIO",Enum.NormalId.Back)
 -- Hogar de piedra, repisa, leña y emblema original en lugar de trofeo animal.
 part("Chimenea alta",Vector3.new(12,32,3),Vector3.new(22,16,33),C.stone,Enum.Material.Cobblestone)
 part("Hueco oscuro del hogar",Vector3.new(8,6,.3),Vector3.new(22,3.5,31.3),Color3.fromRGB(18,16,15),Enum.Material.Slate)
 for _,dx in {-5,5} do part("Pilar del hogar",Vector3.new(2,7,3),Vector3.new(22+dx,4,30),C.stone,Enum.Material.Cobblestone) end
 part("Repisa",Vector3.new(15,1.2,5),Vector3.new(22,8,30),C.trim)
 part("Piedra de hogar",Vector3.new(16,.6,9),Vector3.new(22,1,28),C.stone,Enum.Material.Cobblestone)
 for _,dx in {-1.5,1.5} do part("Leño",Vector3.new(4,.7,.8),Vector3.new(22+dx,1.8,29.5),C.wood,nil,CFrame.Angles(0,dx/3,0)) end
 local ember=decor(part("Brasas",Vector3.new(5,.3,2),Vector3.new(22,2,29.5),Color3.fromRGB(255,115,35),Enum.Material.Neon))
 local fire=Instance.new("Fire");fire.Size=5;fire.Heat=3;fire.Parent=ember
 local warm=Instance.new("PointLight");warm.Color=Color3.fromRGB(255,163,88);warm.Range=28;warm.Brightness=2;warm.Shadows=true;warm.Parent=ember
 local emblem=decor(part("Emblema amistad fracturada",Vector3.new(4,4,.5),Vector3.new(22,12,31),C.gold,Enum.Material.Metal,CFrame.Angles(0,0,math.rad(45))))
 decor(part("Grieta del emblema",Vector3.new(.2,4,.6),emblem.Position,Color3.fromRGB(25,20,24),Enum.Material.Slate))
 -- Salón: sofá, butacas, alfombra, mesas y lámpara de pie.
 local rug=decor(part("Alfombra tejida",Vector3.new(20,.15,16),Vector3.new(20,.8,15),C.green,Enum.Material.Fabric))
 for x=11,29,2 do decor(part("Banda de alfombra",Vector3.new(.18,.03,15.6),Vector3.new(x,.9,15),C.cream,Enum.Material.Fabric)) end
 local function sofa(pos,width,rotation)
  local base=CFrame.new(pos)*CFrame.Angles(0,rotation,0)
  local function piece(name,size,offset,color)
   local p=part(name,size,(base*CFrame.new(offset)).Position,color,Enum.Material.Fabric)
   p.CFrame=base*CFrame.new(offset);return p
  end
  piece("Asiento tapizado",Vector3.new(width,1,3.5),Vector3.new(0,2,0),C.cream)
  piece("Respaldo",Vector3.new(width,3.2,.8),Vector3.new(0,3.1,1.5),C.green)
  for _,side in {-1,1} do piece("Brazo",Vector3.new(.8,2.4,4),Vector3.new(side*width/2,2.6,0),C.green) end
  for _,dx in {-width/4,width/4} do piece("Cojin",Vector3.new(width/2-.5,.3,2.8),Vector3.new(dx,2.7,0),C.cream) end
 end
 sofa(Vector3.new(21,0,10),12,math.pi)
 sofa(Vector3.new(33,0,20),5,-math.pi/2)
 sofa(Vector3.new(10,0,20),5,math.pi/2)
 part("Mesa de centro",Vector3.new(8,.6,4),Vector3.new(22,2.5,19),C.trim)
 for _,dx in {-3,3} do part("Pata de mesa",Vector3.new(.5,2,.5),Vector3.new(22+dx,1.5,19),C.trim) end
 local journal=decor(part("Diario del accidente",Vector3.new(2,.2,1.5),Vector3.new(22,2.95,19),C.gold))
 local prompt=Instance.new("ProximityPrompt");prompt.ActionText="Leer diario";prompt.ObjectText="La amistad rota";prompt.MaxActivationDistance=8;prompt.Parent=journal
 prompt.Triggered:Connect(function(p) remote:FireClient(p,"message","El accidente con ácido separó a Guest 666 y Death Speaker. Uno busca venganza; el otro todavía intenta recuperar su amistad.") end)
 part("Base lampara",Vector3.new(2,.3,2),Vector3.new(34,1,12),C.trim,Enum.Material.Metal)
 part("Pie lampara",Vector3.new(.2,6,.2),Vector3.new(34,4,12),C.gold,Enum.Material.Metal)
 part("Pantalla",Vector3.new(3,2,3),Vector3.new(34,7,12),C.cream,Enum.Material.Fabric);lamp(Vector3.new(34,6.7,12))
 -- Billar azul, seis troneras, bolas y tacos: decoración reconocible.
 part("Cuerpo billar",Vector3.new(13,2,8),Vector3.new(-6,3,9),C.trim)
 part("Tapete azul",Vector3.new(11.8,.2,6.8),Vector3.new(-6,4.15,9),Color3.fromRGB(48,110,124),Enum.Material.Fabric)
 for _,dx in {-5,5} do for _,dz in {-2.8,2.8} do part("Pata billar",Vector3.new(1.3,2,1.3),Vector3.new(-6+dx,1.5,9+dz),C.trim) end end
 for _,dx in {-5.6,0,5.6} do for _,dz in {-3.1,3.1} do
  local pocket=decor(part("Tronera",Vector3.new(.12,.9,.9),Vector3.new(-6+dx,4.3,9+dz),Color3.fromRGB(14,15,16)))
  pocket.Shape=Enum.PartType.Cylinder;pocket.CFrame*=CFrame.Angles(0,0,math.pi/2)
 end end
 for i=1,6 do local ball=decor(part("Bola "..i,Vector3.new(.5,.5,.5),Vector3.new(-8+i*.65,4.6,9+(i%2)*.6),roster[i].color,Enum.Material.SmoothPlastic));ball.Shape=Enum.PartType.Ball end
 decor(part("Taco sobre mesa",Vector3.new(.12,.12,10),Vector3.new(-6,4.5,10),C.gold,nil,CFrame.Angles(0,.4,0)))
 -- Aparador, radio, estantería, reloj y recuerdos enmarcados.
 part("Aparador",Vector3.new(11,4,3),Vector3.new(-15,2.5,-17),C.wood)
 for _,dx in {-3,0,3} do
  decor(part("Cajon",Vector3.new(2.8,2.8,.15),Vector3.new(-15+dx,2.6,-18.6),C.floor))
  decor(part("Tirador",Vector3.new(.6,.15,.2),Vector3.new(-15+dx,2.6,-18.8),C.gold,Enum.Material.Metal))
 end
 local radio=part("Radio de las señales perdidas",Vector3.new(3,1.5,1),Vector3.new(-17,5.3,-17),C.trim)
 decor(part("Dial de radio",Vector3.new(1.5,.5,.1),Vector3.new(-17,5.5,-17.6),C.gold,Enum.Material.Neon))
 local rp=Instance.new("ProximityPrompt");rp.ActionText="Examinar radio";rp.ObjectText="SHADOW REAPER · 165 BPM";rp.Parent=radio
 rp.Triggered:Connect(function(p) remote:FireClient(p,"message","Shadow Reaper: rock, orquesta y terror retro. Las señales se intensifican cuando Tubers 93 se acerca. Audio pendiente de incorporar.") end)
 for _,x in {-36,36} do
  part("Estanteria",Vector3.new(7,10,2),Vector3.new(x,5.5,32),C.trim)
  for y=2,9,3 do
   part("Balda",Vector3.new(7,.25,2.5),Vector3.new(x,y,31.7),C.floor)
   for j=1,7 do decor(part("Libro de archivo",Vector3.new(.6,1.8,1.2),Vector3.new(x-3+j*.75,y+1,31.4),roster[(j%6)+1].color)) end
  end
 end
 local clock=decor(part("Reloj detenido",Vector3.new(3,3,.4),Vector3.new(5,12,34.7),C.gold,Enum.Material.Metal))
 text(clock,"12\nXI : VI")
 -- Seis retratos abstractos; no personajes nuevos ni imágenes externas.
 for i,entry in ipairs(roster) do
  local x=-15+(i-1)*5
  local frame=decor(part("Retrato "..entry.name,Vector3.new(4,4.8,.4),Vector3.new(x,21,34.7),C.gold))
  local canvas=decor(part("Lienzo "..entry.id,Vector3.new(3.5,4.3,.15),Vector3.new(x,21,34.4),entry.color))
  text(canvas,entry.name.."\nFORGOTTEN")
 end
 local function plant(pos)
  part("Maceta",Vector3.new(2.4,2.5,2.4),pos+Vector3.new(0,1.25,0),C.stone,Enum.Material.Concrete)
  for i=1,5 do
   local leaf=decor(part("Hoja",Vector3.new(.4,5,1.1),pos+Vector3.new((i-3)*.35,4,0),C.green,Enum.Material.Grass,CFrame.Angles(0,i*.9,(i-3)*.2)))
  end
 end
 for _,pos in {Vector3.new(36,.6,-28),Vector3.new(-38,.6,-28),Vector3.new(-17,.6,-5),Vector3.new(-38,16.5,17)} do plant(pos) end
 -- Objetos de pared reinterpretados: tabla de rutas, aro de rescate y señales.
 local board=decor(part("Tabla de rutas",Vector3.new(2,9,.5),Vector3.new(39,6,-12),C.green,nil,CFrame.Angles(0,0,-.2)))
 text(board,"RUTA\n93\nNO SALGAS SOLO")
 local ring=decor(part("Recuerdo de rescate",Vector3.new(4,4,.5),Vector3.new(-15,11,34.7),Color3.fromRGB(151,60,47)))
 text(ring,"ULTIMO\nREFUGIO")
 local warning=decor(part("Señal del entrepiso",Vector3.new(6,4,.4),Vector3.new(-35,21,34.7),Color3.fromRGB(137,55,43)))
 text(warning,"NO\nOLVIDAR")
 -- Bancos del altillo, mesa y vitrina de seis recuerdos.
 for _,z in {16,22,28} do sofa(Vector3.new(-37,16.5,z),4,math.pi/2) end
 part("Mesa del altillo",Vector3.new(4,2.5,8),Vector3.new(-26,18,23),C.trim)
 for i,e in ipairs(roster) do
  decor(part("Recuerdo "..e.id,Vector3.new(.8,1.2,.8),Vector3.new(-26+(i%2)*1.2,20,19+i),e.color,Enum.Material.Glass))
 end
 for _,pos in {Vector3.new(-8,25,-12),Vector3.new(21,25,6),Vector3.new(-30,25,23),Vector3.new(15,25,27)} do lamp(pos,true) end
 for _,pos in {Vector3.new(-12,6,-17),Vector3.new(36,9,30)} do lamp(pos,false) end
 -- Segunda pasada de detalle: piezas pequeñas sin colisión, evitando bloquear recorridos.
 local detail=Instance.new("Folder");detail.Name="ArtesaniaYDesgaste";detail.Parent=lobby
 local function small(name,size,pos,color,material,rotation)
  local p=decor(part(name,size,pos,color,material,rotation));p.Parent=detail;return p
 end
 -- Mampostería visible con juntas, tonos variados y dovelas sobre el fuego.
 for row=0,12 do
  for col=0,3 do
   local x=17.6+col*2.9
   local y=1.7+row*2.3
   if y>7.7 or col==0 or col==3 then
    small("Sillar de piedra envejecida",Vector3.new(2.74,2.12,.45),Vector3.new(x,y,31.2),C.stone:Lerp(C.cream,((row*7+col*3)%9)/45),Enum.Material.Cobblestone)
   end
  end
 end
 for i=0,8 do small("Dovela del hogar",Vector3.new(1.15,1.5,.6),Vector3.new(17.4+i*1.15,7.3,29.6),C.stone,Enum.Material.Slate) end
 -- Morillos, ceniza y leños carbonizados.
 for _,x in {19.5,24.5} do
  small("Morillo de hierro",Vector3.new(.25,1.6,2.8),Vector3.new(x,1.8,28.6),C.trim,Enum.Material.Metal)
 end
 small("Ceniza",Vector3.new(5,.12,2.5),Vector3.new(22,1.4,28.6),Color3.fromRGB(52,48,45),Enum.Material.Slate)
 for i=1,7 do
  small("Brasa individual",Vector3.new(.45,.15,.35),Vector3.new(19.8+i*.58,1.55,28.1+(i%3)*.45),Color3.fromRGB(222,82+i*9,20),Enum.Material.Neon)
 end
 -- Juntas y herrajes de las vigas.
 for _,x in {-40,-20,0,40} do
  for _,y in {3,15,29} do
   small("Abrazadera de hierro",Vector3.new(1.55,.45,1.55),Vector3.new(x,y,34.5),C.trim,Enum.Material.Metal)
   small("Remache",Vector3.new(.2,.2,.15),Vector3.new(x,y,33.65),C.gold,Enum.Material.Metal)
  end
 end
 -- Molduras, zócalos y rodapiés.
 for _,x in {-41,41} do small("Rodapie lateral",Vector3.new(.4,1,70),Vector3.new(x,1.3,0),C.trim) end
 small("Rodapie trasero",Vector3.new(82,1,.4),Vector3.new(0,1.3,35),C.trim)
 for _,z in {12.5,23.5} do small("Moldura altillo",Vector3.new(19.5,.35,.25),Vector3.new(-31,16.8,z),C.gold) end
 -- Revestimiento y ribetes de los asientos.
 for i=-4,4 do
  small("Costura del sofa",Vector3.new(.035,.03,2.6),Vector3.new(21+i*1.12,2.88,10),C.floor,Enum.Material.Fabric)
 end
 for _,x in {17.2,24.8} do
  small("Cojin de terciopelo",Vector3.new(2,1.7,.65),Vector3.new(x,3.3,9),Color3.fromRGB(111,62,47),Enum.Material.Fabric,CFrame.Angles(.16,0,.18))
 end
 -- Enmarcado de alfombra, borlas y trama discreta.
 for _,x in {10.2,29.8} do small("Borde de alfombra",Vector3.new(.3,.04,15.8),Vector3.new(x,.96,15),C.gold,Enum.Material.Fabric) end
 for _,z in {7.1,22.9} do
  small("Borde de alfombra",Vector3.new(19.6,.04,.3),Vector3.new(20,.96,z),C.gold,Enum.Material.Fabric)
  for x=11,29,.7 do small("Fleco",Vector3.new(.12,.035,.5),Vector3.new(x,.92,z+(z<15 and -.3 or .3)),C.cream,Enum.Material.Fabric) end
 end
 -- Tazas, papeles, botella y vela sobre la mesa de centro.
 for _,x in {19.5,24.5} do
  small("Plato",Vector3.new(1,.08,1),Vector3.new(x,2.87,19),C.cream,Enum.Material.CeramicTiles)
  local mug=small("Taza de ceramica",Vector3.new(.65,.7,.65),Vector3.new(x,3.25,19),C.green,Enum.Material.CeramicTiles)
  small("Cafe",Vector3.new(.52,.04,.52),Vector3.new(x,3.62,19),C.trim,Enum.Material.SmoothPlastic)
  small("Asa de taza",Vector3.new(.2,.4,.2),Vector3.new(x+.4,3.25,19),C.green,Enum.Material.CeramicTiles)
 end
 small("Carta sin enviar",Vector3.new(1.6,.035,1.1),Vector3.new(22.2,2.9,20),C.cream,Enum.Material.SmoothPlastic,CFrame.Angles(0,.2,0))
 local bottle=small("Botella antigua",Vector3.new(.65,1.5,.65),Vector3.new(25,3.5,18),Color3.fromRGB(38,68,56),Enum.Material.Glass)
 bottle.Transparency=.25
 small("Cuello de botella",Vector3.new(.3,.6,.3),Vector3.new(25,4.5,18),C.green,Enum.Material.Glass)
 small("Vela",Vector3.new(.4,.9,.4),Vector3.new(20,3.3,18),C.cream)
 -- Tachuelas de billar y cantos de madera noble.
 for _,z in {5,13} do
  small("Banda de billar",Vector3.new(13.4,.55,.5),Vector3.new(-6,4.35,z),C.wood)
  for x=-11,-1,2 do small("Diamante de billar",Vector3.new(.12,.04,.12),Vector3.new(x,4.65,z),C.cream,Enum.Material.Metal) end
 end
 for _,x in {-12.5,.5} do small("Banda lateral billar",Vector3.new(.5,.55,8.3),Vector3.new(x,4.35,9),C.wood) end
 -- Los faroles reciben jaulas y vidrio real; luces existentes se conservan.
 local lights={}
 for _,obj in ipairs(lobby:GetChildren()) do if obj.Name=="Luz ambar" then table.insert(lights,obj) end end
 for _,glow in ipairs(lights) do
  for _,dx in {-.68,.68} do
   for _,dz in {-.68,.68} do small("Jaula del farol",Vector3.new(.09,1.7,.09),glow.Position+Vector3.new(dx,0,dz),C.trim,Enum.Material.Metal) end
  end
  local glass=small("Cristal del farol",Vector3.new(1.3,1.55,1.3),glow.Position,Color3.fromRGB(215,185,133),Enum.Material.Glass)
  glass.Transparency=.82
 end
 -- Cortinas con pliegues en lugar de paneles lisos.
 for _,x in {-26,-12,13,27} do
  for j=0,3 do small("Pliegue de cortina",Vector3.new(.2,9.8,.25),Vector3.new(x-.55+j*.35,23,-34.85),C.cream:Lerp(C.wood,j%2*.13),Enum.Material.Fabric) end
 end
 -- Luz azul del exterior: contraste frío contra el fuego, sin audio ni assets remotos.
 for _,x in {-19,20} do
  local anchor=small("Rebote lunar",Vector3.new(.1,.1,.1),Vector3.new(x,23,-34),Color3.fromRGB(115,149,189))
  anchor.Transparency=1
  local moon=Instance.new("PointLight");moon.Color=Color3.fromRGB(125,161,215);moon.Brightness=.7;moon.Range=26;moon.Shadows=true;moon.Parent=anchor
 end

 -- NPC distribuidos con espacio para hablar y circular.
 if createNPCs~=false then
 local positions={Vector3.new(7,0,30),Vector3.new(33,0,-16),Vector3.new(-15,0,-10),Vector3.new(-14,0,10),Vector3.new(12,16.5,30),Vector3.new(29,0,24)}
 for i,entry in ipairs(roster) do
  local origin=positions[i]
  local npc=Instance.new("Model");npc.Name=entry.name;npc.Parent=lobby
  local function body(name,size,offset,color)
   local p=part(name,size,origin+offset,color,Enum.Material.SmoothPlastic);p.Parent=npc;return p
  end
  body("Torso",Vector3.new(2.2,2.4,1.2),Vector3.new(0,3.5,0),entry.color)
  local head=body("Head",Vector3.new(1.5,1.5,1.5),Vector3.new(0,5.5,0),C.cream)
  for _,side in {-1,1} do
   body(side<0 and "LeftLeg" or "RightLeg",Vector3.new(.9,2,1),Vector3.new(side*.6,1.3,0),C.trim)
   body(side<0 and "LeftArm" or "RightArm",Vector3.new(.7,2.3,1),Vector3.new(side*1.5,3.5,0),entry.color)
   local eye=body("Ojo",Vector3.new(.12,.16,.1),Vector3.new(side*.3,5.6,-.8),C.trim);eye.CanCollide=false
  end
  local pp=Instance.new("ProximityPrompt");pp.ActionText="Escuchar historia";pp.ObjectText=entry.name;pp.MaxActivationDistance=8;pp.Parent=head
  pp.Triggered:Connect(function(p) remote:FireClient(p,"message",entry.name..(entry.confirmedLore and "\n" or " [historia provisional]\n")..entry.lore) end)
  local sign=decor(part("Modelo provisional",Vector3.new(5,1,.1),origin+Vector3.new(0,7.5,0),C.trim))
  text(sign,entry.name.." · PROVISIONAL")
 end
 local cosmetics=require(script.Parent.Appearance)
 for _,npc in ipairs(lobby:GetChildren()) do
  for _,entry in ipairs(roster) do
   if npc.Name==entry.name then
    for _,child in ipairs(npc:GetChildren()) do if child.Name=="Ojo" then child:Destroy() end end
    cosmetics.apply(npc,entry.id,true)
   end
  end
 end
 end
 local spawn=Instance.new("SpawnLocation")
 spawn.Name="Refugio";spawn.Position=Vector3.new(0,1,-25);spawn.Size=Vector3.new(6,1,6)
 spawn.Neutral=true;spawn.Anchored=true;spawn.Transparency=1;spawn.CanCollide=false;spawn.Parent=lobby
 return lobby
end
