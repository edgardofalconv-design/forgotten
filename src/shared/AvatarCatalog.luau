-- Resolve official catalog resources by exact name and verified creator at runtime.
-- No guessed asset or bundle IDs. Junkbot keeps its existing, author-supplied loader.
local Players=game:GetService("Players")
local Editor=game:GetService("AvatarEditorService")
local Assets=game:GetService("AssetService")
local Catalog={}
local templates={}
local loading=false
local nextAttempt=0
local function official(entry,name)
 return type(entry)=="table" and type(entry.Id)=="number" and entry.Id>0
  and type(entry.Name)=="string" and entry.Name:lower()==name:lower()
  and type(entry.CreatorName)=="string" and entry.CreatorName:lower()=="roblox"
end
local function search(name,bundle)
 local params=CatalogSearchParams.new()
 params.SearchKeyword=name;params.CreatorName="Roblox";params.IncludeOffSale=true;params.Limit=30
 if bundle then params.BundleTypes={Enum.BundleType.BodyParts}
 else params.AssetTypes={Enum.AvatarAssetType.HairAccessory} end
 local pages=Editor:SearchCatalogAsync(params)
 for _,entry in ipairs(pages:GetCurrentPage()) do if official(entry,name) then return entry.Id end end
 return nil
end
local function native(name,description,rigType)
 local model=Players:CreateHumanoidModelFromDescriptionAsync(description,rigType)
 assert(model and model:FindFirstChildOfClass("Humanoid") and model:FindFirstChild("HumanoidRootPart"),"Avatar incompleto")
 model.Name=name;model.Archivable=true;model.Parent=nil;templates[name]=model
end
function Catalog.load()
 if loading or os.clock()<nextAttempt then return false end
 if templates.classic and templates.bacon and templates.deathspeaker then return false end
 loading=true;nextAttempt=os.clock()+90
 local changed=false
 local function attempt(key,fn)
  if templates[key] then return end
  local ok,problem=pcall(fn)
  if ok and templates[key] then changed=true else warn("FORGOTTEN V3 · "..key..": "..tostring(problem or "recurso no disponible")..". Se conserva la alternativa propia.") end
 end
 attempt("classic",function()
  native("classic",Instance.new("HumanoidDescription"),Enum.HumanoidRigType.R6)
 end)
 attempt("bacon",function()
  local id=search("Pal Hair",false);assert(id,"No se encontró Pal Hair del creador Roblox")
  local description=Instance.new("HumanoidDescription");description.HairAccessory=tostring(id)
  native("bacon",description,Enum.HumanoidRigType.R6)
  templates.bacon:SetAttribute("OfficialBaconHair",true)
  templates.bacon:SetAttribute("ResolvedHairAssetId",id)
 end)
 attempt("deathspeaker",function()
  local id=search("Korblox Deathspeaker",true);assert(id,"No se encontró el paquete oficial Korblox Deathspeaker")
  local bundle=Assets:GetBundleDetailsAsync(id)
  assert(type(bundle.Name)=="string" and bundle.Name:lower()=="korblox deathspeaker","Identidad de paquete incorrecta")
  local outfit
  for _,item in ipairs(bundle.Items or {}) do if item.Type=="UserOutfit" then outfit=item.Id;break end end
  assert(outfit,"El paquete no incluye un atuendo")
  local description=Players:GetHumanoidDescriptionFromOutfitIdAsync(outfit)
  for _,key in ipairs({"Head","Torso","LeftArm","RightArm","LeftLeg","RightLeg"}) do assert(description[key]>0,"Cuerpo oficial incompleto: "..key) end
  native("deathspeaker",description,Enum.HumanoidRigType.R15)
  templates.deathspeaker:SetAttribute("ResolvedBundleId",id)
  templates.deathspeaker:SetAttribute("SourceOutfitId",outfit)
  templates.deathspeaker:SetAttribute("OfficialCatalogBody",true)
 end)
 loading=false
 return changed
end
function Catalog.clone(id)
 local key=id=="deathspeaker" and "deathspeaker" or (id=="pelotocino" or id=="tubers93") and (templates.bacon and "bacon" or "classic") or id~="junkbot" and "classic"
 local template=key and templates[key]
 if not template then return nil end
 local model=template:Clone();model:SetAttribute("CharacterIdentity",id)
 model:SetAttribute("NativeAvatarRig",true)
 return model
end
return Catalog
