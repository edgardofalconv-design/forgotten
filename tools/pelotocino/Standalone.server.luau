-- Preview-only prompt. Combat remains authoritative in the full FORGOTTEN test place.
local model=script.Parent;local root=model:WaitForChild("HumanoidRootPart")
if not model:GetAttribute("NPC")then return end
local prompt=Instance.new("ProximityPrompt");prompt.Name="PreviewAnimation";prompt.ActionText="Ver animación";prompt.ObjectText="Pelotocino R15 · vista previa";prompt.HoldDuration=.2;prompt.MaxActivationDistance=10;prompt.Parent=root
local states={"idle","walk","run","pan","baconThrow","detector","hit"};local index=0;local cooldown=0
prompt.Triggered:Connect(function(player)
 local now=workspace:GetServerTimeNow();local r=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if now<cooldown or not r or(r.Position-root.Position).Magnitude>12 then return end
 cooldown=now+1.7;index=index%#states+1;local key=states[index]
 local action=key=="pan"or key=="baconThrow"or key=="detector"
 model:SetAttribute("Action",action and key or"");model:SetAttribute("ActionAt",now)
 model:SetAttribute("DemoState",action and"idle"or key);model:SetAttribute("DemoUntil",now+1.7)
 prompt.ActionText="Animación: "..key
end)
