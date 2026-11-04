-- Official bundle supplied by the author. Body asset IDs come from Roblox.
local Players = game:GetService("Players")
local AssetService = game:GetService("AssetService")
local Storage = game:GetService("ServerStorage")
local Catalog = {}
local cached
local loading = false
local lastAttempt = -math.huge
local BODY = {"Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}

local function validate(model)
 local h = model:FindFirstChildOfClass("Humanoid")
 assert(h and h.RigType == Enum.HumanoidRigType.R15, "Junkbot necesita su cuerpo R15 original.")
 assert(model:FindFirstChild("HumanoidRootPart") and model:FindFirstChild("Head"), "Junkbot llegó incompleto.")
 local description = h:GetAppliedDescription()
 for _, key in ipairs(BODY) do
  assert(description[key] > 0, "Falta la pieza original de Junkbot: " .. key)
 end
end

function Catalog.load()
 -- This method yields; call during lobby loading, never halfway through equipping.
 if cached then return true end
 if loading or os.clock() - lastAttempt < 20 then return false end
 loading = true
 lastAttempt = os.clock()
 local model
 local ok, problem = pcall(function()
  local folder = Storage:FindFirstChild("CatalogCharacters")
  local installed = folder and folder:FindFirstChild("junkbot")
  -- Read the previous misnamed installation only when its catalog ID proves it is Junkbot.
  if not installed and folder then
   local legacy=folder:FindFirstChild("yellowguy")
   if legacy and legacy:GetAttribute("SourceBundleId")==589 then installed=legacy end
  end
  if installed and installed:GetAttribute("SourceBundleId") == 589 then
   local candidate = installed:Clone()
   if pcall(validate,candidate) then model=candidate
   else candidate:Destroy();warn("Plantilla local de Junkbot incompleta; se intentará el catálogo.") end
  end
  if not model then
   local bundle = AssetService:GetBundleDetailsAsync(589)
   assert(bundle.Name and bundle.Name:lower() == "junkbot", "El paquete 589 no se identifica como Junkbot.")
   local outfitId
   for _, item in ipairs(bundle.Items) do
    if item.Type == "UserOutfit" then outfitId = item.Id; break end
   end
   assert(outfitId, "Roblox no devolvió el atuendo del paquete Junkbot.")
   local description = Players:GetHumanoidDescriptionFromOutfitIdAsync(outfitId)
   model = Players:CreateHumanoidModelFromDescriptionAsync(description, Enum.HumanoidRigType.R15)
   model:SetAttribute("SourceOutfitId", outfitId)
  end
  validate(model)
  model.Name = "junkbot"
  model:SetAttribute("SourceBundleId", 589)
  model:SetAttribute("ExpectedCharacterId", "junkbot")
  -- Do not recolor, rescale, overlay procedural meshes or add avatar accessories.
  model.Archivable = true
  model.Parent = nil
 end)
 loading = false
 if not ok then
  if model then model:Destroy() end
  warn("No se pudo cargar el Junkbot original: " .. tostring(problem))
  return false
 end
 cached = model
 return true
end

function Catalog.ready()
 return cached ~= nil
end

function Catalog.clone()
 if not cached then return nil end
 return cached:Clone()
end

return Catalog
