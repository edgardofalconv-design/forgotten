-- Client RunContext Script: works for an inserted NPC without other FORGOTTEN scripts.
local model=script.Parent
local package=model:WaitForChild("PelotocinoPackage")
local Motion=require(package.PelotocinoMotion)
local Renderer=require(package.PelotocinoRenderer)
Renderer.apply(model)
local joints={}
for _,part in ipairs(model:GetDescendants())do if part:IsA("Motor6D")then joints[part.Name=="Root"and"RootJoint"or part.Name]=part end end
local phase=0;local connection
connection=game:GetService("RunService").PreSimulation:Connect(function(dt)
 if not model.Parent then connection:Disconnect();return end
 local now=workspace:GetServerTimeNow();local root=model:FindFirstChild("HumanoidRootPart");local h=model:FindFirstChildOfClass("Humanoid")
 if not root or not h then return end
 local velocity=root.AssemblyLinearVelocity;local speed=Vector3.new(velocity.X,0,velocity.Z).Magnitude
 local state=h.Health<=0 and"death"or h.FloorMaterial==Enum.Material.Air and not root.Anchored and"fall"or speed>18 and"run"or speed>.7 and"walk"or"idle"
 if (model:GetAttribute("DemoUntil")or 0)>now then state=model:GetAttribute("DemoState")or state end
 phase=phase+dt*(state=="run"and 9 or state=="walk"and 6 or 2)
 local action=model:GetAttribute("Action")or"";local elapsed=now-(model:GetAttribute("ActionAt")or -100)
 local pose=Motion.sample(state,phase,speed,action,elapsed,{stateTime=0})
 for name,joint in pairs(joints)do local v=pose[name]
  if v then
   local target=CFrame.new(v[4],v[5],v[6])*CFrame.Angles(v[1],v[2],v[3])
   joint.Transform=(Motion.durations[action] and elapsed>=0 and elapsed<Motion.durations[action])and target or joint.Transform:Lerp(target,1-math.exp(-dt*19))
  end
 end
 Renderer.update(model,action,elapsed)
end)
