local Camp={}
function Camp.extend(world,remote,World)
 local camp=Instance.new("Model");camp.Name="ClubHouseYCampamentoV2";camp.Parent=world
 local wood=Color3.fromRGB(91,67,47);local stone=Color3.fromRGB(95,101,95);local amber=Color3.fromRGB(230,173,89)
 local function p(name,size,x,y,z,tint,material,decor)
  local part=World.part(camp,name,size,Vector3.new(x,y,z),tint or wood,material or Enum.Material.WoodPlanks)
  if decor then part.CanCollide=false;part.CanTouch=false;part.CanQuery=false;part.CastShadow=false end
  return part
 end
 p("Camino al club",Vector3.new(9,.12,48),0,-.85,-62,stone,Enum.Material.Ground,true)
 for _,side in ipairs({-1,1}) do
  p("Camino a cabañas",Vector3.new(60,.12,7),side*34,-.84,-68,stone,Enum.Material.Ground,true)
  for i=1,5 do
   local lantern=p("Farol de camino",Vector3.new(.6,1,.6),side*6,1,-38-i*7,amber,Enum.Material.Neon,true)
   local light=Instance.new("PointLight");light.Color=amber;light.Range=12;light.Brightness=.65;light.Parent=lantern
  end
 end
 p("Plataforma club house",Vector3.new(39,1,20),0,0,-79)
 p("Techo club house",Vector3.new(42,.8,23),0,11,-79,wood:Lerp(stone,.4))
 for _,x in ipairs({-19,19}) do p("Pilar del club",Vector3.new(1,11,1),x,5.5,-70);p("Pilar del club",Vector3.new(1,11,1),x,5.5,-88) end
 p("Pared trasera del club",Vector3.new(39,10,1),0,5,-88)
 local sign=p("Club House",Vector3.new(16,2,.25),0,9,-69,stone,nil,true);World.label(sign,"CLUB HOUSE · EL ÚLTIMO REFUGIO")
 local counters={{"TIENDA","shop",-12},{"PERSONAJES","characters",0},{"INVENTARIO","inventory",12}}
 for _,data in ipairs(counters) do
  local counter=p(data[1],Vector3.new(9,3,4),data[3],2,-82,wood)
  local panel=p("Rótulo "..data[1],Vector3.new(8,2,.2),data[3],5,-84,stone,nil,true);World.label(panel,data[1])
  local prompt=Instance.new("ProximityPrompt");prompt.ActionText="Abrir";prompt.ObjectText=data[1];prompt.MaxActivationDistance=10;prompt.Parent=counter
  prompt.Triggered:Connect(function(player)remote:FireClient(player,"openPanel",data[2])end)
 end
 -- Quiet gathering spot on the east side; no objectives or combat triggers in the camp.
 for i=1,12 do
  local a=i/12*math.pi*2
  p("Piedra de fogata",Vector3.new(1.2,.5,1.2),24+math.cos(a)*3,.3,-53+math.sin(a)*3,stone,Enum.Material.Slate)
 end
 local log=p("Leña",Vector3.new(5,.7,1),24,.4,-53,wood,Enum.Material.Wood)
 local flame=Instance.new("Fire");flame.Size=3;flame.Heat=3;flame.Color=amber;flame.SecondaryColor=Color3.fromRGB(185,77,37);flame.Parent=log
 local light=Instance.new("PointLight");light.Color=amber;light.Brightness=1.3;light.Range=30;light.Shadows=true;light.Parent=log
 for _,offset in ipairs({-8,8}) do p("Banco junto a la fogata",Vector3.new(9,1.2,2),24,1,-53+offset,wood) end
 for i=1,16 do
  local x=-80+(i%8)*20;local z=i<=8 and 73 or -87
  if math.abs(x)>25 then
   p("Hierba del sendero",Vector3.new(2,.9,2),x,-.4,z,Color3.fromRGB(57,74,49),Enum.Material.Grass,true)
   p("Roca erosionada",Vector3.new(3.5,2.3,3),x+3,.2,z-3,stone,Enum.Material.Slate)
  end
 end
 return camp
end
return Camp
