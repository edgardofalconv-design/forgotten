-- Shared appearance for the playable rig, lobby NPC and preview. Actual MeshParts.
-- No visual Part/Wedge fallback: unavailable mesh APIs produce an explicit notice.
local Assets=game:GetService("AssetService")
local RS=game:GetService("ReplicatedStorage")
local Data=require(script.Parent.PelotocinoMeshData)
local Surface=require(script.Parent.PelotocinoSurface)
local Motion=require(script.Parent.PelotocinoMotion)
local Renderer={};local cache={};local inFlight={};local states=setmetatable({},{__mode="k"});local reveal
local function vec(v)return Vector3.new(v[1],v[2],v[3])end
local function bounds(spec)
 local lo,hi=Vector3.new(math.huge,math.huge,math.huge),Vector3.new(-math.huge,-math.huge,-math.huge)
 for _,v in ipairs(spec.vertices)do local p=vec(v);lo=Vector3.new(math.min(lo.X,p.X),math.min(lo.Y,p.Y),math.min(lo.Z,p.Z));hi=Vector3.new(math.max(hi.X,p.X),math.max(hi.Y,p.Y),math.max(hi.Z,p.Z)) end
 return (lo+hi)/2,Vector3.new(math.max(.002,hi.X-lo.X),math.max(.002,hi.Y-lo.Y),math.max(.002,hi.Z-lo.Z))
end
local function template(index)
 if cache[index]then return cache[index]end
 while inFlight[index]do task.wait()end
 if cache[index]then return cache[index]end
 inFlight[index]=true
 local spec=Data.meshes[index];local center,size=bounds(spec);local editable
 local ok,result=pcall(function()
  local imported=RS:FindFirstChild("PelotocinoImportedMeshes")
  local source=imported and imported:FindFirstChild(spec.name,true)
  local part
  if source and source:IsA("MeshPart")then part=source:Clone();part.Size=size
  else
   editable=Assets:CreateEditableMesh();assert(editable,"No hay memoria para la malla")
   local vertices,normals,colors,uvs={},{},{},{}
   for i,v in ipairs(spec.vertices)do
    vertices[i]=editable:AddVertex(vec(v)-center)
    uvs[i]=editable:AddUV(Vector2.new(.5+v[1]*.32,.5+v[2]*.32))
    normals[i]=editable:AddNormal(vec(spec.normals[i]))
    local c=spec.colors[i];colors[i]=editable:AddColor(Color3.fromRGB(c[1],c[2],c[3]),1)
   end
   for _,face in ipairs(spec.faces)do
    local a,b,c=face[1]+1,face[2]+1,face[3]+1
    local f=editable:AddTriangle(vertices[a],vertices[b],vertices[c]);editable:SetFaceNormals(f,{normals[a],normals[b],normals[c]});editable:SetFaceColors(f,{colors[a],colors[b],colors[c]});editable:SetFaceUVs(f,{uvs[a],uvs[b],uvs[c]})
   end
   part=Assets:CreateMeshPartAsync(Content.fromObject(editable),{CollisionFidelity=Enum.CollisionFidelity.Box})
   part.Size=size;part.Color=Color3.new(1,1,1);part.Material=Enum.Material[spec.material]
   if spec.material=="Fabric"then Surface.apply(part,spec.group=="backpack")end
   if spec.group=="hair"or spec.group=="tuft"then Surface.applyHair(part)end
  end
  part.Name=spec.name;part.Anchored=false;part.CanCollide=false;part.CanTouch=false;part.CanQuery=false;part.Massless=true;part.DoubleSided=true
  return {part=part,center=center,editable=editable}
 end)
 inFlight[index]=nil
 if not ok then if editable then editable:Destroy()end;error(result)end
 cache[index]=result;return result
end
local function notice(model,message)
 local head=model:FindFirstChild("Head");if not head then return end
 local gui=Instance.new("BillboardGui");gui.Name="PelotocinoMeshNotice";gui.Size=UDim2.fromOffset(260,74);gui.StudsOffset=Vector3.new(0,2,0);gui.AlwaysOnTop=true;gui.Parent=head
 local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundColor3=Color3.fromRGB(23,28,35);text.BackgroundTransparency=.15;text.TextColor3=Color3.fromRGB(255,210,150);text.TextSize=13;text.TextWrapped=true;text.Text=message;text.Parent=gui
