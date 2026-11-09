-- EDIT MODE ONLY. Select the FBX import, then run the one-line command in the guide.
-- Validates all resources before replacing anything; keeps previous installations.
local RS=game:GetService("ReplicatedStorage")
local Storage=game:GetService("ServerStorage")
local Run=game:GetService("RunService")
local ContentProvider=game:GetService("ContentProvider")
local Library=require(RS.Shared.PelotocinoMeshLibrary)
local Data=require(RS.Shared.PelotocinoMeshData)
local Setup={}
function Setup.install(selected)
 assert(Run:IsStudio()and not Run:IsRunning(),"Pulsa STOP. La instalación se realiza en modo edición, antes de Play.")
 selected=selected or game:GetService("Selection"):Get()[1]
 assert(selected and (selected:IsA("Model")or selected:IsA("Folder")),"Selecciona el modelo completo recién importado desde Pelotocino-Importar.fbx.")
 local found,errors=Library.inspect(selected,true)
 assert(#errors==0,"Importación incompleta; no se cambió el proyecto:\n"..table.concat(errors,"\n"))
 local assets={}
 for _,spec in ipairs(Data.meshes)do
  local part=found[spec.name];local _,expected=Library.bounds(spec)
  local x,y,z=part.Size.X/expected.X,part.Size.Y/expected.Y,part.Size.Z/expected.Z
  assert(math.min(x,y,z)>0 and math.max(x,y,z)/math.min(x,y,z)<1.06,"Proporciones/ejes alterados: "..spec.name..". Reimporta sin girar ni deformar las mallas.")
  table.insert(assets,part)
  local surface=part:FindFirstChildOfClass("SurfaceAppearance");if surface then table.insert(assets,surface)end
 end
 local failures={}
 local loaded,problem=pcall(function()
  ContentProvider:PreloadAsync(assets,function(id,status)
   if status~=Enum.AssetFetchStatus.Success then table.insert(failures,tostring(id).." · "..tostring(status))end
  end)
 end)
 assert(loaded and #failures==0,"Roblox no pudo cargar los recursos importados. Revisa propietario/permisos y Output; no se instaló nada. "..tostring(problem or table.concat(failures,"; ")))
 local templates=Storage:FindFirstChild("PelotocinoSetupTemplates")
 assert(templates and templates:FindFirstChild("Pelotocino_R15")and templates:FindFirstChild("Pelotocino_NPC"),"Abre Forgotten-Pelotocino-MeshParts.rbxlx; faltan las plantillas R15.")
 local bank=Instance.new("Folder");bank.Name="PelotocinoImportedMeshes";bank:SetAttribute("InstallationVersion","meshparts-20261109")
 for _,spec in ipairs(Data.meshes)do
  local part=found[spec.name]:Clone()
  for _,child in ipairs(part:GetChildren())do if not child:IsA("SurfaceAppearance")then child:Destroy()end end
  local _,size=Library.bounds(spec);part.Size=size;part.CFrame=CFrame.new();part.PivotOffset=CFrame.new()
  part.Anchored=false;part.Transparency=0;part.CanCollide=false;part.CanTouch=false;part.CanQuery=false;part.Massless=true
  part.Color=Color3.new(1,1,1);part.Material=Enum.Material[spec.material];part.Parent=bank
 end
 local review=Instance.new("Folder");review.Name="PelotocinoRevision"
 local playable,npc,gameModel
 local staged,stageError=pcall(function()
  playable=templates.Pelotocino_R15:Clone();npc=templates.Pelotocino_NPC:Clone()
  for i,model in ipairs({playable,npc})do
   Library.attach(model,bank);model:SetAttribute("PelotocinoVisualReady",true);model:SetAttribute("ModelStatus","MeshParts importadas · R15")
   model.PrimaryPart.Anchored=true;model:PivotTo(CFrame.new(i==1 and -2 or 2,3,0));model.Parent=review
  end
  gameModel=playable:Clone();gameModel.Name="pelotocino"
  for _,name in ipairs({"AnimSaves","PelotocinoPackage","PelotocinoAnimate","PelotocinoPreview"})do local child=gameModel:FindFirstChild(name);if child then child:Destroy()end end
 end)
 if not staged then bank:Destroy();review:Destroy();if gameModel then gameModel:Destroy()end;error(stageError)end
 local characters=Storage:FindFirstChild("CharacterModels")
 if not characters then characters=Instance.new("Folder");characters.Name="CharacterModels";characters.Parent=Storage end
 local backups=Storage:FindFirstChild("PelotocinoImportBackups")
 if not backups then backups=Instance.new("Folder");backups.Name="PelotocinoImportBackups";backups.Parent=Storage end
 local history=game:GetService("ChangeHistoryService");history:SetWaypoint("Antes de instalar Pelotocino")
 local backup=Instance.new("Folder");backup.Name="Instalacion_"..tostring(os.time());backup.Parent=backups
 local replacements={{parent=RS,new=bank},{parent=characters,new=gameModel},{parent=workspace,new=review}}
 local sourceParent=selected.Parent
 local committed,commitError=pcall(function()
  for _,entry in ipairs(replacements)do
   entry.old=entry.parent:FindFirstChild(entry.new.Name)
   if entry.old then entry.old.Parent=backup end
   entry.new.Parent=entry.parent
  end
  -- Keep the unrigged source as a backup rather than a second collidable avatar.
  local parent=selected.Parent
  while parent do
   if parent==workspace then selected.Parent=backup;break end
   parent=parent.Parent
  end
 end)
 if not committed then
  for _,entry in ipairs(replacements)do entry.new:Destroy();if entry.old then entry.old.Parent=entry.parent end end
  selected.Parent=sourceParent
  backup:Destroy();error(commitError)
 end
 history:SetWaypoint("Pelotocino instalado")
 game:GetService("Selection"):Set({review})
 print("PELOTOCINO INSTALADO: 25/25 MeshParts y texturas cargadas. Jugador y NPC conectados al mismo R15. Guarda el .rbxlx; pulsa F para encuadrar, y después Play.")
 return {meshCount=#Data.meshes,playable=playable,npc=npc,library=bank,backup=backup}
end
return Setup
