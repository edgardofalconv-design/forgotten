-- Generator presentation only. Objective ownership and minigame rules stay server-side.
local Generator={}
local gray=Color3.fromRGB(72,83,87)
local steel=Color3.fromRGB(130,140,139)
local amber=Color3.fromRGB(194,145,56)
function Generator.build(parent,position,World,id)
 local model=Instance.new("Model");model.Name="GeneradorDetallado_"..id;model.Parent=parent
 local base=World.part(model,"Generador "..id,Vector3.new(5,4,3),position+Vector3.new(0,2,0),gray)
 base.Transparency=1
 local function part(name,size,offset,tint,shape,rotation)
  local p=World.part(model,name,size,position+offset,tint or gray,Enum.Material.Metal)
  p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=size.Magnitude>1
  if shape then p.Shape=shape end
  if rotation then p.CFrame=p.CFrame*rotation end
  return p
 end
 part("Bancada",Vector3.new(5,.35,3.2),Vector3.new(0,.35,0),gray)
 for _,x in ipairs({-2.15,2.15}) do
  for _,z in ipairs({-1.25,1.25}) do
   part("Soporte tubular",Vector3.new(3.2,.16,.16),Vector3.new(x,1.9,z),steel,Enum.PartType.Cylinder,CFrame.Angles(0,0,math.pi/2))
   part("Aislador de goma",Vector3.new(.5,.35,.5),Vector3.new(x,.1,z),Color3.fromRGB(27,29,29))
  end
  part("Asa superior",Vector3.new(2.5,.16,.16),Vector3.new(x,3.5,0),steel,Enum.PartType.Cylinder,CFrame.Angles(0,math.pi/2,0))
 end
 part("Motor fundido",Vector3.new(2.9,1.65,1.65),Vector3.new(-.4,1.45,0),gray,Enum.PartType.Cylinder)
 for i=1,6 do part("Aleta de refrigeración",Vector3.new(.08,1.85,1.85),Vector3.new(-1.7+i*.38,1.45,0),steel,Enum.PartType.Cylinder) end
 local rotor=part("Rotor",Vector3.new(.25,1.45,1.45),Vector3.new(1.3,1.45,0),amber,Enum.PartType.Cylinder)
 part("Depósito combustible",Vector3.new(2.8,1,1.2),Vector3.new(-.4,2.9,.2),Color3.fromRGB(115,80,49),Enum.PartType.Cylinder)
 part("Tapón",Vector3.new(.2,.45,.45),Vector3.new(-.4,3.46,.2),steel,Enum.PartType.Cylinder,CFrame.Angles(0,0,math.pi/2))
 local exhaust=part("Escape",Vector3.new(1.6,.24,.24),Vector3.new(1.7,2.8,.6),steel,Enum.PartType.Cylinder,CFrame.Angles(0,0,math.pi/2))
 local smoke=Instance.new("Smoke");smoke.Name="HumoSuave";smoke.Enabled=false;smoke.Opacity=.07;smoke.Size=1.2;smoke.RiseVelocity=2;smoke.Parent=exhaust
 part("Consola",Vector3.new(3.7,1.6,.28),Vector3.new(0,2,-1.55),Color3.fromRGB(35,45,48))
 local screen=part("Panel generador "..id,Vector3.new(2.1,.7,.05),Vector3.new(-.58,2.3,-1.73),Color3.fromRGB(184,65,54))
 screen.Material=Enum.Material.Neon
 local label=World.label(screen,"G"..id.." · SIN ENERGÍA")
 local light=Instance.new("PointLight");light.Color=screen.Color;light.Range=8;light.Brightness=.3;light.Shadows=false;light.Parent=screen
 local switches={}
 for i=1,4 do
  local x=-1.35+(i-1)*.6
  part("Zócalo interruptor",Vector3.new(.38,.36,.1),Vector3.new(x,1.7,-1.76),steel)
  switches[i]=part("Interruptor "..i,Vector3.new(.12,.3,.14),Vector3.new(x,1.7,-1.84),amber)
 end
 local colors={Color3.fromRGB(197,65,58),Color3.fromRGB(65,126,193),Color3.fromRGB(210,176,65)}
 for i=1,3 do
  local a=Instance.new("Attachment");a.Position=Vector3.new(-1.5+i*.55,-.65,-1.75);a.Parent=base
  local b=Instance.new("Attachment");b.Position=Vector3.new(-1.3+i*.55,-1.35,-.9);b.Parent=base
  local cable=Instance.new("Beam");cable.Name="Cable curvo "..i;cable.Attachment0=a;cable.Attachment1=b
  cable.Width0=.065;cable.Width1=.065;cable.CurveSize0=.3;cable.CurveSize1=.25;cable.FaceCamera=true;cable.Segments=6;cable.Color=ColorSequence.new(colors[i]);cable.Parent=base
 end
 local grip=part("Tirador de arranque",Vector3.new(.65,.16,.18),Vector3.new(1.65,1.8,-1.75),Color3.fromRGB(40,43,40))
 model:SetAttribute("Running",false);model:SetAttribute("RepairStage",1)
 game:GetService("CollectionService"):AddTag(model,"ForgottenGenerator")
 return {model=model,base=base,screen=screen,label=label,switches=switches,rotor=rotor,grip=grip,smoke=smoke,light=light}
end
function Generator.progress(view,stage,challenge)
 if view.challenge~=challenge then view.challenge=challenge;view.pulls=0 end
 view.model:SetAttribute("RepairStage",stage)
 view.label.Text=({"CONECTA LOS CABLES","AJUSTA LOS INTERRUPTORES","TIRA DEL ARRANQUE"})[stage]
 if challenge.current then
  for i,p in ipairs(view.switches) do p.CFrame=CFrame.new(p.Position)*CFrame.Angles(challenge.current[i] and -.5 or .5,0,0);p.Color=challenge.current[i] and Color3.fromRGB(82,177,127) or amber end
 end
 if challenge.pulls and challenge.pulls>(view.pulls or 0) then view.model:SetAttribute("PullAt",workspace:GetServerTimeNow());view.pulls=challenge.pulls end
end
function Generator.complete(view)
 view.model:SetAttribute("Running",true);view.smoke.Enabled=true;view.light.Color=Color3.fromRGB(82,177,127)
end
function Generator.animate()
 local Collection=game:GetService("CollectionService");local Run=game:GetService("RunService");local models={}
 local function add(model)
  task.defer(function()
   local rotor=model:WaitForChild("Rotor",10);local grip=model:WaitForChild("Tirador de arranque",10)
   if model.Parent and rotor and grip then models[model]={rotor=rotor,rotorFrame=rotor.CFrame,grip=grip,gripFrame=grip.CFrame} end
  end)
 end
 Collection:GetInstanceAddedSignal("ForgottenGenerator"):Connect(add)
 Collection:GetInstanceRemovedSignal("ForgottenGenerator"):Connect(function(m)models[m]=nil end)
 for _,model in ipairs(Collection:GetTagged("ForgottenGenerator")) do add(model) end
 Run.RenderStepped:Connect(function()
  local now=workspace:GetServerTimeNow()
  for model,data in pairs(models) do
   if model.Parent and data.rotor.Parent then
    if model:GetAttribute("Running") then data.rotor.CFrame=data.rotorFrame*CFrame.Angles(now*8,0,0) end
    local elapsed=now-(model:GetAttribute("PullAt") or -100)
    data.grip.CFrame=data.gripFrame*CFrame.new(0,0,elapsed>=0 and elapsed<.4 and -math.sin(elapsed/.4*math.pi)*.65 or 0)
   end
  end
 end)
end
return Generator
