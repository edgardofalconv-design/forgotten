-- Preserve complete R6/R15 rigs and restore the player's own lobby avatar.
local Storage = game:GetService("ServerStorage")
local Native = {}
local saved = {}
local expected = setmetatable({}, {__mode = "k"})
local restored = setmetatable({}, {__mode = "k"})

function Native.consumeSwap(player, character)
 if expected[character] ~= player then return false end
 expected[character] = nil
 return true
end

function Native.isRestoredAvatar(character)
 return character ~= nil and restored[character] == true
end

function Native.equip(player, model, id, displayName, speed)
 local original = player.Character
 local oldHumanoid = original and original:FindFirstChildOfClass("Humanoid")
 local humanoid = model and model:FindFirstChildOfClass("Humanoid")
 local root = model and model:FindFirstChild("HumanoidRootPart")
 if saved[player] or not oldHumanoid or oldHumanoid.Health <= 0 or not humanoid or not root then
  if model then model:Destroy() end
  return false
 end
 if humanoid.RigType ~= Enum.HumanoidRigType.R15 and humanoid.RigType ~= Enum.HumanoidRigType.R6 then model:Destroy(); return false end
 -- Round rigs use BasicAnimation, independently of the player's avatar animation pack.
 for _, part in ipairs(model:GetDescendants()) do
  if part:IsA("BasePart") then part.Anchored = false end
 end
 humanoid.DisplayName = displayName or id
 humanoid.MaxHealth = 100
 humanoid.Health = 100
 humanoid.WalkSpeed = speed or 16
 model.Name = player.Name
 model:PivotTo(original:GetPivot())
 saved[player] = {original = original, round = model, parent = original.Parent}
 expected[model] = player
 original.Parent = Storage
 model.Parent = workspace
 player.Character = model
 player:SetAttribute("CharacterId", id)
 return true
end

function Native.restore(player)
 local record = saved[player]
 if not record then return false end
 saved[player] = nil
 if player.Character == record.round and record.original.Parent then
  local h = record.original:FindFirstChildOfClass("Humanoid")
  if h then h.Health = h.MaxHealth;h:SetAttribute("SpeedEffect",nil) end
  restored[record.original] = true
  expected[record.original] = player
  record.original.Parent = record.parent or workspace
  player.Character = record.original
  record.round:Destroy()
 else
  record.original:Destroy()
  if player.Character ~= record.round then record.round:Destroy() end
 end
 player:SetAttribute("CharacterId", nil)
 return true
end

function Native.discard(player)
 local record = saved[player]
 if not record then return end
 saved[player] = nil
 expected[record.original] = nil
 expected[record.round] = nil
 if player.Character ~= record.original then record.original:Destroy() end
 if player.Character ~= record.round then record.round:Destroy() end
end

return Native
