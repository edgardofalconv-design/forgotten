-- Run in Studio's Command Bar after importing one exported FBX as a Model.
-- Active IDs: guest666, tubers93, pelotocino, yellowguy, junkbot, deathspeaker.
local Selection=game:GetService("Selection")
local selected=Selection:Get()
assert(#selected==1 and selected[1]:IsA("Model"),"Selecciona un único modelo importado.")
local source=selected[1]
local allowed={guest666=true,tubers93=true,pelotocino=true,yellowguy=true,junkbot=true,deathspeaker=true}
assert(allowed[source.Name],"Renombra el modelo con el identificador de personaje indicado en la guía.")
assert(source.Name~="yellowguy" or source:GetAttribute("CharacterIdentity")=="yellowguy","La exportación antigua llamada yellowguy era un robot. Instálala como junkbot. El Yellow Guy clásico necesita su propio modelo.")
local prefix=source.Name
if source.Name=="junkbot" and source:FindFirstChild("yellowguy__Head_mesh",true) then prefix="yellowguy" end
for _,name in ipairs({"Head_mesh","Torso_mesh","LeftArm_mesh","RightArm_mesh","LeftLeg_mesh","RightLeg_mesh"}) do
 local part=source:FindFirstChild(prefix.."__"..name,true) or source:FindFirstChild(name,true)
 assert(part and part:IsA("BasePart"),"Falta "..name..". Revisa los nombres y la jerarquía del FBX importado.")
end
local storage=game:GetService("ServerStorage")
local folder=storage:FindFirstChild("ReferenceCharacters")
if not folder then folder=Instance.new("Folder");folder.Name="ReferenceCharacters";folder.Parent=storage end
assert(not folder:FindFirstChild(source.Name),"Ya existe una plantilla de ese personaje; conserva o renombra la anterior antes de instalar otra.")
local template=source:Clone()
template:SetAttribute("ReferenceFormat",1)
template:SetAttribute("ReferenceScale",1)
template:SetAttribute("CharacterIdentity",source.Name)
template:SetAttribute("ReferenceMeshPrefix",prefix)
for _,part in ipairs(template:GetDescendants()) do if part:IsA("BasePart") then part.Anchored=true;part.CanCollide=false end end
template.Parent=folder
print("Plantilla instalada: "..source.Name..". Prueba en R6 y ajusta escala/pivotes si es necesario; la importación no verifica el rig automáticamente.")
