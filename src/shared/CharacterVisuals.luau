local Data=require(script.Parent.CharacterVisualData)
local Geometry=require(script.Parent.VisualGeometry)
local Visuals={}
local palettes={
 pelotocino={skin={237,235,226},torso={18,21,25},legs={25,30,32}},
 yellowguy={skin={245,205,48},torso={13,105,172},legs={75,151,75}},
 guest666={skin={12,13,17},torso={13,15,19},legs={14,16,20}},
 tubers93={skin={221,219,208},torso={16,18,22},legs={24,28,31}},
 junkbot={skin={157,134,51},torso={66,72,64},legs={63,69,63}},
 deathspeaker={skin={33,65,75},torso={33,65,75},legs={33,65,75}}}
local function rgb(t)return Color3.fromRGB(t[1],t[2],t[3])end
function Visuals.anchor(model,name,specName)
 if name=="Torso" then return model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso") end
 if name=="Head" then return model:FindFirstChild("Head") end
 local spaced=name:gsub("Left","Left "):gsub("Right","Right ")
 local direct=model:FindFirstChild(spaced) or model:FindFirstChild(name)
 if direct then return direct end
 local lower=name:gsub("Arm","LowerArm"):gsub("Leg","LowerLeg")
 local upper=name:gsub("Arm","UpperArm"):gsub("Leg","UpperLeg")
 return model:FindFirstChild(specName and specName:find("Hombrera") and upper or lower)
end
local function surface(part,name)
 local gui=Instance.new("SurfaceGui");gui.Name=name;gui.Face=Enum.NormalId.Front;gui.CanvasSize=Vector2.new(512,512);gui.Parent=part
 return gui
end
local function panel(gui,pos,size,color)
 local f=Instance.new("Frame");f.BorderSizePixel=0;f.Position=UDim2.fromScale(pos[1],pos[2]);f.Size=UDim2.fromScale(size[1],size[2]);f.BackgroundColor3=rgb(color);f.Parent=gui;return f
end
function Visuals.apply(model,id)
 local old=model:FindFirstChild("ForgottenAppearance");if old then old:Destroy() end
 local folder=Instance.new("Folder");folder.Name="ForgottenAppearance";folder.Parent=model
 local palette=palettes[id];local head=model:FindFirstChild("Head");local torso=Visuals.anchor(model,"Torso")
 for _,part in ipairs(model:GetChildren()) do
  if part:IsA("BasePart") and part.Name~="HumanoidRootPart" then
   part.Transparency=0;part.Material=Enum.Material.SmoothPlastic
   part.Color=rgb(palette.skin)
   if part.Name:find("Torso") then part.Color=rgb(palette.torso)
   elseif part.Name:find("Leg") or part.Name:find("Foot") then part.Color=rgb(palette.legs) end
  end
 end
 -- Native Roblox head geometry and built-in smile, rather than a hidden head + cube stack.
 if head then
  for _,child in ipairs(head:GetChildren()) do if child:IsA("Decal") or child:IsA("SpecialMesh") then child:Destroy() end end
  if head:IsA("Part") then
   head.Size=Vector3.new(2,1,1)
   local mesh=Instance.new("SpecialMesh");mesh.MeshType=Enum.MeshType.Head;mesh.Scale=Vector3.new(1.25,1.25,1.25);mesh.Parent=head
  end
  if id=="pelotocino" or id=="yellowguy" or id=="tubers93" then
   local face=Instance.new("Decal");face.Name="ClassicSmile";face.Face=Enum.NormalId.Front;face.Texture="rbxasset://textures/face.png";face.Parent=head
  elseif id=="guest666" then
   local gui=surface(head,"OjosGuest")
   for _,x in ipairs({.35,.59}) do local eye=panel(gui,{x,.37},{.06,.14},{217,20,34});local round=Instance.new("UICorner");round.CornerRadius=UDim.new(1,0);round.Parent=eye end
  else head.Transparency=1 end
 end
 if id=="pelotocino" or id=="tubers93" then
  local shirt=surface(torso,"CamisetaYChaqueta")
  panel(shirt,{.3,.02},{.4,.96},{14,102,157})
  for _,x in ipairs({.24,.72}) do local lapel=panel(shirt,{x,.03},{.07,.58},{43,47,49});lapel.Rotation=x<.5 and -10 or 10 end
 elseif id=="guest666" then
  local gui=surface(torso,"CamisetaGuest")
  local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(.94,.27);text.Position=UDim2.fromScale(.03,.25);text.BackgroundTransparency=1
  text.Text="ROBLOX";text.TextScaled=true;text.Font=Enum.Font.GothamBlack;text.TextColor3=Color3.fromRGB(230,228,217);text.TextStrokeColor3=Color3.fromRGB(149,26,36);text.TextStrokeTransparency=0;text.Parent=gui
 elseif id=="deathspeaker" or id=="junkbot" then
  for _,part in ipairs(model:GetChildren()) do if part:IsA("BasePart") then part.Transparency=1 end end
 end
 local officialHair=model:GetAttribute("OfficialBaconHair")
 for index,spec in ipairs(Data[id] or {}) do
  local hair=spec.name:find("Bacon") or spec.name=="Cabellera" or spec.name=="Veta de cabello" or spec.name=="Patilla curva"
  if not (officialHair and hair) then
   local anchor=Visuals.anchor(model,spec.anchor,spec.name)
   if anchor then
    if spec.body then anchor.Transparency=1 end
    local group=Geometry.build(folder,anchor,spec);group:SetAttribute("VisualSpecIndex",index)
    if id=="yellowguy" and not spec.name:find("CombatMark") then group:SetAttribute("WeaponKind","cane") end
   end
  end
 end
 model:SetAttribute("VisualVersion",3);model:SetAttribute("GeometryBackend","Native shapes + authored surfaces")
end
return Visuals