end
function Renderer.apply(model)
 if not model:GetAttribute("PelotocinoR15")or states[model]then return end
 local old=model:FindFirstChild("PelotocinoMeshAppearance");if old then old:Destroy()end
 local state={parts={},loading=true};states[model]=state
 local folder=Instance.new("Folder");folder.Name="PelotocinoMeshAppearance";folder.Parent=model;state.folder=folder
 local ok,problem=pcall(function()
  for index,spec in ipairs(Data.meshes)do
   local source=template(index);if not model.Parent then return end
   local anchor=model:FindFirstChild(spec.anchor);assert(anchor,"Falta hueso R15: "..spec.anchor)
   local part=source.part:Clone();part.CFrame=anchor.CFrame*CFrame.new(source.center);part.Parent=folder
   local motor=Instance.new("Motor6D");motor.Name="MeshMount_"..index;motor.Part0=anchor;motor.Part1=part;motor.C0=CFrame.new(source.center);motor.Parent=part
   table.insert(state.parts,{part=part,motor=motor,center=source.center,spec=spec})
  end
 end)
 state.loading=false
 if not ok then
  folder:Destroy();state.failed=true
  model:SetAttribute("PelotocinoVisualReady",false)
  notice(model,"PELOTOCINO · MALLAS NO DISPONIBLES\nActiva Mesh & Image APIs o instala el FBX incluido.")
  warn("Pelotocino R15: no se reemplaza por cubos. "..tostring(problem));return
 end
 if not model.Parent then return end
 local labelHost=model.LeftHand
 local oldReadout=labelHost:FindFirstChild("TrackerReadout");if oldReadout then oldReadout:Destroy()end
 local oldNotice=model.Head:FindFirstChild("PelotocinoMeshNotice");if oldNotice then oldNotice:Destroy()end
 local gui=Instance.new("BillboardGui");gui.Name="TrackerReadout";gui.Size=UDim2.fromOffset(110,28);gui.StudsOffset=Vector3.new(0,.4,0);gui.AlwaysOnTop=false;gui.Enabled=false;gui.Parent=labelHost
 local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundColor3=Color3.fromRGB(8,21,14);text.BackgroundTransparency=.12;text.TextColor3=Color3.fromRGB(136,231,157);text.TextSize=11;text.Text="SIN SEÑAL";text.Parent=gui
 state.readout=gui;state.readoutText=text;model:SetAttribute("PelotocinoVisualReady",true)
 -- Viewport clones also start with equipment stowed, before their first animation tick.
 Renderer.update(model,"",100)
end
function Renderer.setReveal(data)
 reveal={models=data.models or {},untilTime=os.clock()+math.min(data.duration or 6,10)}
end
local function mount(item,anchor,frame)
 item.motor.Part0=anchor;item.motor.C0=frame*CFrame.new(item.center)
end
function Renderer.update(model,action,elapsed)
 local state=states[model];if not state or state.loading or state.failed then return end
 local pose=Motion.equipment(action,elapsed)
 for _,item in ipairs(state.parts)do
  local spec=item.spec
  if spec.group=="pan"then
   mount(item,pose.pan and model.RightHand or model.UpperTorso,pose.pan and CFrame.new(0,-.08,0)or CFrame.new(.65,-.25,.93)*CFrame.Angles(0,.2,-.22))
  elseif spec.group=="tracker"then
   mount(item,pose.tracker and model.LeftHand or model.UpperTorso,pose.tracker and CFrame.new(0,-.10,-.16)*CFrame.Angles(.1,0,0)or CFrame.new(-.69,-.28,.36))
  elseif spec.group=="tuft"then
   item.part.Transparency=pose.tuftRemoved and 1 or 0
   if pose.tuftInHand then
    item.part.Transparency=0;mount(item,model.LeftHand,CFrame.new(0,-.08,-.16)*CFrame.Angles(0,0,.2)*CFrame.new(.15,-.4,.2))
   elseif pose.tuftTossed then
    item.part.Transparency=0
    local f=math.clamp((elapsed-.36)/.09,0,1)
    local from=model.LeftHand.CFrame*CFrame.new(0,-.08,-.16)
    local to=model.RightHand.CFrame*CFrame.new(0,-.82,-.15)
    mount(item,model.HumanoidRootPart,model.HumanoidRootPart.CFrame:ToObjectSpace(from:Lerp(to,f))*CFrame.new(.15,-.4,.2))
   else mount(item,model.Head,CFrame.new())end
  end
 end
 if state.readout then
  state.readout.Enabled=pose.tracker
  local detected=(model:GetAttribute("TrackerUntil")or 0)>workspace:GetServerTimeNow()and(model:GetAttribute("TrackerCount")or 0)>0
  local text=detected and "● SEÑAL DETECTADA"or "SIN SEÑAL"
  local player=game:GetService("Players").LocalPlayer
  if player and player.Character==model and reveal and os.clock()<reveal.untilTime then
   local root=model.HumanoidRootPart;local nearest,distance
   for _,target in ipairs(reveal.models)do local r=target and target:FindFirstChild("HumanoidRootPart")
    if r and target.Parent then local d=(r.Position-root.Position).Magnitude;if not distance or d<distance then nearest,distance=r,d end end
   end
   if nearest and distance<=100 then
    local d=root.CFrame:VectorToObjectSpace(nearest.Position-root.Position)
    text=(math.abs(d.X)>math.abs(d.Z)and(d.X>0 and "→ DERECHA"or"← IZQUIERDA")or(d.Z<0 and "↑ DELANTE"or"↓ DETRÁS")).." · SEÑAL"
   end
  end
  for _,item in ipairs(state.parts)do if item.spec.group=="tracker"and item.spec.material=="Neon"then
   local intensity=detected and (.85+.15*math.sin(os.clock()*9))or .3;item.part.Color=Color3.new(intensity,intensity,intensity)
  end end
  state.readoutText.Text=text
  state.readoutText.TextColor3=detected and Color3.fromRGB(135,255,151)or Color3.fromRGB(160,174,159)
 end
end
function Renderer.projectile(parent)
 local model=Instance.new("Model");model.Name="BaconTuftProjectile"
 for index,spec in ipairs(Data.meshes)do if spec.group=="tuft"then
  local source=template(index);local part=source.part:Clone();part.Anchored=true;part.CFrame=CFrame.new();part.Parent=model;model.PrimaryPart=part;break
 end end
 model.Parent=parent;return model
end
function Renderer.start()
 local collection=game:GetService("CollectionService")
 local function add(model)if model:GetAttribute("PelotocinoR15")then task.defer(function()Renderer.apply(model)end)end end
 collection:GetInstanceAddedSignal("ForgottenAnimated"):Connect(add)
 for _,m in ipairs(collection:GetTagged("ForgottenAnimated"))do add(m)end
end
return Renderer
