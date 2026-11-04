local Debris=game:GetService("Debris")
local TweenService=game:GetService("TweenService")
local SoundService=game:GetService("SoundService")
local Music=require(script.Parent.Music)
local RunService=game:GetService("RunService")
local Geometry=require(script.Parent.VisualGeometry)
local VisualData=require(script.Parent.CharacterVisualData)
return function(enabled)
 local folder=Instance.new("Folder");folder.Name="EfectosLocalesForgotten";folder.Parent=workspace
 local function sound(key)
  local id=Music.sfx and Music.sfx[key]
  if type(id)~="string" or not id:match("^rbxassetid://%d+$") then return end
  local s=Instance.new("Sound");s.SoundId=id;s.Volume=.3;s.Parent=SoundService;s:Play();Debris:AddItem(s,8)
 end
 local function effect(data)
  if not enabled() or #folder:GetChildren()>24 then return end
  local weapon=data.ability
  if data.model and (weapon=="scythe" or weapon=="spin" or weapon=="cane" or weapon=="pan" or weapon=="claw") then
   local arm=data.model:FindFirstChild("RightHand") or data.model:FindFirstChild("Right Arm")
   if arm then
    local a=Instance.new("Attachment");local b=Instance.new("Attachment")
    a.Position=Vector3.new(0,-.2,-.6)
    if weapon=="scythe" or weapon=="spin" then a.Position=Vector3.new(0,2.4,-.65);b.Position=Vector3.new(2,1.5,-.65)
    elseif weapon=="cane" then b.Position=Vector3.new(0,-2.45,-.58)
    else b.Position=Vector3.new(.4,-1,-.85) end
    a.Parent=arm;b.Parent=arm
    local trail=Instance.new("Trail");trail.Attachment0=a;trail.Attachment1=b;trail.Lifetime=.15;trail.MinLength=.05;trail.FaceCamera=true
    trail.Color=ColorSequence.new(data.color=="red" and Color3.fromRGB(202,67,51) or Color3.fromRGB(207,180,112))
    trail.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.35),NumberSequenceKeypoint.new(1,1)});trail.Parent=folder
    task.delay(.65,function()if trail.Parent then trail.Enabled=false end end)
    Debris:AddItem(trail,.9);Debris:AddItem(a,.9);Debris:AddItem(b,.9)
   end
  end
  if data.kind=="projectile" and data.finish then
   local start=data.position
   if data.model and not data.returning then
    local hand=data.model:FindFirstChild("RightHand") or data.model:FindFirstChild("Right Arm")
    if hand then start=hand.Position+hand.CFrame.UpVector*-.65 end
   end
   local projectile=Instance.new("Model");projectile.Name="Proyectil_"..tostring(data.projectile)
   local root=Instance.new("Part");root.Name="Centro";root.Size=Vector3.new(.1,.1,.1);root.CFrame=CFrame.new();root.Transparency=1
   root.Anchored=true;root.CanCollide=false;root.CanTouch=false;root.CanQuery=false;root.Parent=projectile;projectile.PrimaryPart=root
   if data.projectile=="cane" then
    for _,spec in ipairs(VisualData.yellowguy) do if not spec.name:find("CombatMark") then Geometry.build(projectile,root,spec) end end
   else
    for _,spec in ipairs(VisualData.pelotocino) do if spec.name=="Mechón Bacon 0" then Geometry.build(projectile,root,spec);break end end
   end
   projectile.Parent=folder
   local began=os.clock();local duration=math.max(.1,data.duration or .4);local connection
   connection=RunService.RenderStepped:Connect(function()
    if not projectile.Parent then connection:Disconnect();return end
    local t=math.clamp((os.clock()-began)/duration,0,1)
    local finish=data.finish
    if data.returning and data.model and data.model.Parent then
     local hand=data.model:FindFirstChild("RightHand") or data.model:FindFirstChild("Right Arm")
     if hand then finish=hand.Position end
    end
    local position=start:Lerp(finish,t)+Vector3.new(0,math.sin(t*math.pi)*(data.returning and .4 or 1.2),0)
    projectile:PivotTo(CFrame.new(position)*CFrame.Angles(0,0,t*math.pi*3))
    if t>=1 then connection:Disconnect();projectile:Destroy() end
   end)
   Debris:AddItem(projectile,duration+1);sound("skill");return
  end
  if data.model and (data.kind=="transformation" or data.kind=="step") then
   local highlight=Instance.new("Highlight");highlight.Adornee=data.model;highlight.FillTransparency=.75;highlight.OutlineTransparency=.35
   highlight.FillColor=data.kind=="transformation" and Color3.fromRGB(161,22,39) or Color3.fromRGB(49,165,198);highlight.OutlineColor=highlight.FillColor;highlight.Parent=folder
   Debris:AddItem(highlight,data.kind=="transformation" and 1.5 or .6)
   if data.kind=="step" then
    local previous={}
    for _,part in ipairs(data.model:GetDescendants()) do if part:IsA("BasePart") then previous[part]=part.LocalTransparencyModifier;part.LocalTransparencyModifier=math.max(.75,part.LocalTransparencyModifier) end end
    task.delay(.3,function()for part,value in pairs(previous) do if part.Parent then part.LocalTransparencyModifier=value end end end)
   end
  end
  local p=Instance.new("Part");p.Name="FX_"..data.kind;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Material=Enum.Material.Neon
  p.Color=data.color=="red" and Color3.fromRGB(192,69,51) or Color3.fromRGB(68,162,188)
  p.Transparency=.65
  local duration=math.max(.15,math.min(data.duration or .4,6))
  if data.kind=="beam" and data.finish then
   local distance=(data.finish-data.position).Magnitude
   if distance<.1 then p:Destroy();return end
   p.Size=Vector3.new(.18,.18,distance);p.CFrame=CFrame.lookAt((data.position+data.finish)/2,data.finish)
  else
   local radius=math.min(data.radius or 2,24)
   p.Shape=Enum.PartType.Ball;p.Size=Vector3.new(radius*2,.22,radius*2);p.Position=data.position-Vector3.new(0,2.4,0)
   if data.kind=="fire" then local fire=Instance.new("Fire");fire.Size=4;fire.Heat=0;fire.Parent=p end
  end
  p.Parent=folder;TweenService:Create(p,TweenInfo.new(duration),{Transparency=1}):Play();Debris:AddItem(p,duration+.1)
  sound(data.kind=="hit" and "hit" or "skill")
 end
 local function reveal(data)
  for _,model in ipairs(data.models or {}) do
   if typeof(model)=="Instance" and model:IsA("Model") then
    local h=Instance.new("Highlight");h.Adornee=model;h.FillColor=Color3.fromRGB(214,88,74);h.FillTransparency=.8;h.OutlineTransparency=.15
    h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;h.Parent=folder;Debris:AddItem(h,math.min(data.duration or 5,10))
   end
  end
 end
 return {effect=effect,reveal=reveal,sound=sound}
end
