-- R15 skeleton and shared authored appearance contract. The visible body is MeshParts.
-- Native Roblox APIs are used when Studio is available; no external IDs are guessed.
local Players=game:GetService("Players")
local Data=require(script.Parent.PelotocinoMeshData)
local Rig={}
local nativeTemplate
local attempted=false
local function vec(v)return Vector3.new(v[1],v[2],v[3])end
function Rig.create()
 local model
 if not attempted then
  attempted=true
  local ok,result=pcall(function()
   local description=Instance.new("HumanoidDescription")
   description.WidthScale=.75;description.DepthScale=.85;description.HeightScale=.95
   return Players:CreateHumanoidModelFromDescriptionAsync(description,Enum.HumanoidRigType.R15)
  end)
  if ok and result then nativeTemplate=result;nativeTemplate.Parent=nil end
 end
 if nativeTemplate then model=nativeTemplate:Clone() else model=Instance.new("Model") end
 model.Name="pelotocino"
 -- Normalize native joint positions to the authored R15 dimensions. Invisible
 -- physics bodies do not draw the visible character or a cube fallback.
 for _,node in ipairs(model:GetDescendants())do
  if node:IsA("Motor6D") or node:IsA("Accessory") or node:IsA("Script") or node:IsA("LocalScript") or node:IsA("Decal") or node:IsA("SpecialMesh") then node:Destroy() end
 end
 for name,position in pairs(Data.anchors)do
  local part=model:FindFirstChild(name)
  if not part then part=Instance.new("Part");part.Name=name;part.Parent=model end
  part.Size=name=="HumanoidRootPart" and Vector3.new(1.4,2,.75) or name=="Head" and Vector3.new(1.3,1.18,1.06)
   or name=="UpperTorso" and Vector3.new(1.25,1.10,.68) or name=="LowerTorso" and Vector3.new(1.1,.55,.64)
   or name:find("Foot") and Vector3.new(.65,.44,.98) or name:find("Hand") and Vector3.new(.45,.45,.40)
   or name:find("Arm") and Vector3.new(.5,.7,.5) or Vector3.new(.60,.9,.65)
  part.CFrame=CFrame.new(vec(position));part.Transparency=1;part.CanCollide=name=="UpperTorso" or name=="LowerTorso"
  part.CanTouch=name=="HumanoidRootPart";part.CanQuery=true;part.Anchored=false;part.CastShadow=false;part.Massless=name~="HumanoidRootPart"
  for _,a in ipairs(part:GetChildren())do if a:IsA("Attachment") then a:Destroy() end end
 end
 local h=model:FindFirstChildOfClass("Humanoid") or Instance.new("Humanoid")
 h.Name="Humanoid";h.RigType=Enum.HumanoidRigType.R15;h.AutomaticScalingEnabled=false
 h.HipHeight=Data.hipHeight;h.MaxHealth=100;h.Health=100;h.WalkSpeed=16;h.BreakJointsOnDeath=false;h.Parent=model
 for _,joint in ipairs(Data.joints)do
  local name,p0,p1,point=joint[1],model[joint[2]],model[joint[3]],vec(joint[4])
  local a=Instance.new("Attachment");a.Name=name.."RigAttachment";a.Position=point-p0.Position;a.Parent=p0
  local b=Instance.new("Attachment");b.Name=a.Name;b.Position=point-p1.Position;b.Parent=p1
  local motor=Instance.new("Motor6D");motor.Name=name;motor.Part0=p0;motor.Part1=p1
  motor.C0=CFrame.new(a.Position);motor.C1=CFrame.new(b.Position);motor.Parent=p0
 end
 for name,partName in pairs({RightGripAttachment="RightHand",LeftGripAttachment="LeftHand",HairAttachment="Head",BodyBackAttachment="UpperTorso"})do
  local a=Instance.new("Attachment");a.Name=name;a.Parent=model[partName]
 end
 local release=Instance.new("Attachment");release.Name="BaconRelease";release.Position=Vector3.new(0,-.82,-.15);release.Parent=model.RightHand
 if not h:FindFirstChildOfClass("Animator")then Instance.new("Animator").Parent=h end
 model.PrimaryPart=model.HumanoidRootPart
 model:SetAttribute("CharacterIdentity","pelotocino");model:SetAttribute("PelotocinoR15",true)
 model:SetAttribute("NativeAvatarRig",nativeTemplate~=nil);model:SetAttribute("Placeholder",false)
 model:SetAttribute("ModelStatus","Pelotocino R15 · mallas propias · prueba de Studio pendiente")
 return model
end
return Rig
