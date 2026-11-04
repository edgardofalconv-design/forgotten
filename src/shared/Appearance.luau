local A={}
function A.describe(id)
 local list={}
 local black=Color3.fromRGB(13,15,18)
 local white=Color3.fromRGB(221,222,215)
 local brown=Color3.fromRGB(98,48,20)
 local gold=Color3.fromRGB(153,132,40)
 local silver=Color3.fromRGB(138,146,165)
 local cyan=Color3.fromRGB(32,150,181)
 local purple=Color3.fromRGB(60,41,69)
 local killer=id=="guest666" or id=="tubers93"
 local robot=id=="junkbot"
 local ghost=id=="deathspeaker"
 local skin=id=="yellowguy" and Color3.fromRGB(245,205,48) or robot and gold or ghost and Color3.fromRGB(29,49,58) or id=="guest666" and black or id=="baller" and Color3.fromRGB(222,176,66) or white
 local coat=ghost and purple or black
 local function p(name,anchor,size,offset,color,angle,shape,neon,label)
  table.insert(list,{name=name,anchor=anchor,size=Vector3.new(size[1],size[2],size[3]),offset=Vector3.new(offset[1],offset[2],offset[3]),color=color,angle=angle or 0,shape=shape or "Block",neon=neon,label=label})
 end
 local function ball(name,anchor,size,offset,color,angle,neon)p(name,anchor,size,offset,color,angle,"Ball",neon)end
 -- Rounded replacement heads, with layered eyes instead of flat square dots.
 if robot or ghost then ball("Cabeza esculpida","Head",{1.05,1.1,1.04},{0,0,0},skin)
 else p("Cabeza esculpida","Head",{1.05,1.05,1.04},{0,0,0},skin,math.pi/2,"Cylinder") end
 for _,side in ipairs({-1,1}) do
  if robot or ghost then
   ball("Cuenca oscura","Head",{.33,.26,.14},{side*.21,.08,-.48},black,side*.25)
   ball("Ojo luminoso","Head",{.18,.12,.08},{side*.21,.09,-.56},robot and Color3.fromRGB(49,127,71) or cyan,side*.25,true)
  else
   ball("Ojo","Head",{.065,.11,.05},{side*.18,.1,-.52},id=="guest666" and Color3.fromRGB(180,12,25) or black,0,id=="guest666")
   if id=="baller" then
    ball("Esclerotica","Head",{.24,.1,.06},{side*.2,.1,-.51},white,side*.13)
    ball("Iris","Head",{.075,.09,.045},{side*.17,.09,-.55},black)
    p("Ceja expresiva","Head",{.27,.045,.05},{side*.21,.25,-.5},brown,side*-.2)
   end
  end
 end
 if not robot and not ghost and id~="guest666" then
  for i=0,7 do
   local t=i/7*math.pi
   ball("Sonrisa","Head",{.045,.04,.025},{math.cos(t)*.18,-.13-math.sin(t)*.13,-.52},black)
  end
 end
 if id=="pelotocino" or id=="tubers93" or id=="baller" then
  local hair=id=="baller" and Color3.fromRGB(164,107,30) or brown
  ball("Masa de cabello","Head",{1.15,.65,1.08},{0,.5,.08},hair)
  for i=-3,3 do
   local height=id=="baller" and (.55+(3-math.abs(i))*.09) or .45
   ball("Mechon curvado","Head",{.24,height,.75},{i*.15,.58,-.13},hair,i*.16)
   ball("Brillo del pelo","Head",{.045,height*.8,.64},{i*.15-.045,.6,-.2},hair:Lerp(gold,.28),i*.16)
   if id~="baller" and i~=0 then
    ball("Mechon frontal","Head",{.16,.52,.22},{i*.15,.31,-.47},hair,i*.11)
   end
  end
  for _,side in ipairs({-1,1}) do ball("Patilla","Head",{.14,.4,.6},{side*.49,.18,.03},hair) end
 end
 if id=="pelotocino" or id=="tubers93" then
  p("Camiseta azul","Torso",{.5,.95,.05},{0,0,-.53},Color3.fromRGB(16,90,138))
  for _,side in ipairs({-1,1}) do
   p("Chaqueta abierta","Torso",{.27,.97,.15},{side*.37,0,-.52},black)
   p("Solapa","Torso",{.1,.65,.13},{side*.25,.13,-.61},Color3.fromRGB(37,40,43),side*.15)
   p("Bolsillo","Torso",{.18,.15,.08},{side*.37,-.18,-.63},Color3.fromRGB(26,29,30))
   local arm=side<0 and "LeftArm" or "RightArm"
   p("Manga corta",arm,{1.03,.5,1.04},{0,.24,0},black)
  end
 elseif id=="guest666" then
  ball("Copa de gorra","Head",{1.16,.48,1.1},{0,.52,.04},Color3.fromRGB(30,27,26))
  ball("Visera de gorra","Head",{1.2,.09,.8},{0,.4,-.58},Color3.fromRGB(104,30,31))
  p("Insignia gorra","Head",{.26,.23,.03},{0,.61,-.5},black,0,nil,false,"R")
  p("Logo camiseta","Torso",{.9,.34,.04},{0,.17,-.53},black,0,nil,false,"ROBLOX")
  for _,side in ipairs({-1,1}) do p("Banda roja manga",side<0 and "LeftArm" or "RightArm",{1.04,.16,1.05},{0,.1,0},Color3.fromRGB(116,26,32),.12) end
 elseif id=="baller" then
  p("Camisa blanca","Torso",{.44,.96,.055},{0,0,-.53},white)
  for _,side in ipairs({-1,1}) do
   p("Solapa de smoking","Torso",{.19,.74,.09},{side*.28,.1,-.59},Color3.fromRGB(29,34,38),side*.28)
   ball("Pajarita","Torso",{.18,.12,.12},{side*.08,.35,-.64},black,side*.25)
  end
  for i=1,4 do ball("Boton de camisa","Torso",{.035,.035,.04},{0,.19-i*.15,-.6},black) end
  p("Numero 246","Torso",{.23,.17,.03},{-.36,.19,-.59},black,0,nil,false,"246")
 elseif robot then
  ball("Casco robot","Head",{1.12,.8,.92},{0,.2,.08},gold)
  for _,side in ipairs({-1,1}) do
   ball("Ojo del casco","Head",{.3,.25,.12},{side*.21,.09,-.49},black,side*.3)
   ball("Cristal verde","Head",{.18,.15,.08},{side*.21,.09,-.56},Color3.fromRGB(45,112,66),side*.3,true)
   p("Aleta lateral","Head",{.13,.66,.33},{side*.52,.52,.12},gold,side*.18)
   ball("Hombrera dorada",side<0 and "LeftArm" or "RightArm",{1.4,.4,1.3},{0,.35,0},gold)
  end
  p("Cresta dorsal","Head",{.16,1.65,.48},{0,1.05,.38},gold)
  for i=0,10 do p("Ranura verde de cresta","Head",{.08,.04,.04},{0,.37+i*.13,.12},Color3.fromRGB(64,112,60)) end
  ball("Peto articulado","Torso",{.94,.72,.72},{0,.15,-.36},gold)
  p("Panel central","Torso",{.38,.16,.08},{0,.13,-.76},gold,0,nil,false,"◈")
  for i=1,5 do ball("Anillo abdominal","Torso",{.55,.09,.8},{0,-.24-i*.1,0},Color3.fromRGB(67,71,64)) end
 elseif ghost then
  ball("Capucha exterior","Head",{1.23,1.22,1.12},{0,.09,.15},purple)
  ball("Hueco de capucha","Head",{.96,.92,.3},{0,.03,-.46},black)
  for _,side in ipairs({-1,1}) do
   ball("Pomulo espectral","Head",{.22,.35,.18},{side*.25,-.18,-.59},Color3.fromRGB(45,66,77),side*.2)
   ball("Ojo espectral","Head",{.21,.14,.08},{side*.2,.1,-.64},cyan,side*.2,true)
   for j=0,6 do
    local size=.23-j*.025
    ball("Cuerno curvo","Head",{size,.24,size},{side*(.48+j*.045+math.sin(j*.5)*.17),.4+j*.16,.05},j>4 and cyan or black,side*.4)
   end
   local arm=side<0 and "LeftArm" or "RightArm"
   ball("Hombrera labrada",arm,{1.6,.48,1.45},{0,.38,0},silver)
   for j=0,3 do ball("Espina azul",arm,{.25-j*.045,.32,.25-j*.045},{side*(.35+j*.06),.6+j*.13,0},j>1 and cyan or purple,side*.35) end
  end
  ball("Coraza curvada","Torso",{1.04,.82,.38},{0,.08,-.49},silver)
  ball("Engaste de gema","Torso",{.32,.25,.12},{0,.26,-.71},purple)
  ball("Gema azul","Torso",{.22,.17,.1},{0,.26,-.78},cyan,0,true)
  for _,side in ipairs({-1,1}) do
   for j=0,5 do ball("Filigrana","Torso",{.07,.07,.04},{side*(.13+j*.06),.12-math.sin(j*.55)*.15,-.7},purple) end
  end
  for i=-3,3 do
   p("Faldon desgarrado","Torso",{.15,.9-math.abs(i)*.12,.12},{i*.13,-.66,-.51},purple,i*.09)
  end
 end
 -- Boots, gauntlets and fingers are attached to limbs, not to the torso.
 for _,side in ipairs({-1,1}) do
  local leg=side<0 and "LeftLeg" or "RightLeg"
  local arm=side<0 and "LeftArm" or "RightArm"
  ball("Bota",leg,{1.13,.32,1.5},{0,-.42,-.2},(id=="pelotocino" or id=="tubers93") and white or black)
  if robot or ghost then
   ball("Rodillera",leg,{1.1,.34,1.15},{0,.1,-.16},robot and gold or silver)
   p("Greba",leg,{.66,.65,.16},{0,-.12,-.57},robot and gold or purple)
   ball("Guantelete",arm,{1.15,.52,1.18},{0,-.27,0},robot and Color3.fromRGB(64,68,64) or silver)
   for j=-1,1 do
    ball("Garra",arm,{.18,.32,.22},{j*.26,-.65,-.05},robot and black or cyan,j*.15)
   end
  end
 end
 if id=="tubers93" then
  p("Pechera triste","Torso",{.86,.46,.08},{0,.24,-.67},Color3.fromRGB(195,142,30),0,nil,false,"︵ ︵\n︵")
  p("Asta guadana","Torso",{.045,2.4,.09},{1,.1,0},silver)
  for i=0,11 do
   local a=i/11*1.8
   p("Hoja curva","Torso",{.18,.15,.1},{1-math.sin(a)*.9,1.29+(math.cos(a)-1)*.43,0},silver,a-.4)
  end
  for i=0,11 do ball("Eslabon de cadena","Torso",{.05,.07,.04},{.94+math.sin(i)*.02,.3-i*.08,-.1},silver) end
 end
 if id=="pelotocino" then
  p("Mochila","Torso",{.78,.85,.42},{0,0,.65},Color3.fromRGB(88,64,38))
  p("Bolsillo de mochila","Torso",{.55,.38,.12},{0,-.18,.91},Color3.fromRGB(64,49,34))
  for _,side in ipairs({-1,1}) do p("Correa de mochila","Torso",{.09,.9,.07},{side*.34,0,-.57},Color3.fromRGB(88,64,38)) end
 elseif id=="yellowguy" then
  p("Baston","RightArm",{.12,1.7,.12},{0,-.55,-.65},brown)
  p("Empunadura del baston","RightArm",{.4,.12,.14},{-.12,.27,-.65},gold)
 end
 if not killer then
  p("CombatMark_Cicatriz","Head",{.018,.19,.02},{-.32,-.07,-.52},Color3.fromRGB(113,74,57),-.35)
  p("CombatMark_Venda","Head",{.17,.08,.02},{.27,-.2,-.52},white,.2)
  p("CombatMark_Raspon","Torso",{.18,.015,.03},{-.2,-.2,-.74},Color3.fromRGB(103,91,72),.3)
  p("CombatMark_Desgaste","Torso",{.12,.015,.03},{-.15,-.26,-.74},Color3.fromRGB(103,91,72),.3)
 end
 if id=="tubers93" then
  for _,piece in ipairs(list) do
   if piece.name=="Asta guadana" or piece.name=="Hoja curva" or piece.name=="Eslabon de cadena" then
    piece.anchor="RightArm"
    piece.offset=Vector3.new(piece.offset.X*2-1.5,piece.offset.Y,piece.offset.Z)
    piece.size=Vector3.new(piece.size.X*2,piece.size.Y,piece.size.Z)
   end
  end
 end
 return list,skin,coat
