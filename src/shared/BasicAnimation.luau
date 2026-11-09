-- V3 character-specific animation state machine. Every observer samples server time.
local Config=require(script.Parent.AnimationConfig)
local Motion=require(script.Parent.CharacterMotion)
local Pelotocino=require(script.Parent.PelotocinoRenderer)
return function()
 local Collection=game:GetService("CollectionService")
 local RunService=game:GetService("RunService")
 local rigs={}
 local function add(model)
  local joints,visuals={},{}
  for _,object in ipairs(model:GetDescendants()) do
   if object:IsA("Motor6D") then joints[Motion.jointKey(object.Name)]=object
   elseif object:IsA("BasePart") then
    local group=object.Parent
    local weapon=object:GetAttribute("WeaponKind") or group and group:GetAttribute("WeaponKind")
    local action=object:GetAttribute("VisibilityAction")
    if weapon or action then table.insert(visuals,{part=object,weapon=weapon,action=action}) end
   end
  end
  local data={joints=joints,visuals=visuals,phase=0,tracks={},state="idle",stateAt=0,wasAir=false}
  data.connection=model.DescendantAdded:Connect(function(object)
   if object:IsA("Motor6D") then joints[Motion.jointKey(object.Name)]=object
   elseif object:IsA("BasePart") then
    local weapon=object:GetAttribute("WeaponKind") or object.Parent and object.Parent:GetAttribute("WeaponKind")
    local action=object:GetAttribute("VisibilityAction")
    if weapon or action then table.insert(visuals,{part=object,weapon=weapon,action=action}) end
   end
  end)
  rigs[model]=data
 end
 local function external(data,h,id,key)
  local overrides=Config.characters and Config.characters[id]
  local asset=overrides and overrides[key] or Config[key]
  if type(asset)~="string" or not asset:match("^rbxassetid://%d+$") then return nil end
  if data.tracks[asset]==nil then
   local animator=h:FindFirstChildOfClass("Animator")
   if not animator then return nil end
   local clip=Instance.new("Animation");clip.AnimationId=asset
   local ok,result=pcall(function()return animator:LoadAnimation(clip)end)
   clip:Destroy();data.tracks[asset]=ok and result or false
  end
  return data.tracks[asset] or nil
 end
 Collection:GetInstanceAddedSignal("ForgottenAnimated"):Connect(add)
 Collection:GetInstanceRemovedSignal("ForgottenAnimated"):Connect(function(model)
  if rigs[model] and rigs[model].connection then rigs[model].connection:Disconnect() end
  rigs[model]=nil
 end)
 for _,model in ipairs(Collection:GetTagged("ForgottenAnimated")) do add(model) end
 RunService.PreSimulation:Connect(function(dt)
  local now=workspace:GetServerTimeNow()
  for model,data in pairs(rigs) do
   local root=model:FindFirstChild("HumanoidRootPart");local h=model:FindFirstChildOfClass("Humanoid")
   local camera=workspace.CurrentCamera
   local nearby=root and (not root.Anchored or not camera or (camera.CFrame.Position-root.Position).Magnitude<180)
   if model:IsDescendantOf(workspace) and root and h and nearby then
    local velocity=root.AssemblyLinearVelocity
    local speed=Vector3.new(velocity.X,0,velocity.Z).Magnitude
    data.phase=data.phase+dt*(speed>1 and math.min(16,5+speed*.32) or 2)
    local id=model:GetAttribute("CharacterIdentity") or "pelotocino"
    local air=h.FloorMaterial==Enum.Material.Air and not root.Anchored
    if data.wasAir and not air then data.landedAt=now end
    data.wasAir=air
    local action=model:GetAttribute("Action") or ""
    local actionTime=now-(model:GetAttribute("ActionAt") or -100)
    local use=(model:GetAttribute("ItemActionUntil") or 0)>now and model:GetAttribute("ItemAction")
    local state=h.Health<=0 and "death"
     or (model:GetAttribute("StunnedUntil") or 0)>now and "stun"
     or now-(model:GetAttribute("DamageAt") or -100)<.22 and "hit"
     or use or (model:GetAttribute("RepairStage") or 0)>0 and "repairGenerator" or air and (velocity.Y>1 and "jump" or "fall")
     or now-(data.landedAt or -100)<.28 and "land"
     or speed>23 and "sprint" or speed>18 and "run" or speed>.7 and "walk" or "idle"
    if state~=data.state then data.state=state;data.stateAt=now end
    local key=Motion.durations[action] and actionTime<Motion.durations[action] and actionTime>=0 and action or state
    local track=external(data,h,id,key) or (key~=state and external(data,h,id,"skill"))
    if track then
     if data.current~=track then
      if data.current then data.current:Stop(.12) end
      track.Looped=key=="idle" or key=="walk" or key=="run" or key=="sprint"
      track:Play(.12);data.current=track
     end
    else
     if data.current then data.current:Stop(.12);data.current=nil end
     local pose=Motion.sample(id,state,data.phase,speed,action,actionTime,{stateTime=now-data.stateAt,repairStage=model:GetAttribute("RepairStage"),pullElapsed=now-(model:GetAttribute("RepairPullAt") or -100)})
     local alpha=1-math.exp(-dt*19)
     for name,joint in pairs(data.joints) do
      local values=pose[name]
      if values then
       local target=Motion.toTransform(joint,values)
       joint.Transform=(model:GetAttribute("PelotocinoR15") and key~=state) and target or joint.Transform:Lerp(target,alpha)
      end
     end
    end
    if model:GetAttribute("PelotocinoR15") then Pelotocino.update(model,action,actionTime) end
    local away=(model:GetAttribute("CaneAwayUntil") or 0)>now
    for _,visual in ipairs(data.visuals) do
     if visual.part.Parent then
      if visual.action then visual.part.Transparency=action==visual.action and actionTime>=0 and actionTime<1 and 0 or 1 end
      if visual.weapon=="cane" then visual.part.LocalTransparencyModifier=(away or visual.part:GetAttribute("MeshReplaced")) and 1 or 0 end
     end
    end
   end
  end
 end)
end
