"""Generate import-ready place/models without touching historical deliveries."""
from pathlib import Path
import sys,copy,xml.etree.ElementTree as E
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from pelotocino import export_model as old
from build_place import build
from check_playable import check_export
OUT=ROOT/'dist/pelotocino-importado';OUT.mkdir(exist_ok=True)
PLACE=ROOT/'dist/Forgotten-Pelotocino-MeshParts.rbxlx'

def main():
 old.OUT=OUT
 model_roots=[]
 for npc in [False,True]:
  path=old.model_export(npc);tree=E.parse(path)
  for node in tree.findall('.//Item[@class="ModuleScript"]'):
   name=node.find("Properties/string[@name='Name']")
   if name.text=='PelotocinoSurface':
    name.text='PelotocinoMeshLibrary';node.find('Properties/ProtectedString').text=(ROOT/'src/shared/PelotocinoMeshLibrary.luau').read_text()
  # Replace, rather than duplicate, the serialized model metadata.
  model=tree.getroot().find('Item');props=model.find('Properties')
  props.remove(props.find("BinaryString[@name='AttributesSerialize']"))
  old.attributes(model,{'PelotocinoR15':True,'CharacterIdentity':'pelotocino','NPC':npc,'Placeholder':False,
   'ModelStatus':'Plantilla R15 · importa el FBX e instala las MeshParts primero'})
  E.indent(tree);tree.write(path,encoding='utf-8',xml_declaration=True);model_roots.append(copy.deepcopy(model))
 root=E.Element('roblox',version='4');old.sequences(root);E.indent(root)
 E.ElementTree(root).write(OUT/'Pelotocino-Animations.rbxmx',encoding='utf-8',xml_declaration=True)
 build(PLACE.name);check_export(PLACE.name)
 tree=E.parse(PLACE);root=tree.getroot()
 rs=next(n for n in root.findall('Item')if n.attrib['class']=='ReplicatedStorage')
 ss=next(n for n in root.findall('Item')if n.attrib['class']=='ServerStorage')
 bank=old.item(rs,'Folder','PelotocinoImportedMeshes')
 old.attributes(bank,{'InstallationRequired':True})
 setup=old.item(rs,'ModuleScript','PelotocinoSetup')
 old.prop(setup,'ProtectedString','Source',(ROOT/'tools/pelotocino_import/StudioInstall.luau').read_text())
 templates=old.item(ss,'Folder','PelotocinoSetupTemplates')
 for model in model_roots:templates.append(model)
 E.indent(tree);tree.write(PLACE,encoding='utf-8',xml_declaration=True)
 (OUT/'INSTALAR-EN-STUDIO.txt').write_text('Con el FBX importado seleccionado y Play detenido, pulsa Ctrl+9 (Windows), o Window > Script > Command Bar. Pega y ejecuta esta línea en la barra de comandos:\n\nrequire(game:GetService("ReplicatedStorage"):WaitForChild("PelotocinoSetup")).install()\n')
 print('Exportados: prueba con instalador y dos plantillas R15. Importación en Studio pendiente; no hay AssetIds inventados.')

if __name__=='__main__':main()
