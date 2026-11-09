local RS=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local Portraits=require(script.Parent.Portraits)
local Cosmetics=require(script.Parent.Cosmetics)
local T=require(script.Parent.ClientTheme)
local AnimationConfig=require(script.Parent.AnimationConfig)
local Motion=require(script.Parent.CharacterMotion)
local Preview={}
local function image(id)return type(Portraits[id])=="string" and Portraits[id]:match("^rbxassetid://%d+$") and Portraits[id] or nil end
function Preview.icon(parent,id,pos,size)
 local portrait=image(id)
 if portrait then
  local img=Instance.new("ImageLabel");img.Size=size;img.Position=pos;img.Image=portrait;img.BackgroundTransparency=1;img.ScaleType=Enum.ScaleType.Fit;img.Parent=parent;return img
 end
 local box=T.frame(parent,"RetratoPendiente",pos,size,T.bg)
 T.label(box,"Inicial",id:sub(1,1):upper(),UDim2.fromScale(0,0),UDim2.fromScale(1,.65),22,T.gold)
 T.label(box,"Estado","PEND.",UDim2.fromScale(0,.65),UDim2.fromScale(1,.35),9,T.muted)
 return box
end
function Preview.show(parent,id,equipment,pose)
 T.clear(parent)
 local viewport=Instance.new("ViewportFrame");viewport.Name="Vista3D";viewport.Size=UDim2.fromScale(1,.87);viewport.BackgroundTransparency=1
 viewport.Ambient=Color3.fromRGB(177,183,189);viewport.LightColor=Color3.fromRGB(255,229,190);viewport.LightDirection=Vector3.new(-1,-1,-1);viewport.Parent=parent
 local caption=T.label(parent,"EstadoModelo","Cargando vista…",UDim2.fromScale(0,.88),UDim2.fromScale(1,.1),12,T.muted)
 local folder=RS:FindFirstChild("CharacterPreviews");local source=folder and folder:FindFirstChild(id)
 if not source then caption.Text="VISTA PENDIENTE";return end
 local world=Instance.new("WorldModel");world.Parent=viewport
 local model=source:Clone();model.Parent=world
 task.defer(function()if model.Parent then require(script.Parent.EditableAppearance).apply(model);require(script.Parent.PelotocinoRenderer).apply(model) end end)
 Cosmetics.apply(model,id,equipment)
 local root=model:FindFirstChild("HumanoidRootPart");if root then root.Anchored=true end
 local center,size=model:GetBoundingBox()
 local camera=Instance.new("Camera");camera.FieldOfView=38;camera.Parent=viewport;viewport.CurrentCamera=camera
 local distance=math.max(size.Y*1.6,size.X*1.5,8)
 local focus=center.Position
 camera.CFrame=CFrame.lookAt(focus+Vector3.new(distance*.25,distance*.08,-distance),focus)
 caption.Text=(model:GetAttribute("Placeholder") and "MODELO PROVISIONAL" or "VISTA 3D · RETRATO PENDIENTE")..((model:GetAttribute("Milestone") or 0)>0 and " · SKIN PROVISIONAL" or "")
 local joints={}
 for _,node in ipairs(model:GetDescendants()) do if node:IsA("Motor6D") then joints[Motion.jointKey(node.Name)]=node end end
 local external
 local animKey=pose=="mvp" and "mvp" or pose=="victory" and (id=="guest666" and "guestVictory" or id=="tubers93" and "tubersVictory" or "results")
 local animationId=animKey and AnimationConfig[animKey]
 if type(animationId)=="string" and animationId:match("^rbxassetid://%d+$") then
  local humanoid=model:FindFirstChildOfClass("Humanoid");local animator=humanoid and humanoid:FindFirstChildOfClass("Animator")
  if animator then
   local animation=Instance.new("Animation");animation.AnimationId=animationId
   local ok,result=pcall(function()return animator:LoadAnimation(animation)end);animation:Destroy()
   if ok then external=result;external:Play() end
  end
 end
 local elapsed=0
 local connection
 connection=RunService.RenderStepped:Connect(function(dt)
  if not viewport.Parent then connection:Disconnect();return end
  elapsed=elapsed+dt
  local aspect=viewport.AbsoluteSize.X/math.max(1,viewport.AbsoluteSize.Y)
  distance=math.max(size.Y*1.6,size.X/math.max(.3,aspect)*1.6,8)
  camera.CFrame=CFrame.lookAt(focus+Vector3.new(math.sin(elapsed*.18)*distance*.18,distance*.08,-distance),focus)
  if not external or not external.IsPlaying then
  local transforms=pose and Motion.presentation(id,pose,elapsed) or Motion.sample(id,"idle",elapsed*2,0,"",100)
  for name,joint in pairs(joints) do
   local v=transforms[name]
   if v then joint.Transform=Motion.toTransform(joint,v) end
  end
  end
  if model:GetAttribute("PelotocinoR15")then require(script.Parent.PelotocinoRenderer).update(model,"",100)end
 end)
 viewport.Destroying:Connect(function()connection:Disconnect()end)
end
return Preview
