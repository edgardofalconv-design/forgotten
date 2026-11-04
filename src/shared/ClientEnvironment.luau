-- Local lighting profiles: players in the lobby retain its warm refuge lighting.
local Environment={}
local styles={
 disaster_island={hour=5.1,exposure=.2,fog=.26,tint={214,230,237}},
 pizza_place={hour=.7,exposure=.25,fog=.17,tint={255,223,191}},
 forgotten_heights={hour=4.7,exposure=.2,fog=.24,tint={201,222,244}},
 research_facility={hour=1,exposure=.28,fog=.16,tint={210,243,232}},
 cursed_manor={hour=.2,exposure=.19,fog=.25,tint={233,217,236}},
 forgotten_robloxia={hour=5,exposure=.2,fog=.23,tint={224,232,213}},
 junkbot_factory={hour=1,exposure=.26,fog=.2,tint={240,224,191}},
 corrupted_arcade={hour=0,exposure=.22,fog=.16,tint={221,210,249}},
 ballers_arena={hour=4.9,exposure=.26,fog=.18,tint={239,226,208}}}
local lobby={hour=.5,exposure=.2,fog=.22,tint={255,237,211}}
function Environment.start()
 local Lighting=game:GetService("Lighting");local Tween=game:GetService("TweenService");local current
 local function update(state,inRound)
  local key=inRound and state.phase=="Ronda" and state.mapId or "lobby"
  if key==current then return end;current=key
  local profile=styles[key] or lobby
  Tween:Create(Lighting,TweenInfo.new(1.2),{ClockTime=profile.hour,ExposureCompensation=profile.exposure}):Play()
  local atmosphere=Lighting:FindFirstChild("ForgottenAtmosphere")
  if atmosphere then Tween:Create(atmosphere,TweenInfo.new(1.2),{Density=profile.fog}):Play() end
  local grade=Lighting:FindFirstChild("ForgottenGrade")
  if grade then Tween:Create(grade,TweenInfo.new(1.2),{TintColor=Color3.fromRGB(profile.tint[1],profile.tint[2],profile.tint[3]),Contrast=.13,Saturation=-.07}):Play() end
 end
 return update
end
return Environment
