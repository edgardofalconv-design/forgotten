-- Called in edit mode only. Never fabricates IDs or substitutes geometry.
local Config = require(script.Parent.Config)
local Catalog = {}

function Catalog.validate(info, spec)
	local creator = info.Creator or {}
	local creatorId = tonumber(creator.CreatorTargetId or creator.Id)
	assert(creatorId == 1 and creator.CreatorType == "User", "El recurso no pertenece al usuario oficial Roblox.")
	assert(info.Name == spec.Name, "Nombre incorrecto: se esperaba «" .. spec.Name .. "».")
	assert(tonumber(info.AssetTypeId) == spec.AssetTypeId, "Tipo de recurso incorrecto para «" .. spec.Name .. "».")
	return true
end

local function verify(id, spec)
	assert(type(id) == "number" and id > 0 and id % 1 == 0, "ID de catálogo inválido.")
	local info = game:GetService("MarketplaceService"):GetProductInfoAsync(id, Enum.InfoType.Asset)
	Catalog.validate(info, spec)
	return id
end

function Catalog.resolveOne(spec)
	if spec.Id and spec.Id > 0 then return verify(spec.Id, spec) end
	local params = CatalogSearchParams.new()
	params.SearchKeyword = spec.Name
	params.CreatorId = 1
	params.CreatorType = Enum.CreatorTypeFilter.User
	params.AssetTypes = {Enum.AvatarAssetType[spec.Type]}
	params.IncludeOffSale = true
	params.Limit = 30
	local pages = game:GetService("AvatarEditorService"):SearchCatalogAsync(params)
	local matches = {}
	for _ = 1, 5 do
		for _, item in ipairs(pages:GetCurrentPage()) do
			if item.Name == spec.Name then
				local id = tonumber(item.Id)
				local ok = pcall(verify, id, spec)
				if ok then matches[id] = true end
			end
		end
		if pages.IsFinished then break end
		pages:AdvanceToNextPageAsync()
	end
	local found
	for id in pairs(matches) do
		assert(not found, "Hay varios recursos oficiales con ese nombre. Especifica el ID que elegiste en Config.Resources.")
		found = id
	end
	assert(found, "No se pudo verificar «" .. spec.Name .. "». Abre su página oficial, copia el ID de /catalog/ y escríbelo en Config.Resources; consulta LEEME.")
	return found
end

function Catalog.resolve()
	local result = {}
	for _, key in ipairs({"Hair", "Shirt", "Pants"}) do
		local ok, value = pcall(Catalog.resolveOne, Config.Resources[key])
		assert(ok, key .. ": " .. tostring(value))
		result[key] = value
	end
	return result
end

return Catalog
