-- Persistent, pre-imported MeshParts only. No runtime asset creation or uploads.
local RS=game:GetService("ReplicatedStorage")
local Data=require(script.Parent.PelotocinoMeshData)
local Library={}
local function vec(v)return Vector3.new(v[1],v[2],v[3])end
function Library.bounds(spec)
 local lo,hi=Vector3.new(math.huge,math.huge,math.huge),Vector3.new(-math.huge,-math.huge,-math.huge)
 for _,v in ipairs(spec.vertices)do local p=vec(v)
  lo=Vector3.new(math.min(lo.X,p.X),math.min(lo.Y,p.Y),math.min(lo.Z,p.Z))
  hi=Vector3.new(math.max(hi.X,p.X),math.max(hi.Y,p.Y),math.max(hi.Z,p.Z))
 end
 return (lo+hi)/2,Vector3.new(math.max(.002,hi.X-lo.X),math.max(.002,hi.Y-lo.Y),math.max(.002,hi.Z-lo.Z))
end
local function persistent(id)
 if type(id)~="string"then return false end
 local number=id:match("^rbxassetid://(%d+)$")or id:match("^https://www%.roblox%.com/asset/%?id=(%d+)$")
 return number~=nil and tonumber(number)>0
end
function Library.hasTexture(part)
 local surface=part:FindFirstChildOfClass("SurfaceAppearance")
 return persistent(part.TextureID)or(surface and persistent(surface.ColorMap))or false
end
function Library.inspect(container,requireTexture)
 local found,errors,expected={},{},{}
 for _,spec in ipairs(Data.meshes)do expected[spec.name]=true end
 if not container then return found,{"Falta ReplicatedStorage.PelotocinoImportedMeshes; importa el FBX e instala en modo edición."}end
 local list=container:GetDescendants();if container:IsA("MeshPart")then table.insert(list,container)end
 for _,part in ipairs(list)do if part:IsA("MeshPart")then
  if not expected[part.Name]then table.insert(errors,"Malla inesperada: "..part.Name)
  elseif found[part.Name]then table.insert(errors,"Nombre duplicado: "..part.Name)
  else found[part.Name]=part end
 end end
 for _,spec in ipairs(Data.meshes)do
  local part=found[spec.name]
  if not part then table.insert(errors,"Falta: "..spec.name)
  elseif not persistent(part.MeshId)then table.insert(errors,"MeshId sin publicar: "..spec.name)
  elseif requireTexture and not Library.hasTexture(part)then table.insert(errors,"Textura sin importar: "..spec.name)end
 end
 return found,errors
end
function Library.template(index,container)
 local spec=Data.meshes[index]
 local bank=container or RS:FindFirstChild("PelotocinoImportedMeshes")
 local part=bank and bank:FindFirstChild(spec.name,true)
 assert(part and part:IsA("MeshPart")and persistent(part.MeshId),"Importa e instala la MeshPart: "..spec.name)
 local center,size=Library.bounds(spec)
 return {part=part,center=center,size=size}
end
function Library.restMount(model,spec)
 if spec.group=="pan"then return model.UpperTorso,CFrame.new(.65,-.25,.93)*CFrame.Angles(0,.2,-.22)
 elseif spec.group=="tracker"then return model.UpperTorso,CFrame.new(-.69,-.28,.36)end
 return model[spec.anchor],CFrame.new()
end
function Library.attach(model,container)
 local existing=model:FindFirstChild("PelotocinoMeshAppearance")
 if existing then
  local found,errors=Library.inspect(existing,true);local parts={}
  if #errors==0 then
   for index,spec in ipairs(Data.meshes)do
    local part=found[spec.name];local motor=part:FindFirstChild("MeshMount_"..index)
    if not motor or not motor:IsA("Motor6D")or motor.Part1~=part or not motor.Part0 or model:FindFirstChild(motor.Part0.Name)~=motor.Part0 then table.insert(errors,"Montaje incompleto: "..spec.name);break end
    local center=Library.bounds(spec);table.insert(parts,{part=part,motor=motor,center=center,spec=spec})
   end
   if #errors==0 then return {parts=parts,folder=existing}end
  end
 end
 local bank=container or RS:FindFirstChild("PelotocinoImportedMeshes")
 local found,errors=Library.inspect(bank,true)
 for _,spec in ipairs(Data.meshes)do if not model:FindFirstChild(spec.anchor)then table.insert(errors,"Falta hueso R15: "..spec.anchor)end end
 assert(#errors==0,table.concat(errors,"\n"))
 local folder=Instance.new("Folder");folder.Name="PelotocinoMeshAppearance"
 local state={parts={},folder=folder}
 local ok,problem=pcall(function()
  for index,spec in ipairs(Data.meshes)do
   local part=found[spec.name]:Clone();local center,size=Library.bounds(spec)
   for _,child in ipairs(part:GetChildren())do if not child:IsA("SurfaceAppearance")then child:Destroy()end end
   part.Size=size;part.PivotOffset=CFrame.new();part.Color=Color3.new(1,1,1);part.Material=Enum.Material[spec.material]
   part.Transparency=0;part.Anchored=false;part.CanCollide=false;part.CanTouch=false;part.CanQuery=false;part.Massless=true;part.DoubleSided=true
   local anchor,offset=Library.restMount(model,spec)
   part.CFrame=anchor.CFrame*offset*CFrame.new(center);part.Parent=folder
   local motor=Instance.new("Motor6D");motor.Name="MeshMount_"..index;motor.Part0=anchor;motor.Part1=part;motor.C0=offset*CFrame.new(center);motor.Parent=part
   table.insert(state.parts,{part=part,motor=motor,center=center,spec=spec})
  end
 end)
 if not ok then folder:Destroy();error(problem)end
 if existing then existing:Destroy()end
 folder.Parent=model;model:SetAttribute("PelotocinoImported",true)
 return state
end
return Library
