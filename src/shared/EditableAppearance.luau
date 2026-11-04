-- Optional client-side consolidation of the same authored surfaces into MeshParts.
-- EditableMesh permissions vary by experience. The portable geometry remains on failure.
local Assets=game:GetService("AssetService")
local Data=require(script.Parent.CharacterVisualData)
local Visuals=require(script.Parent.CharacterVisuals)
local Renderer={}
local cache={};local waiting={};local disabled=false
local function vector(v)return Vector3.new(v[1],v[2],v[3])end
local function template(id,index,spec)
 local key=id..":"..index
 if cache[key] then return cache[key] end
 if disabled or waiting[key] then return nil end
 waiting[key]=true
 local editable
 local ok,result=pcall(function()
  editable=Assets:CreateEditableMesh();assert(editable,"Presupuesto de malla no disponible")
  local lo=Vector3.new(math.huge,math.huge,math.huge);local hi=-lo
  for _,v in ipairs(spec.vertices) do
   local p=vector(v);lo=Vector3.new(math.min(lo.X,p.X),math.min(lo.Y,p.Y),math.min(lo.Z,p.Z));hi=Vector3.new(math.max(hi.X,p.X),math.max(hi.Y,p.Y),math.max(hi.Z,p.Z))
  end
  local center=(lo+hi)/2;local ids={}
  for i,v in ipairs(spec.vertices) do ids[i]=editable:AddVertex(vector(v)-center) end
  for _,face in ipairs(spec.faces) do editable:AddTriangle(ids[face[1]+1],ids[face[2]+1],ids[face[3]+1]) end
  local part=Assets:CreateMeshPartAsync(Content.fromObject(editable),{CollisionFidelity=Enum.CollisionFidelity.Box})
  part.Size=Vector3.new(math.max(.012,hi.X-lo.X),math.max(.012,hi.Y-lo.Y),math.max(.012,hi.Z-lo.Z))
  part.Name=spec.name.."_Mesh";part.Color=Color3.fromRGB(spec.color[1],spec.color[2],spec.color[3]);part.Material=Enum.Material[spec.material]
  part.CanCollide=false;part.CanTouch=false;part.CanQuery=false;part.Massless=true;part.DoubleSided=true
  return {part=part,center=center,editable=editable}
 end)
 waiting[key]=nil
 if not ok then
  if editable then editable:Destroy() end
  disabled=true;warn("FORGOTTEN V3: se conserva la geometría portátil; EditableMesh no está disponible en esta experiencia.")
  return nil
 end
 cache[key]=result;return result
end
function Renderer.apply(model)
 if disabled or (model:GetAttribute("VisualVersion") or 0)<3 or model:FindFirstChild("ClientVisualMeshes") then return end
 local id=model:GetAttribute("CharacterIdentity");local source=Data[id]
 local original=model:FindFirstChild("ForgottenAppearance")
 if not source or not original then return end
 local folder=Instance.new("Folder");folder.Name="ClientVisualMeshes";folder.Parent=model
 for index,spec in ipairs(source) do
  if spec.kind=="Mesh" then
   local group
   for _,candidate in ipairs(original:GetChildren()) do if candidate:GetAttribute("VisualSpecIndex")==index then group=candidate;break end end
   local anchor=Visuals.anchor(model,spec.anchor,spec.name)
   if group and anchor then
    local built=template(id,index,spec)
    if built and model.Parent and folder.Parent and group.Parent then
     local part=built.part:Clone();part.CFrame=anchor.CFrame*CFrame.new(built.center)
     part:SetAttribute("WeaponKind",group:GetAttribute("WeaponKind"));part.Parent=folder
     local weld=Instance.new("WeldConstraint");weld.Part0=anchor;weld.Part1=part;weld.Parent=part
     for _,piece in ipairs(group:GetChildren()) do if piece:IsA("BasePart") then piece:SetAttribute("MeshReplaced",true);piece.LocalTransparencyModifier=1 end end
    end
   end
  end
 end
end
function Renderer.start()
 local Collection=game:GetService("CollectionService")
 local function apply(model)task.defer(function()if model.Parent then Renderer.apply(model) end end)end
 Collection:GetInstanceAddedSignal("ForgottenAnimated"):Connect(apply)
 for _,model in ipairs(Collection:GetTagged("ForgottenAnimated")) do apply(model) end
end
return Renderer
