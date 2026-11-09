-- Pre-imported MeshParts shared by playable character, NPC and preview.
-- EditableMesh/EditableImage are not used by Pelotocino during play.
local Data=require(script.Parent.PelotocinoMeshData)
local Library=require(script.Parent.PelotocinoMeshLibrary)
local Motion=require(script.Parent.PelotocinoMotion)
local Renderer={};local states=setmetatable({},{__mode="k"});local reveal
local function notice(model,message)
 local head=model:FindFirstChild("Head");if not head then return end
 local gui=Instance.new("BillboardGui");gui.Name="PelotocinoMeshNotice";gui.Size=UDim2.fromOffset(260,74);gui.StudsOffset=Vector3.new(0,2,0);gui.AlwaysOnTop=true;gui.Parent=head
 local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundColor3=Color3.fromRGB(23,28,35);text.BackgroundTransparency=.15;text.TextColor3=Color3.fromRGB(255,210,150);text.TextSize=13;text.TextWrapped=true;text.Text=message;text.Parent=gui
end
function Renderer.apply(model)
 if not model:GetAttribute("PelotocinoR15")then return false end
 local previous=states[model]
 if previous and not previous.failed then return true end
 local ok,state=pcall(Library.attach,model)
 if not ok then
  local problem=tostring(state)
  if not previous or previous.problem~=problem then
   local head=model:FindFirstChild("Head");local old=head and head:FindFirstChild("PelotocinoMeshNotice");if old then old:Destroy()end
   notice(model,"PELOTOCINO · IMPORTACIÓN PENDIENTE\nImporta el FBX y ejecuta el instalador en modo edición.")
   warn("Pelotocino: "..problem)
  end
  states[model]={failed=true,problem=problem,nextRetry=os.clock()+1}
  model:SetAttribute("PelotocinoVisualReady",false);model:SetAttribute("PelotocinoSetupError",problem)
  return false
 end
 states[model]=state;model:SetAttribute("PelotocinoSetupError",nil)
 if not model.Parent then return end
 local labelHost=model.LeftHand
 local oldReadout=labelHost:FindFirstChild("TrackerReadout");if oldReadout then oldReadout:Destroy()end
 local oldNotice=model.Head:FindFirstChild("PelotocinoMeshNotice");if oldNotice then oldNotice:Destroy()end
 local gui=Instance.new("BillboardGui");gui.Name="TrackerReadout";gui.Size=UDim2.fromOffset(110,28);gui.StudsOffset=Vector3.new(0,.4,0);gui.AlwaysOnTop=false;gui.Enabled=false;gui.Parent=labelHost
 local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundColor3=Color3.fromRGB(8,21,14);text.BackgroundTransparency=.12;text.TextColor3=Color3.fromRGB(136,231,157);text.TextSize=11;text.Text="SIN SEÑAL";text.Parent=gui
 state.readout=gui;state.readoutText=text;model:SetAttribute("PelotocinoVisualReady",true)
 -- Viewport clones also start with equipment stowed, before their first animation tick.
 Renderer.update(model,"",100)
 return true
end
function Renderer.setReveal(data)
 reveal={models=data.models or {},untilTime=os.clock()+math.min(data.duration or 6,10)}
end
local function mount(item,anchor,frame)
 item.motor.Part0=anchor;item.motor.C0=frame*CFrame.new(item.center)
end
function Renderer.update(model,action,elapsed)
 local state=states[model];if not state then return end
 if state.failed then if os.clock()>=(state.nextRetry or 0)then Renderer.apply(model)end;return end
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
  local source=Library.template(index);local part=source.part:Clone();part.Size=source.size;part.Transparency=0;part.CanCollide=false;part.CanTouch=false;part.CanQuery=false;part.Anchored=true;part.CFrame=CFrame.new();part.Parent=model;model.PrimaryPart=part;break
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
