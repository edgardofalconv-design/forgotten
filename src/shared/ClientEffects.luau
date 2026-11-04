local Debris=game:GetService("Debris")
local TweenService=game:GetService("TweenService")
local SoundService=game:GetService("SoundService")
local Music=require(script.Parent.Music)
return function(enabled)
 local folder=Instance.new("Folder");folder.Name="EfectosLocalesForgotten";folder.Parent=workspace
 local function sound(key)
  local id=Music.sfx and Music.sfx[key]
  if type(id)~="string" or not id:match("^rbxassetid://%d+$") then return end
  local s=Instance.new("Sound");s.SoundId=id;s.Volume=.3;s.Parent=SoundService;s:Play();Debris:AddItem(s,8)
 end
 local function effect(data)
  if not enabled() or #folder:GetChildren()>24 then return end
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
