local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local shared=RS:WaitForChild("Shared")
local remote=RS:WaitForChild("GameEvent")
local T=require(shared.ClientTheme)
local AbilityConfig=require(shared.AbilityConfig)
local ItemConfig=require(shared.ItemConfig)
local Portraits=require(shared.Portraits)
local roster=require(shared.Roster);local byId={};for _,entry in ipairs(roster) do byId[entry.id]=entry end
require(shared.BasicAnimation)()
require(shared.EditableAppearance).start()
require(shared.GeneratorVisuals).animate()
pcall(function()game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList,false)end)
local function follow(character)
 local h=character:WaitForChild("Humanoid",10)
 if h and player.Character==character and workspace.CurrentCamera then workspace.CurrentCamera.CameraType=Enum.CameraType.Custom;workspace.CurrentCamera.CameraSubject=h end
end
player.CharacterAdded:Connect(follow);if player.Character then task.spawn(follow,player.Character) end
local old=player:WaitForChild("PlayerGui"):FindFirstChild("ForgottenUI");if old then old:Destroy() end
local gui=Instance.new("ScreenGui");gui.Name="ForgottenUI";gui.ResetOnSpawn=false;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=player.PlayerGui
local state={phase="Lobby",mode="Normal",remaining=15,generators=0,capsules=0,gateOpen=false,musicKey="",killerUserId=0}
local combat={character="pelotocino",cooldowns={},statuses={},items={},carried=0}
local selected="pelotocino";local sprinting=false;local scoreboardOpen=false
local top=T.frame(gui,"Cabecera",UDim2.fromScale(.02,.02),UDim2.fromScale(.96,.075),T.bg)
local phaseLabel=T.label(top,"Fase","FORGOTTEN",UDim2.fromScale(.01,.05),UDim2.fromScale(.3,.9),18,T.gold)
local clock=T.label(top,"Reloj","00:15",UDim2.fromScale(.39,.02),UDim2.fromScale(.22,.94),28)
local coins=T.label(top,"Monedas","CARGANDO PROGRESO…",UDim2.fromScale(.67,.04),UDim2.fromScale(.31,.9),14,T.gold)
local goals=T.label(gui,"Progreso","CAMPAMENTO SEGURO",UDim2.fromScale(.2,.1),UDim2.fromScale(.78,.045),14)
local objective=T.label(gui,"Objetivo","Elige tu historia",UDim2.fromScale(.2,.145),UDim2.fromScale(.78,.04),14,T.gold)
local menus=require(shared.ClientMenus)(gui,remote)
local challenge=require(shared.ClientChallenge)(gui,remote)
local results=require(shared.ClientResults)(gui)
local effects=require(shared.ClientEffects)(function()return menus.effectsEnabled()end)
local musicLabel=T.label(gui,"Musica","",UDim2.fromScale(.31,.975),UDim2.fromScale(.67,.025),10,T.muted)
local updateMusic=require(shared.ClientMusic)(musicLabel)
local toast=T.frame(gui,"Notificacion",UDim2.fromScale(.31,.22),UDim2.fromScale(.66,.12),T.bg);toast.Visible=false;toast.ZIndex=50
local toastText=T.label(toast,"Texto","",UDim2.fromScale(.03,.08),UDim2.fromScale(.94,.84),15)
local toastUntil=0
local escapeData,escapeUntil
local escapeButton=T.button(gui,"EscaparDelAtaque","",UDim2.fromScale(.32,.59),UDim2.fromScale(.36,.08),function()
 if escapeData then remote:FireServer("struggle",escapeData.token) end
end,T.red)
escapeButton.Visible=false
local function notify(message,duration)toastText.Text=message;toast.Visible=true;toastUntil=os.clock()+(duration or 5)end
T.button(gui,"Menu","MENÚ · M",UDim2.fromScale(.02,.11),UDim2.fromScale(.16,.06),function()menus.open()end)
local function showScoreboard()
 scoreboardOpen=true;results.show({rows=state.scoreboard or {},map=state.mapName,message="Estado de la partida"},true)
end
T.button(gui,"Marcador","MARCADOR · TAB",UDim2.fromScale(.02,.18),UDim2.fromScale(.16,.05),showScoreboard,T.bg)
local hud=T.frame(gui,"HUD",UDim2.fromScale(.02,.77),UDim2.fromScale(.96,.2),T.bg)
local identity=T.label(hud,"Identidad","",UDim2.fromScale(.015,.01),UDim2.fromScale(.27,.17),14,T.gold)
local function statusBar(name,y,color)
 local label=T.label(hud,name,name,UDim2.fromScale(.015,y),UDim2.fromScale(.27,.16),13)
 local track=T.frame(hud,name.."Track",UDim2.fromScale(.025,y+.17),UDim2.fromScale(.25,.055),T.edge)
 local fill=T.frame(track,name.."Fill",UDim2.new(),UDim2.fromScale(1,1),color)
 return label,fill
