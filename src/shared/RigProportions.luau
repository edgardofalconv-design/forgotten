-- Applies only to the project's own generated R6 avatars, never installed rigs.
local Profiles=require(script.Parent.RigProfileData)
local Proportions={}
function Proportions.apply(model,id)
 local profile=Profiles[id];local h=model:FindFirstChildOfClass("Humanoid")
 local torso=model:FindFirstChild("Torso")
 if not profile or not h or h.RigType~=Enum.HumanoidRigType.R6 or not torso then return end
 local function vec(a)return Vector3.new(a[1],a[2],a[3])end
 torso.Size=vec(profile.torso)
 for _,side in ipairs({-1,1}) do
  local prefix=side<0 and "Left" or "Right"
  local arm=model:FindFirstChild(prefix.." Arm");local leg=model:FindFirstChild(prefix.." Leg")
  if arm then arm.Size=vec(profile.arm);arm.CFrame=torso.CFrame*CFrame.new(side*profile.armX,0,0) end
  if leg then leg.Size=vec(profile.leg);leg.CFrame=torso.CFrame*CFrame.new(side*profile.legX,-2,0) end
  local shoulder=torso:FindFirstChild(prefix.." Shoulder")
  if shoulder then
   shoulder.C0=CFrame.new(side*profile.torso[1]/2,.5,0)*shoulder.C0.Rotation
   shoulder.C1=CFrame.new(-side*profile.arm[1]/2,.5,0)*shoulder.C1.Rotation
  end
  local hip=torso:FindFirstChild(prefix.." Hip")
  if hip then hip.C0=CFrame.new(side*profile.legX,-1,0)*hip.C0.Rotation end
 end
 model:SetAttribute("RigProportionsVersion",4)
end
return Proportions
