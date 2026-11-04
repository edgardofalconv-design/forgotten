local RS=game:GetService("ReplicatedStorage")
local Lighting=game:GetService("Lighting")
local Factory=require(RS.Shared.CharacterFactory)
local World={}

function World.part(parent,name,size,position,color,material)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=position
 p.Color=color;p.Material=material or Enum.Material.Metal;p.Anchored=true
 if World.variants and World.variants[p.Material] then p.MaterialVariant=World.variants[p.Material] end
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent
 return p
end

function World.label(part,message)
 local surface=Instance.new("SurfaceGui");surface.Face=Enum.NormalId.Front;surface.CanvasSize=Vector2.new(600,260);surface.Parent=part
 local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1
 text.TextColor3=Color3.fromRGB(242,229,193);text.TextScaled=true;text.TextWrapped=true;text.Text=message;text.Parent=surface
 return text
end

function World.build(roster,remote)
 local preview=workspace:FindFirstChild("LobbyPreview");if preview then preview:Destroy() end
 local old=workspace:FindFirstChild("Forgotten");if old then old:Destroy() end
 local world=Instance.new("Folder");world.Name="Forgotten";world.Parent=workspace
 Lighting.ClockTime=0.5;Lighting.Brightness=2.1
 Lighting.Ambient=Color3.fromRGB(38,43,53);Lighting.OutdoorAmbient=Color3.fromRGB(57,72,97)
 Lighting.GlobalShadows=true;Lighting.ShadowSoftness=.35;Lighting.ExposureCompensation=.18
 Lighting.EnvironmentDiffuseScale=.58;Lighting.EnvironmentSpecularScale=.65
 Lighting.FogColor=Color3.fromRGB(27,35,46);Lighting.FogEnd=420
 local grade=Lighting:FindFirstChild("ForgottenGrade") or Instance.new("ColorCorrectionEffect")
 grade.Name="ForgottenGrade";grade.Contrast=.12;grade.Saturation=-.12;grade.TintColor=Color3.fromRGB(255,241,222);grade.Parent=Lighting
 local bloom=Lighting:FindFirstChild("FarolesSuaves") or Instance.new("BloomEffect")
 bloom.Name="FarolesSuaves";bloom.Intensity=.18;bloom.Size=20;bloom.Threshold=1.5;bloom.Parent=Lighting
 local atmosphere=Lighting:FindFirstChild("ForgottenAtmosphere") or Instance.new("Atmosphere")
 atmosphere.Name="ForgottenAtmosphere";atmosphere.Density=.24;atmosphere.Offset=.15;atmosphere.Haze=1.2;atmosphere.Color=Color3.fromRGB(168,181,194);atmosphere.Parent=Lighting
 local variants=require(RS.Shared.MaterialPack)()
 World.variants=variants
 local lobby=require(RS.Shared.Lobby)(world,roster,remote,variants,false)
 local camp=Instance.new("Model");camp.Name="CampamentoSoloLobby";camp.Parent=world
 local wood=Color3.fromRGB(81,55,40)
 local stone=Color3.fromRGB(80,88,86)
 for _,x in ipairs({-64,64}) do
  World.part(camp,"Suelo de cabaña abandonada",Vector3.new(23,1,21),Vector3.new(x,0,-55),wood,Enum.Material.WoodPlanks)
  World.part(camp,"Techo de chapa",Vector3.new(25,1,24),Vector3.new(x,12,-55),stone)
  for _,dx in ipairs({-11,11}) do World.part(camp,"Pared lateral",Vector3.new(1,12,21),Vector3.new(x+dx,6,-55),wood,Enum.Material.WoodPlanks) end
  World.part(camp,"Pared trasera",Vector3.new(23,12,1),Vector3.new(x,6,-45),wood,Enum.Material.WoodPlanks)
  for _,dx in ipairs({-8,8}) do World.part(camp,"Fachada rota",Vector3.new(7,10,1),Vector3.new(x+dx,5,-65),wood,Enum.Material.WoodPlanks) end
  local sign=World.part(camp,"Aviso",Vector3.new(7,2,.3),Vector3.new(x,10,-65.7),stone)
  World.label(sign,"CABAÑA ABANDONADA")
  World.part(camp,"Litera",Vector3.new(6,2,3),Vector3.new(x-6,1.6,-51),wood,Enum.Material.WoodPlanks)
 end
 for i=1,32 do
  local a=i/32*math.pi*2
  local pos=Vector3.new(math.cos(a)*84,0,math.sin(a)*84)
  local height=14+(i%4)*1.2
  local trunk=World.part(camp,"Tronco del campamento",Vector3.new(height,2.1,2.1),pos+Vector3.new(0,height/2,0),wood,Enum.Material.Wood)
  trunk.Shape=Enum.PartType.Cylinder;trunk.CFrame=trunk.CFrame*CFrame.Angles(0,0,math.pi/2)
  for tier=1,3 do
   local width=13-tier*2
   local leaves=World.part(camp,"Copa escalonada",Vector3.new(width,7,width),pos+Vector3.new(0,height-3+tier*3.4,0),Color3.fromRGB(22+i%3*3,46+i%5*3,34+i%4*2),Enum.Material.Grass)
   leaves.Shape=Enum.PartType.Ball;leaves.CanCollide=false;leaves.CanTouch=false;leaves.CanQuery=false;leaves.CastShadow=tier==1
  end
  if i%2==0 then
   local rock=World.part(camp,"Piedra musgosa",Vector3.new(3.2,1.3,2.1),pos*.88+Vector3.new(0,.2,0),Color3.fromRGB(67,75,65),Enum.Material.Slate)
   rock.Shape=Enum.PartType.Ball;rock.CanCollide=false;rock.CanQuery=false;rock.CanTouch=false
   for leaf=1,5 do
    local angle=leaf*math.pi*2/5
    local fern=World.part(camp,"Helecho de sotobosque",Vector3.new(.24,2.1,.7),pos*.92+Vector3.new(math.cos(angle)*.4,.7,math.sin(angle)*.4),Color3.fromRGB(39,67,44),Enum.Material.Grass)
    fern.Shape=Enum.PartType.Ball;fern.CFrame=fern.CFrame*CFrame.Angles(.5,angle,.25)
    fern.CanCollide=false;fern.CanTouch=false;fern.CanQuery=false;fern.CastShadow=false
   end
  end
 end
 local sign=World.part(camp,"Zona segura",Vector3.new(18,4,.4),Vector3.new(0,6,-46),wood,Enum.Material.WoodPlanks)
 sign.CanCollide=false;sign.CanQuery=false
 World.label(sign,"CAMPAMENTO · LOBBY\nEl escenario de partida está separado")
 local npcPositions={Vector3.new(7,.7,30),Vector3.new(33,.7,-16),Vector3.new(-15,.7,-10),Vector3.new(-14,.7,10),Vector3.new(12,16.5,30),Vector3.new(29,.7,24)}
 local npcs={}
 local function installNPC(index)
  local entry=roster[index]
  local npc=Factory.create(entry);npc.Name=entry.name
  Factory.place(npc,npcPositions[index]);npc.HumanoidRootPart.Anchored=true
  for _,part in ipairs(npc:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide=false end end
  local prompt=Instance.new("ProximityPrompt");prompt.ActionText="Escuchar historia";prompt.ObjectText=entry.name
  prompt.MaxActivationDistance=9;prompt.Parent=npc.Head
  prompt.Triggered:Connect(function(player)
   remote:FireClient(player,"message",entry.name..(entry.confirmedLore and "\n" or " [historia provisional]\n")..entry.lore)
  end)
  npc.Parent=lobby
  if npcs[index] then npcs[index]:Destroy() end
  npcs[index]=npc
 end
 for i=1,#roster do installNPC(i) end

 require(script.Parent.Camp).extend(world,remote,World)
 -- Keep warm pools of light, but bound the expensive shadow casters.
 local shadowLights=0
 for _,object in ipairs(world:GetDescendants()) do
  if object:IsA("PointLight") and object.Shadows then
   shadowLights=shadowLights+1;object.Shadows=shadowLights<=5
  end
 end
 local data={root=world,lobby=lobby,lobbyPosition=Vector3.new(0,.7,-25),spawn=lobby:FindFirstChild("Refugio"),refreshNPC=installNPC}
 local Maps=require(script.Parent.Maps)
 local mapCatalog=require(RS.Shared.MapCatalog)
 function data.loadMap(id)
  local definition=mapCatalog[1]
  for _,entry in ipairs(mapCatalog) do if entry.id==id then definition=entry end end
  if data.arena then data.arena:Destroy() end
  local built=Maps.build(world,definition,World)
  for key,value in pairs(built) do data[key]=value end
 end
 data.loadMap(mapCatalog[1].id)
 return data
end
return World