end
local health,healthFill=statusBar("VIDA",.23,T.green)
local energy,energyFill=statusBar("ENERGÍA",.57,T.gold)
local skills=T.frame(hud,"Habilidades",UDim2.fromScale(.3,.06),UDim2.fromScale(.68,.62),T.bg)
local grid=Instance.new("UIGridLayout");grid.CellPadding=UDim2.fromOffset(5,5);grid.SortOrder=Enum.SortOrder.LayoutOrder;grid.Parent=skills
local skillButtons={}
local function aim()
 local mouse=player:GetMouse();local camera=workspace.CurrentCamera
 if UIS.TouchEnabled and camera then return camera.CFrame.LookVector end
 return mouse.UnitRay.Direction
end
local function cast(slot)if player:GetAttribute("InRound") then remote:FireServer("skill",slot,aim()) end end
for i=1,6 do
 local b=T.button(skills,"Habilidad"..i,"",UDim2.new(),UDim2.new(),function()cast(i)end,T.panel)
 b.LayoutOrder=i;skillButtons[i]=b
end
local itemButtons={}
for i=1,2 do itemButtons[i]=T.button(hud,"Objeto"..i,"",UDim2.fromScale(.3+(i-1)*.19,.74),UDim2.fromScale(.18,.21),function()remote:FireServer("item",i)end,T.panel) end
local function sprint(value)sprinting=value;remote:FireServer("sprint",value)end
local sprintButton=T.button(hud,"Sprint","SHIFT · CORRER",UDim2.fromScale(.69,.74),UDim2.fromScale(.14,.21),function()sprint(not sprinting)end,T.edge)
local attackButton=T.button(hud,"Atacar","CLIC · ATACAR",UDim2.fromScale(.84,.74),UDim2.fromScale(.14,.21),function()remote:FireServer("attack",aim())end,T.red)
local statusLabel=T.label(gui,"Estados","",UDim2.fromScale(.3,.71),UDim2.fromScale(.68,.04),13,T.gold)
local function refreshHUD()
 local active=state.phase=="Ronda" and player:GetAttribute("InRound")==true
 hud.Visible=active;statusLabel.Visible=active
 local id=player:GetAttribute("CharacterId") or selected;local entry=byId[id]
 identity.Text=entry and entry.name or ""
 local list=AbilityConfig[id] or {}
 local small=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X<850
 hud.Position=UDim2.fromScale(.02,small and .71 or .77);hud.Size=UDim2.fromScale(.96,small and .26 or .2)
 local columns=small and 3 or math.max(1,#list)
 grid.CellSize=UDim2.new(1/columns,-5,0,small and 40 or 58)
 for i,b in ipairs(skillButtons) do
  local a=list[i];b.Visible=a~=nil
  if a then
   local cooldown=combat.character==id and (combat.cooldowns[i] or 0) or 0
   b.Text=a.icon.."  "..AbilityConfig.keys[i].."\n"..a.name..(cooldown>0 and " · "..cooldown.."s" or "")
   b.TextSize=small and 11 or 12;b.BackgroundColor3=cooldown>0 and T.bg or T.panel
  end
 end
 for i,b in ipairs(itemButtons) do
  local item=combat.items[i]
  b.Text=({"Z","X"})[i].." · "..(item and ItemConfig[item].name or "VACÍO")
 end
 attackButton.Visible=entry and entry.role=="Asesino" or false
 sprintButton.Text=sprinting and "PARAR" or "SHIFT · CORRER"
 statusLabel.Text=table.concat(combat.statuses or {},"  •  ")
 if not active then challenge.close();escapeData=nil;escapeButton.Visible=false;if sprinting then sprint(false) end end
end
local function refreshState()
 local remaining=math.max(0,math.ceil(state.remaining or 0))
 clock.Text=string.format("%02d:%02d",math.floor(remaining/60),remaining%60)
 phaseLabel.Text="FORGOTTEN · "..(state.phase=="Ronda" and state.mode or state.phase)
 if state.phase=="Lobby" then
  goals.Text="CAMPAMENTO · ZONA SEGURA";objective.Text="Selecciona personaje, visita la tienda y vota un mapa."
 elseif state.phase=="Fin" then goals.Text=state.mapName or "";objective.Text=state.result or "Regreso al campamento"
 elseif state.mode=="LMS" then
  goals.Text="ÚLTIMO SUPERVIVIENTE · SIN REQUISITOS"
  objective.Text=state.gateOpen and "¡ATRAVIESA LA SALIDA!" or "Resiste. La puerta abre a 0:00."
 else
  goals.Text="Generadores "..state.generators.."/4 (mín. 2) · Cápsulas depositadas "..state.capsules.."/3 · Llevas "..(combat.carried or 0)
  objective.Text=state.gateOpen and "¡ATRAVIESA LA SALIDA PARA ESCAPAR!" or (combat.carried or 0)>0 and "Lleva tus cápsulas al depósito junto a la salida." or state.generators<2 and "Repara generadores: cables, interruptores y cuerda." or state.capsules<3 and "Resuelve puzles, recoge cápsulas y deposítalas." or "Requisitos completos. Resiste hasta 1:00."
 end
 if state.phase=="Ronda" and not player:GetAttribute("InRound") then objective.Text="Espera la próxima ronda en el campamento." end
 menus.setState(state);refreshHUD()
end
player:GetAttributeChangedSignal("InRound"):Connect(refreshHUD)
local keySlots={Q=1,R=2,F=3,G=4,T=5,Y=6}
UIS.InputBegan:Connect(function(input,processed)
 if escapeData and input.KeyCode==Enum.KeyCode.E and not UIS:GetFocusedTextBox() then remote:FireServer("struggle",escapeData.token);return end
 if processed then return end
 local key=input.KeyCode.Name
 if key=="M" then menus.open();return end
 if key=="Tab" then if results.visible() then results.hide();scoreboardOpen=false else showScoreboard() end;return end
 if not player:GetAttribute("InRound") or challenge.visible() then return end
 if keySlots[key] then cast(keySlots[key])
 elseif key=="Z" then remote:FireServer("item",1)
 elseif key=="X" then remote:FireServer("item",2)
 elseif key=="LeftShift" then sprint(true)
 elseif input.UserInputType==Enum.UserInputType.MouseButton1 and not results.visible() then remote:FireServer("attack",aim()) end
end)
UIS.InputEnded:Connect(function(input)if input.KeyCode==Enum.KeyCode.LeftShift then sprint(false) end end)
UIS.WindowFocusReleased:Connect(function()if sprinting then sprint(false) end end)
local scoreboardAt=0
remote.OnClientEvent:Connect(function(kind,data)
 if kind=="state" then
  state=data;refreshState()
  if scoreboardOpen and results.visible() and os.clock()>scoreboardAt then showScoreboard();scoreboardAt=os.clock()+1 end
 elseif kind=="message" then notify(tostring(data),6)
 elseif kind=="selected" and byId[data] then selected=data;menus.setSelected(data);refreshHUD()
 elseif kind=="profile" then
  menus.setProfile(data)
  coins.Text=data.coins.." FORGOTTEN COINS\n"..(data.mode=="persistent" and "Guardado automático" or data.mode=="locked" and "Progreso bloqueado" or "Progreso de sesión")
 elseif kind=="reward" then
  local extra=#data.unlocked>0 and "\n¡Nueva Milestone desbloqueada!" or ""
  notify("+"..data.coins.." Forgotten Coins"..extra,5);effects.sound("reward")
 elseif kind=="combat" then combat=data;refreshHUD();refreshState()
 elseif kind=="challenge" then challenge.open(data);effects.sound("ui")
 elseif kind=="challengeClose" then challenge.close()
 elseif kind=="openPanel" then menus.open(data)
 elseif kind=="effect" then effects.effect(data)
 elseif kind=="sfx" then effects.sound(data)
 elseif kind=="reveal" then effects.reveal(data)
 elseif kind=="escape" then
  escapeData=data;escapeUntil=os.clock()+data.duration;escapeButton.Text="¡ESCAPA!  E · "..data.taps.." / "..data.required;escapeButton.Visible=true
 elseif kind=="escapeClose" then escapeData=nil;escapeButton.Visible=false
 elseif kind=="results" then scoreboardOpen=false;results.show(data,false);challenge.close();effects.sound("results") end
end)
local elapsed=0;local audioElapsed=0;local footstepAt=0
RunService.Heartbeat:Connect(function(dt)
 elapsed=elapsed+dt;audioElapsed=audioElapsed+dt
 if elapsed>=.1 then
  elapsed=0
  if toast.Visible and os.clock()>toastUntil then toast.Visible=false end
  if escapeData and os.clock()>escapeUntil then escapeData=nil;escapeButton.Visible=false end
  local c=player.Character;local h=c and c:FindFirstChildOfClass("Humanoid");local root=c and c:FindFirstChild("HumanoidRootPart")
  local hp=h and math.max(0,h.Health) or 0;local max=h and h.MaxHealth or 100;local stamina=player:GetAttribute("Energy") or 100
  health.Text="VIDA  "..math.ceil(hp).." / "..max;healthFill.Size=UDim2.fromScale(hp/math.max(1,max),1);healthFill.BackgroundColor3=hp<30 and T.red or T.green
  energy.Text="ENERGÍA  "..stamina.." / 100";energyFill.Size=UDim2.fromScale(stamina/100,1)
  if root and h and h.Health>0 and h.FloorMaterial~=Enum.Material.Air and root.AssemblyLinearVelocity.Magnitude>3 and os.clock()>footstepAt then effects.sound("footstep");footstepAt=os.clock()+.45 end
 end
 if audioElapsed>=.25 then audioElapsed=0;updateMusic(state) end
end)
refreshState();remote:FireServer("ready")
