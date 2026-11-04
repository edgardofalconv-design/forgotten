-- LEGACY: use ImportJunkbotFromBundle.luau instead; bundle 589 needs no avatar changes.
-- Roblox Studio -> Command Bar. Equip the complete Junkbot on the Roblox avatar first.
-- Enter the account username (not DisplayName). This creates a local inspection model.
local username = ""
assert(username ~= "", "Escribe tu @usuario de Roblox en la variable username.")

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local userId = Players:GetUserIdFromNameAsync(username)
local description = Players:GetHumanoidDescriptionFromUserIdAsync(userId)

-- Check real catalog metadata; do not assume any remembered bundle or asset ID.
local checked = {}
for _, key in ipairs({"Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}) do
 local assetId = description[key]
 assert(assetId > 0, "Tu avatar no tiene el Junkbot completo: falta " .. key)
 local info = MarketplaceService:GetProductInfo(assetId, Enum.InfoType.Asset)
 assert(string.find(string.lower(info.Name), "junkbot", 1, true),
  "La pieza " .. key .. " aparece como '" .. info.Name .. "'. Equipa el Junkbot completo antes de importar.")
 checked[key] = assetId
end

-- Keep the original R15 body and joints. Do not coerce this bundle into R6.
local model = Players:CreateHumanoidModelFromDescriptionAsync(description, Enum.HumanoidRigType.R15)
model.Name = "Junkbot_Original_" .. tostring(userId)
model:SetAttribute("SourceAvatarUserId", userId)
model:SetAttribute("ExpectedCharacterId", "junkbot")
model:SetAttribute("CatalogBodyChecked", true)
for key, assetId in pairs(checked) do model:SetAttribute("Source" .. key .. "AssetId", assetId) end
local root = model:FindFirstChild("HumanoidRootPart")
assert(root, "Roblox no creó el rig esperado; revisa Output.")
root.Anchored = true
local camera = workspace.CurrentCamera
local position = camera and (camera.CFrame.Position + camera.CFrame.LookVector * 12) or Vector3.new(0, 5, 0)
model:PivotTo(CFrame.new(position))
model.Parent = workspace
game:GetService("Selection"):Set({model})
print("Junkbot original creado y seleccionado. Revisa ropa/accesorios extra; después Save to File como .rbxm.")
