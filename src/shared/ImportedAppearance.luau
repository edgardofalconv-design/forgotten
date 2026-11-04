-- Optional imported mesh templates. Missing templates keep the existing appearance.
-- Studio installer: tools/InstallReferenceCharacter.luau. No external asset IDs guessed.
local Imported={}
local targets={Head="Head_mesh",Torso="Torso_mesh",LeftArm="LeftArm_mesh",RightArm="RightArm_mesh",LeftLeg="LeftLeg_mesh",RightLeg="RightLeg_mesh"}
function Imported.apply(character,id,anchored)
 local templates=game:GetService("ServerStorage"):FindFirstChild("ReferenceCharacters")
 local template=templates and templates:FindFirstChild(id)
 -- Older "yellowguy" mesh exports were robots. They must never replace the classic avatar.
 if id=="yellowguy" and template and template:GetAttribute("CharacterIdentity")~="yellowguy" then return false end
 if not template or template:GetAttribute("ReferenceFormat")~=1 then return false end
 local h=character:FindFirstChildOfClass("Humanoid")
 if h and h.RigType~=Enum.HumanoidRigType.R6 then return false end
 local bindings={}
 local meshPrefix=template:GetAttribute("ReferenceMeshPrefix") or id
 for name,meshName in pairs(targets) do
  local source=template:FindFirstChild(meshPrefix.."__"..meshName,true) or template:FindFirstChild(meshName,true)
  local target=character:FindFirstChild(name) or character:FindFirstChild(name:gsub("Left","Left "):gsub("Right","Right "))
  if source then
   if not source:IsA("BasePart") or not target or not target:IsA("BasePart") then return false end
   table.insert(bindings,{source=source,target=target})
  else return false end
 end
 local scale=template:GetAttribute("ReferenceScale") or 1
 if typeof(scale)~="number" or scale<=0 or scale>10 then return false end
 local old=character:FindFirstChild("ForgottenAppearance");if old then old:Destroy() end
 local folder=Instance.new("Folder");folder.Name="ForgottenAppearance";folder.Parent=character
 for _,body in ipairs(character:GetChildren()) do
  if body:IsA("BasePart") and body.Name~="HumanoidRootPart" then body.Transparency=1 end
 end
 for _,b in ipairs(bindings) do
  local piece=b.source:Clone()
  local offset=b.source:GetPivot():ToObjectSpace(b.source.CFrame)
  piece.Size=piece.Size*scale
  piece.CFrame=b.target.CFrame*CFrame.new(offset.Position*scale)*offset.Rotation
  piece.Anchored=anchored;piece.CanCollide=false;piece.CanTouch=false;piece.Massless=true;piece.Parent=folder
  if not anchored then local weld=Instance.new("WeldConstraint");weld.Part0=b.target;weld.Part1=piece;weld.Parent=piece end
 end
 return true
end
return Imported
