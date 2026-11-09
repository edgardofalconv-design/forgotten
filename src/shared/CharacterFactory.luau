local Storage=game:GetService("ServerStorage")
local Collection=game:GetService("CollectionService")
local Appearance=require(script.Parent.Appearance)
local Imported=require(script.Parent.ImportedAppearance)
local Catalog=require(script.Parent.CatalogCharacter)
local AvatarCatalog=require(script.Parent.AvatarCatalog)
local Visuals=require(script.Parent.CharacterVisuals)
local Factory={}
local PelotocinoRig=require(script.Parent.PelotocinoRig)

function Factory.validate(model,id)
 if not model or not model:IsA("Model") then return false,"Falta Model" end
 local h=model:FindFirstChildOfClass("Humanoid")
 local root=model:FindFirstChild("HumanoidRootPart")
 if not h or not root or not root:IsA("BasePart") then return false,"Falta Humanoid/HumanoidRootPart" end
 if h.RigType~=Enum.HumanoidRigType.R6 and h.RigType~=Enum.HumanoidRigType.R15 then return false,"Rig incompatible" end
 if not model:FindFirstChild("Head") or not (model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso")) then return false,"Cuerpo incompleto" end
 if model:GetAttribute("SourceBundleId")==589 and id~="junkbot" then return false,"El paquete 589 pertenece a Junkbot" end
 if model:GetAttribute("CharacterIdentity")~=id then return false,"Identidad del modelo sin verificar" end
 local joints=0
 local connected={}
 for _,child in ipairs(model:GetDescendants()) do
  if child:IsA("Motor6D") and child.Part0 and child.Part1 then
   joints=joints+1
   connected[child.Part0]=connected[child.Part0] or {};table.insert(connected[child.Part0],child.Part1)
   connected[child.Part1]=connected[child.Part1] or {};table.insert(connected[child.Part1],child.Part0)
  end
 end
 if joints<(h.RigType==Enum.HumanoidRigType.R15 and 15 or 6) then return false,"Faltan articulaciones Motor6D" end
 local reached={[root]=true};local queue={root};local index=1
 while index<=#queue do
  for _,part in ipairs(connected[queue[index]] or {}) do
   if not reached[part] then reached[part]=true;table.insert(queue,part) end
  end
  index=index+1
 end
 local required=h.RigType==Enum.HumanoidRigType.R6 and {"Head","Torso","Left Arm","Right Arm","Left Leg","Right Leg"}
  or {"Head","UpperTorso","LowerTorso","LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand","LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"}
 for _,name in ipairs(required) do
  local part=model:FindFirstChild(name)
  if not part or not part:IsA("BasePart") or not reached[part] then return false,"Parte desconectada: "..name end
 end
 return true
end

local function placeholder(entry)
 local model=Instance.new("Model")
 model.Name=entry.id
 local function part(name,size,pos)
  local p=Instance.new("Part")
  p.Name=name;p.Size=size;p.CFrame=CFrame.new(pos);p.Color=entry.color
  p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
  p.CanCollide=name=="Torso";p.Parent=model
  return p
 end
 local root=part("HumanoidRootPart",Vector3.new(2,2,1),Vector3.new())
 root.Transparency=1;root.CanCollide=false
 local torso=part("Torso",Vector3.new(2,2,1),Vector3.new())
 local head=part("Head",Vector3.new(2,1,1),Vector3.new(0,1.5,0))
 local function joint(name,p0,p1,c0,c1)
  local motor=Instance.new("Motor6D");motor.Name=name;motor.Part0=p0;motor.Part1=p1
  motor.C0=c0;motor.C1=c1;motor.Parent=p0
 end
 joint("RootJoint",root,torso,CFrame.new(),CFrame.new())
 joint("Neck",torso,head,CFrame.new(0,1,0),CFrame.new(0,-.5,0))
 for _,side in ipairs({-1,1}) do
  local prefix=side<0 and "Left" or "Right"
  local arm=part(prefix.." Arm",Vector3.new(1,2,1),Vector3.new(side*1.5,0,0))
  local leg=part(prefix.." Leg",Vector3.new(1,2,1),Vector3.new(side*.5,-2,0))
  joint(prefix.." Shoulder",torso,arm,CFrame.new(side,.5,0),CFrame.new(-side*.5,.5,0))
  joint(prefix.." Hip",torso,leg,CFrame.new(side*.5,-1,0),CFrame.new(0,1,0))
 end
 local humanoid=Instance.new("Humanoid");humanoid.RigType=Enum.HumanoidRigType.R6
 humanoid.DisplayName=entry.name;humanoid.Parent=model
 model.PrimaryPart=root
 model:SetAttribute("CharacterIdentity",entry.id)
 model:SetAttribute("Placeholder",true)
 model:SetAttribute("ModelStatus","Provisional")
 if Imported.apply(model,entry.id,false) then model:SetAttribute("ModelStatus","Malla importada · pendiente de validar")
 else Visuals.apply(model,entry.id);model:SetAttribute("ModelStatus","Modelo propio V4 · provisional") end
 return model
end

local function wear(model)
 if model:FindFirstChild("JunkbotWear") then return end
 local torso=model:FindFirstChild("UpperTorso")
 if not torso then return end
 local folder=Instance.new("Folder");folder.Name="JunkbotWear";folder.Parent=model
 for i=1,3 do
  local scratch=Instance.new("Part");scratch.Name="Raspon discreto"
  scratch.Size=Vector3.new(torso.Size.X*.16,.018,.012)
  scratch.CFrame=torso.CFrame*CFrame.new(-torso.Size.X*.2,-.05-i*.06,-torso.Size.Z/2-.012)*CFrame.Angles(0,0,.22)
  scratch.Color=Color3.fromRGB(118,115,90);scratch.Transparency=.3
  scratch.CanCollide=false;scratch.CanTouch=false;scratch.CanQuery=false;scratch.Massless=true;scratch.Parent=folder
  local weld=Instance.new("WeldConstraint");weld.Part0=torso;weld.Part1=scratch;weld.Parent=scratch
 end
end

function Factory.create(entry)
 local model
 local folder=Storage:FindFirstChild("CharacterModels")
 local installed=folder and folder:FindFirstChild(entry.id)
 if installed and (entry.id~="pelotocino" or installed:GetAttribute("PelotocinoR15")) then
  local valid,reason=Factory.validate(installed,entry.id)
  if valid then model=installed:Clone();model:SetAttribute("ModelStatus","Modelo instalado")
  else warn(entry.name..": "..reason..". Se conserva la plantilla y se usa un provisional.") end
 end
 if not model and entry.id=="pelotocino" then model=PelotocinoRig.create() end
 if not model and entry.id=="junkbot" then
  model=Catalog.clone()
  if model then
   model:SetAttribute("CharacterIdentity","junkbot")
   local valid,reason=Factory.validate(model,"junkbot")
   if not valid then warn(reason);model:Destroy();model=nil
   else model:SetAttribute("Placeholder",false);model:SetAttribute("ModelStatus","Modelo original de Roblox") end
  end
 end
 if not model and entry.id~="junkbot" then
  local native=AvatarCatalog.clone(entry.id)
  if native then
   local valid=Factory.validate(native,entry.id)
   if valid then
    model=native
    if model:GetAttribute("OfficialCatalogBody") then
     model:SetAttribute("Placeholder",false);model:SetAttribute("ModelStatus","Cuerpo original de Roblox · catálogo verificado")
    else
     Visuals.apply(model,entry.id)
     model:SetAttribute("Placeholder",true);model:SetAttribute("ModelStatus",model:GetAttribute("OfficialBaconHair") and "Rig y cabello Roblox · vestuario propio V4" or "Rig Roblox · apariencia propia V4")
    end
   else native:Destroy() end
  end
 end
 if not model then model=placeholder(entry) end
 if entry.id=="junkbot" and not model:GetAttribute("Placeholder") then wear(model) end
 -- Known local character scripts are provided by this project, not the source rig.
 for _,child in ipairs(model:GetDescendants()) do
  if child:IsA("Script") or child:IsA("LocalScript") then child:Destroy()
  elseif child:IsA("BasePart") then child.Anchored=false end
 end
 local root=model:FindFirstChild("HumanoidRootPart")
 model.PrimaryPart=root
 root.CanCollide=false;root.Transparency=1
 model:SetAttribute("CharacterIdentity",entry.id)
 local h=model:FindFirstChildOfClass("Humanoid")
 if not h:FindFirstChildOfClass("Animator") then local animator=Instance.new("Animator");animator.Parent=h end
 h.Health=100;h.MaxHealth=100;h.WalkSpeed=entry.role=="Asesino" and 18 or 16
 h.DisplayName=entry.name..(model:GetAttribute("Placeholder") and " [provisional]" or "")
 h.BreakJointsOnDeath=false
 Collection:AddTag(model,"ForgottenAnimated")
 return model
end

function Factory.place(model,groundPosition)
 local root=model:FindFirstChild("HumanoidRootPart")
 local h=model:FindFirstChildOfClass("Humanoid")
 local offset=h.RigType==Enum.HumanoidRigType.R6 and 3.4 or (h.HipHeight+root.Size.Y/2+.4)
 if model:GetAttribute("PelotocinoR15") then offset=h.HipHeight+root.Size.Y/2+.03 end
 model:PivotTo(CFrame.new(groundPosition+Vector3.new(0,offset,0)))
 root.AssemblyLinearVelocity=Vector3.new();root.AssemblyAngularVelocity=Vector3.new()
end

return Factory
