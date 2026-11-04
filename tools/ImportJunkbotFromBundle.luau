-- Paste into Roblox Studio's Command Bar in EDIT mode, then press Enter.
-- No username, currently equipped avatar, HttpService or PowerShell required.
assert(not game:GetService("RunService"):IsRunning(), "Detén Play antes de importar para guardar el modelo.")
local Players = game:GetService("Players")
local bundle = game:GetService("AssetService"):GetBundleDetailsAsync(589)
assert(bundle.Name and bundle.Name:lower() == "junkbot", "El paquete no se identifica como Junkbot.")
local outfitId
for _, item in ipairs(bundle.Items) do
 if item.Type == "UserOutfit" then outfitId = item.Id; break end
end
assert(outfitId, "Roblox no devolvió el atuendo del paquete Junkbot.")
local description = Players:GetHumanoidDescriptionFromOutfitIdAsync(outfitId)
for _, key in ipairs({"Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}) do
 assert(description[key] > 0, "Roblox no devolvió la pieza: " .. key)
end
local model = Players:CreateHumanoidModelFromDescriptionAsync(description, Enum.HumanoidRigType.R15)
model.Name = "junkbot"
model:SetAttribute("SourceBundleId", 589)
model:SetAttribute("SourceOutfitId", outfitId)
model:SetAttribute("ExpectedCharacterId", "junkbot")
local root = model:FindFirstChild("HumanoidRootPart")
assert(root, "Roblox no creó el cuerpo esperado.")
root.Anchored = true
local storage = game:GetService("ServerStorage")
local folder = storage:FindFirstChild("CatalogCharacters")
if not folder then folder = Instance.new("Folder"); folder.Name = "CatalogCharacters"; folder.Parent = storage end
-- Keep any existing installation intact if the command is pasted again.
if not folder:FindFirstChild("junkbot") then model:Clone().Parent = folder end
model.Name = "Junkbot_Original_589"
local camera = workspace.CurrentCamera
local position = camera and (camera.CFrame.Position + camera.CFrame.LookVector * 12) or Vector3.new(0, 5, 0)
model:PivotTo(CFrame.new(position))
model.Parent = workspace
game:GetService("Selection"):Set({model})
print("Junkbot original seleccionado; pulsa F para enfocarlo. Guarda el lugar para conservar la plantilla de Junkbot.")
