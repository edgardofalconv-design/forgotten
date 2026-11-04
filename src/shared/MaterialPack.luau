-- Mapas originales en assets/textures. Subir las imágenes a Roblox y rellenar IDs.
-- Con campos vacíos el juego utiliza los materiales texturizados nativos.
local pack={
 {name="ForgottenOak",base=Enum.Material.WoodPlanks,prefix="oak",color="",normal="",roughness="",studs=6},
 {name="ForgottenStone",base=Enum.Material.Cobblestone,prefix="limestone",color="",normal="",roughness="",studs=5},
 {name="ForgottenWoven",base=Enum.Material.Fabric,prefix="woven",color="",normal="",roughness="",studs=2},
 {name="ForgottenBrass",base=Enum.Material.Metal,prefix="aged_brass",color="",normal="",roughness="",studs=3},
}
return function()
 local service=game:GetService("MaterialService")
 local enabled={}
 for _,entry in ipairs(pack) do
  if entry.color:match("^rbxassetid://%d+$") and entry.normal:match("^rbxassetid://%d+$") and entry.roughness:match("^rbxassetid://%d+$") then
   local variant=service:FindFirstChild(entry.name)
   if not variant then variant=Instance.new("MaterialVariant");variant.Name=entry.name;variant.Parent=service end
   variant.BaseMaterial=entry.base;variant.ColorMap=entry.color
   variant.NormalMap=entry.normal;variant.RoughnessMap=entry.roughness
   variant.StudsPerTile=entry.studs;enabled[entry.base]=entry.name
  end
 end
 return enabled
end
