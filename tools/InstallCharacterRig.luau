-- Optional: install a future, correctly identified full rig without changing game code.
-- Not needed to play the delivered prototype.
local selected=game:GetService("Selection"):Get()
assert(#selected==1 and selected[1]:IsA("Model"),"Selecciona un único rig completo.")
local source=selected[1]
local allowed={guest666=true,tubers93=true,pelotocino=true,yellowguy=true,junkbot=true,deathspeaker=true}
assert(allowed[source.Name],"Nombra el rig con el ID del personaje correcto.")
local Factory=require(game.ReplicatedStorage.Shared.CharacterFactory)
local candidate=source:Clone()
candidate:SetAttribute("CharacterIdentity",source.Name)
local valid,reason=Factory.validate(candidate,source.Name)
if not valid then candidate:Destroy();error(reason) end
candidate:SetAttribute("Placeholder",false)
local storage=game:GetService("ServerStorage")
local folder=storage:FindFirstChild("CharacterModels")
if not folder then folder=Instance.new("Folder");folder.Name="CharacterModels";folder.Parent=storage end
if folder:FindFirstChild(source.Name) then candidate:Destroy();error("Ya existe una plantilla; conserva o renombra la anterior antes de instalar otra.") end
candidate.Parent=folder
print("Rig instalado: "..source.Name..". Las articulaciones pasan la validación estructural; comprueba apariencia, física y animación en Studio.")
