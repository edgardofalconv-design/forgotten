local T=require(script.Parent.ClientTheme)
return function(gui,remote)
 local box=T.frame(gui,"Desafio",UDim2.fromScale(.15,.2),UDim2.fromScale(.7,.55),T.bg);box.Visible=false;box.ZIndex=40
 local title=T.label(box,"Titulo","",UDim2.fromScale(.04,.03),UDim2.fromScale(.8,.1),21,T.gold)
 local hint=T.label(box,"Indicacion","",UDim2.fromScale(.04,.15),UDim2.fromScale(.92,.18),15)
 local body=T.frame(box,"Controles",UDim2.fromScale(.04,.36),UDim2.fromScale(.92,.59),T.panel)
 local stages=T.frame(box,"Etapas",UDim2.fromScale(.04,.31),UDim2.fromScale(.92,.012),T.bg)
 local data;local lastClick=0;local clockLabel;local timerBar
 local function close(send) data=nil;box.Visible=false;if send then remote:FireServer("challengeCancel") end end
 T.button(box,"Cerrar","×",UDim2.fromScale(.87,.02),UDim2.fromScale(.1,.1),function()close(true)end)
 local function input(value)
  if data and os.clock()-lastClick>=.16 then lastClick=os.clock();remote:FireServer("challenge",data.token,value) end
 end
 local names={"ROJO","AZUL","AMARILLO","VERDE"}
 local colors={Color3.fromRGB(168,64,60),Color3.fromRGB(58,107,177),Color3.fromRGB(163,139,57),Color3.fromRGB(57,132,94)}
 local function open(payload)
  data=payload;box.Visible=true;T.clear(body);T.clear(stages);stages.Visible=payload.family=="generator";clockLabel=nil;timerBar=nil
  local c=data.challenge
  local stageNames={wires="CABLEADO",switches="INTERRUPTORES",rope="ARRANQUE",memory="MEMORIA",piano="PIANO",reflex="REFLEJOS",maze="LABERINTO"}
  title.Text=(data.family=="generator" and "GENERADOR " or "ESTACIÓN ")..data.id.." · "..(stageNames[c.kind] or c.kind)
  if data.family=="generator" then
   title.Text=title.Text.." · "..data.stage.."/3"
   for stage=1,3 do T.frame(stages,"Etapa",UDim2.fromScale((stage-1)*.34,0),UDim2.fromScale(.32,1),stage<data.stage and T.green or stage==data.stage and T.gold or T.edge) end
  end
  if c.kind=="memory" or c.kind=="piano" or c.kind=="wires" then
   local sequence={};for _,value in ipairs(c.sequence) do table.insert(sequence,c.kind=="piano" and ({"DO","RE","MI","SOL"})[value] or names[value]) end
   hint.Text=c.kind=="wires" and "Conecta los cables en este orden:" or c.kind=="piano" and "Repite la melodía con las teclas:" or "Memoriza la secuencia antes de que desaparezca."
   clockLabel=T.label(body,"Secuencia",c.kind=="memory" and workspace:GetServerTimeNow()>=c.readyAt and ("RECUERDA · PASO "..c.step) or table.concat(sequence," → "),UDim2.fromScale(.02,.04),UDim2.fromScale(.96,.3),19,T.gold)
   for i=1,4 do
    local pad=T.button(body,"Pad"..i,c.kind=="piano" and ({"DO","RE","MI","SOL"})[i] or names[i],UDim2.fromScale(.02+(i-1)*.245,.45),UDim2.fromScale(.225,.45),function()input(i)end,colors[i])
    if c.kind=="wires" then
     T.frame(pad,"Terminal",UDim2.fromScale(.4,0),UDim2.fromScale(.2,.12),T.gold)
     T.label(pad,"Numero",tostring(i),UDim2.fromScale(.03,.02),UDim2.fromScale(.2,.25),12)
    end
   end
   if c.kind~="memory" then hint.Text=hint.Text.." Paso "..c.step.."/"..#c.sequence end
  elseif c.kind=="switches" then
   hint.Text="Deja los interruptores en la posición indicada arriba."
   for i=1,4 do
    T.label(body,"Meta"..i,c.target[i] and "ENCENDIDO" or "APAGADO",UDim2.fromScale(.02+(i-1)*.245,.08),UDim2.fromScale(.225,.2),13,T.gold)
    T.button(body,"Interruptor"..i,c.current[i] and "ON" or "OFF",UDim2.fromScale(.02+(i-1)*.245,.4),UDim2.fromScale(.225,.45),function()input(i)end,c.current[i] and T.green or T.edge)
   end
  elseif c.kind=="reflex" then
   hint.Text="Espera la señal verde. Pulsar antes cancela el intento."
   clockLabel=T.label(body,"Semaforo","ESPERA…",UDim2.fromScale(.1,.05),UDim2.fromScale(.8,.35),26,T.red)
   T.button(body,"Reaccionar","PULSAR",UDim2.fromScale(.2,.5),UDim2.fromScale(.6,.38),function()input("hit")end)
  elseif c.kind=="rope" then
   hint.Text="Tira cuando el marcador esté dentro de la franja verde. Tres tirones correctos."
   local track=T.frame(body,"Pista",UDim2.fromScale(.05,.15),UDim2.fromScale(.9,.15),T.bg)
   T.frame(track,"Zona",UDim2.fromScale(.3,0),UDim2.fromScale(.4,1),T.green)
   timerBar=T.frame(track,"Marcador",UDim2.fromScale(0,0),UDim2.fromScale(.025,1),T.gold)
   T.button(body,"Tirar","TIRAR · "..c.pulls.."/3",UDim2.fromScale(.2,.5),UDim2.fromScale(.6,.38),function()input("pull")end)
  elseif c.kind=="maze" then
   hint.Text="Guía la energía hasta la casilla dorada."
   for y,row in ipairs(c.grid) do for x=1,7 do
    local tint=row:sub(x,x)=="1" and T.edge or T.bg
    if x==6 and y==6 then tint=T.gold end
    if x==c.x and y==c.y then tint=T.green end
    T.frame(body,"Celda",UDim2.fromScale(.03+(x-1)*.065,.03+(y-1)*.128),UDim2.fromScale(.06,.12),tint)
   end end
   for _,control in ipairs({{"up","↑",.72,.12},{"left","←",.58,.45},{"down","↓",.72,.7},{"right","→",.86,.45}}) do
    T.button(body,control[1],control[2],UDim2.fromScale(control[3],control[4]),UDim2.fromScale(.12,.22),function()input(control[1])end)
   end
  end
 end
 game:GetService("RunService").RenderStepped:Connect(function()
  if not data or not box.Visible then return end
  local c=data.challenge;local now=workspace:GetServerTimeNow()
  if c.kind=="memory" and clockLabel and now>=c.readyAt then clockLabel.Text="RECUERDA · PASO "..c.step.."/"..#c.sequence end
  if c.kind=="reflex" and clockLabel then
   local ready=now>=c.readyAt and now<=c.readyAt+1.2
   clockLabel.Text=ready and "¡AHORA!" or now>c.readyAt+1.2 and "TIEMPO AGOTADO" or "ESPERA…"
   clockLabel.TextColor3=ready and T.green or T.red
  end
  if c.kind=="rope" and timerBar then timerBar.Position=UDim2.fromScale(now<c.readyAt and 0 or ((now-c.readyAt)%1.8)/1.8,0) end
 end)
 return {open=open,close=function()close(false)end,visible=function()return box.Visible end}
end