end
function A.apply(model,id,anchored)
 local old=model:FindFirstChild("ForgottenAppearance")
 if old then old:Destroy() end
 local folder=Instance.new("Folder");folder.Name="ForgottenAppearance";folder.Parent=model
 local pieces,skin,coat=A.describe(id)
 for _,body in ipairs(model:GetChildren()) do
  if body:IsA("BasePart") and body.Name~="HumanoidRootPart" then
   body.Color=(id=="junkbot" and Color3.fromRGB(70,76,70)) or (id=="deathspeaker" and Color3.fromRGB(35,61,70)) or Color3.fromRGB(23,25,27)
   if id=="yellowguy" then
    body.Color=body.Name:find("Leg") and Color3.fromRGB(66,112,65) or body.Name:find("Torso") and Color3.fromRGB(43,95,178) or skin
   end
   if (id=="pelotocino" or id=="tubers93") and (body.Name=="Brazo" or body.Name:find("Arm") or body.Name:find("Hand")) then body.Color=skin end
  end
 end
 local head=model:FindFirstChild("Head")
 local torso=model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
 if head then
  head.Color=skin;head.Transparency=1
  for _,d in ipairs(head:GetChildren()) do if d:IsA("Decal") then d.Transparency=1 end end
 end
 if torso then torso.Color=id=="yellowguy" and Color3.fromRGB(43,95,178) or coat end
 for _,spec in ipairs(pieces) do
  local anchor
  if spec.anchor=="Head" then anchor=head
  elseif spec.anchor=="Torso" then anchor=torso
  else
   local spaced=spec.anchor:gsub("Left","Left "):gsub("Right","Right ")
   local lower=spec.anchor:gsub("Arm","LowerArm"):gsub("Leg","LowerLeg")
   local upper=spec.anchor:gsub("Arm","UpperArm")
   local shoulder=spec.name:find("Hombrera") or spec.name=="Manga corta" or spec.name=="Banda roja manga"
   anchor=model:FindFirstChild(spec.anchor) or model:FindFirstChild(spaced) or (shoulder and model:FindFirstChild(upper)) or model:FindFirstChild(lower)
  end
  if anchor then
   local function scale(v)return Vector3.new(v.X*anchor.Size.X,v.Y*anchor.Size.Y,v.Z*anchor.Size.Z)end
   local p=Instance.new("Part");p.Name=spec.name;p.Size=scale(spec.size)
   p.CFrame=anchor.CFrame*CFrame.new(scale(spec.offset))*CFrame.Angles(0,0,spec.angle)
   p.Color=spec.color;p.Material=spec.neon and Enum.Material.Neon or Enum.Material.SmoothPlastic
   p.Anchored=anchored;p.CanCollide=false;p.CanTouch=false;p.Massless=true
   if spec.shape=="Ball" then p.Shape=Enum.PartType.Ball elseif spec.shape=="Cylinder" then p.Shape=Enum.PartType.Cylinder end
   p.Parent=folder
   if spec.label then
    local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Front;gui.CanvasSize=Vector2.new(512,256);gui.Parent=p
    local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1;label.Text=spec.label;label.TextColor3=Color3.fromRGB(240,230,218);label.TextScaled=true;label.Parent=gui
   end
   if not anchored then local weld=Instance.new("WeldConstraint");weld.Part0=anchor;weld.Part1=p;weld.Parent=p end
  end
 end
end
return A
