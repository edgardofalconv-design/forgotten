-- Procedural defaults remain functional with no external AnimationIds.
local Config=require(script.Parent.AnimationConfig)
return function()
 local Collection=game:GetService("CollectionService")
 local RunService=game:GetService("RunService")
 local rigs={}
 local function add(model)
  local joints={}
  for _,obj in ipairs(model:GetDescendants()) do
   if obj:IsA("Motor6D") then
    local name=obj.Name:gsub(" ","")
    if name=="LeftShoulder" or name=="RightShoulder" or name=="LeftHip" or name=="RightHip" or name=="Neck" or name=="Waist" or name=="RootJoint" then joints[name]=obj end
   end
  end
  rigs[model]={joints=joints,phase=0,tracks={}}
 end
 local function track(data,h,key)
  local id=Config[key]
  if type(id)~="string" or not id:match("^rbxassetid://%d+$") then return nil end
  if data.tracks[key]==nil then
   local animator=h:FindFirstChildOfClass("Animator")
   if not animator then return nil end
   local animation=Instance.new("Animation");animation.AnimationId=id
   local ok,result=pcall(function()return animator:LoadAnimation(animation)end)
   animation:Destroy();data.tracks[key]=ok and result or false
  end
  return data.tracks[key] or nil
 end
 Collection:GetInstanceAddedSignal("ForgottenAnimated"):Connect(add)
 Collection:GetInstanceRemovedSignal("ForgottenAnimated"):Connect(function(model)rigs[model]=nil end)
 for _,model in ipairs(Collection:GetTagged("ForgottenAnimated")) do add(model) end
 RunService.PreSimulation:Connect(function(dt)
  for model,data in pairs(rigs) do
   local root=model:FindFirstChild("HumanoidRootPart");local h=model:FindFirstChildOfClass("Humanoid")
   if model:IsDescendantOf(workspace) and root and h and h.Health>0 then
    local velocity=root.AssemblyLinearVelocity
    local speed=Vector3.new(velocity.X,0,velocity.Z).Magnitude
    data.phase=data.phase+dt*(speed>1 and math.min(15,5+speed*.3) or 2)
    local airborne=h.FloorMaterial==Enum.Material.Air and math.abs(velocity.Y)>2
    local now=workspace:GetServerTimeNow()
    local actionAt=model:GetAttribute("ActionAt") or -100
    local damageAt=model:GetAttribute("DamageAt") or -100
    local action=model:GetAttribute("Action") or ""
    local key=now-damageAt<.25 and "hit" or now-actionAt<.6 and "skill" or airborne and "jump" or speed>20 and "run" or speed>1 and "walk" or "idle"
    local external=track(data,h,key)
    if external then
     if data.current~=external then
      if data.current then data.current:Stop(.15) end
      external.Looped=key=="idle" or key=="walk" or key=="run";external:Play(.15);data.current=external
     end
    else
     if data.current then data.current:Stop(.15);data.current=nil end
     local swing=math.sin(data.phase)*(speed>20 and .82 or speed>1 and .6 or .035)
     for name,joint in pairs(data.joints) do
      local angle=(name:find("Left") and 1 or -1)*swing
      local yaw=0
      if name:find("Shoulder") then
       angle=airborne and -.8 or -angle
       if now-actionAt<.6 then
        if action=="shield" or action=="caneGuard" then angle=-1.2
        elseif name=="RightShoulder" then angle=-1.5+math.sin((now-actionAt)*8)*.8 end
       end
      elseif name=="Neck" then angle=now-damageAt<.25 and -.28 or math.sin(data.phase*.5)*.025
      elseif name=="RootJoint" or name=="Waist" then
       angle=0
       if action=="spin" and now-actionAt<.6 then yaw=(now-actionAt)/.6*math.pi*2 end
      end
      joint.Transform=CFrame.Angles(angle,yaw,0)
     end
    end
   end
  end
 end)
end
