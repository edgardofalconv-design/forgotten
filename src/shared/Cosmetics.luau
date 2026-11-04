-- Provisional milestone geometry, replaceable without touching ownership or gameplay.
local Cosmetics={}
function Cosmetics.apply(model,character,equipment)
 local old=model:FindFirstChild("ForgottenCosmetics");if old then old:Destroy() end
 local folder=Instance.new("Folder");folder.Name="ForgottenCosmetics";folder.Parent=model
 equipment=equipment or {}
 local tier=tonumber(type(equipment.skin)=="string" and equipment.skin:match(":m([1-4])$") or nil) or 0
 local torso=model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
 local head=model:FindFirstChild("Head")
 if not torso or not head then return end
 local colors={Color3.fromRGB(156,109,56),Color3.fromRGB(154,173,188),Color3.fromRGB(195,60,65),Color3.fromRGB(222,190,97)}
 local color=colors[math.max(1,tier)]
 local function piece(name,anchor,size,offset,tint,neon)
  local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=anchor.CFrame*CFrame.new(offset)
  p.Color=tint;p.Material=neon and Enum.Material.Neon or Enum.Material.Metal
  p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Massless=true;p.Parent=folder
  local w=Instance.new("WeldConstraint");w.Part0=anchor;w.Part1=p;w.Parent=p
  return p
 end
 if tier>0 then
  piece("Insignia Milestone "..tier,torso,Vector3.new(.24,.32,.06),Vector3.new(-.55,.3,-torso.Size.Z/2-.06),color)
  for _,side in ipairs({-1,1}) do
   local arm=model:FindFirstChild(side<0 and "LeftUpperArm" or "RightUpperArm") or model:FindFirstChild(side<0 and "Left Arm" or "Right Arm")
   if arm then piece("Brazalete de maestría",arm,Vector3.new(arm.Size.X*1.05,.13,arm.Size.Z*1.06),Vector3.new(0,-.12,0),color,tier==4) end
  end
 end
 if tier>=2 then
  piece("Placa de veterano",torso,Vector3.new(.48,.18,.07),Vector3.new(.5,-.35,-torso.Size.Z/2-.07),color)
 end
 if tier>=3 and character=="guest666" then
  -- No cape. Monstrous details begin at M3 only.
  for _,side in ipairs({-1,1}) do
   local arm=model:FindFirstChild(side<0 and "LeftLowerArm" or "RightLowerArm") or model:FindFirstChild(side<0 and "Left Arm" or "Right Arm")
   if arm then for n=-1,1 do piece("Garra maldita",arm,Vector3.new(.11,.45,.12),Vector3.new(n*.22,-arm.Size.Y/2-.18,-.2),Color3.fromRGB(122,26,36),tier==4) end end
  end
  for i=-2,2 do piece("Diente espectral",head,Vector3.new(.07,.15,.05),Vector3.new(i*.12,-.3,-head.Size.Z/2-.04),Color3.fromRGB(192,171,153)) end
 elseif tier>=3 then
  piece("Emblema de supervivencia",torso,Vector3.new(.34,.42,.07),Vector3.new(0,.23,-torso.Size.Z/2-.08),color,tier==4)
 end
 if tier==4 then
  local light=Instance.new("PointLight");light.Color=color;light.Brightness=.45;light.Range=5;light.Parent=torso
  light.Name="MilestoneGlow";light.Parent=folder:FindFirstChild("Insignia Milestone 4") or torso
 end
 local accessory=equipment.cosmetic
 if accessory=="cosmetic:scarf" then
  piece("Bufanda",torso,Vector3.new(torso.Size.X*1.04,.22,torso.Size.Z*1.06),Vector3.new(0,torso.Size.Y/2-.12,0),Color3.fromRGB(120,58,50))
 elseif accessory=="cosmetic:lantern" then
  local lamp=piece("Linterna",torso,Vector3.new(.3,.55,.3),Vector3.new(torso.Size.X/2+.22,-.7,0),Color3.fromRGB(224,183,89),true)
  local l=Instance.new("PointLight");l.Range=7;l.Brightness=.4;l.Color=lamp.Color;l.Parent=lamp
 elseif accessory=="cosmetic:badge" then
  piece("Insignia del refugio",torso,Vector3.new(.35,.35,.06),Vector3.new(.55,.35,-torso.Size.Z/2-.06),Color3.fromRGB(181,151,73))
 elseif accessory=="cosmetic:radio" then
  piece("Radio",torso,Vector3.new(.4,.6,.2),Vector3.new(.55,.05,-torso.Size.Z/2-.18),Color3.fromRGB(40,53,48))
 end
 model:SetAttribute("Milestone",tier)
end
return Cosmetics
