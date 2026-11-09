"""Build import-ready delivery; uploading assets and Studio playtests remain manual."""
from pathlib import Path
from datetime import datetime,timezone
import sys,json,subprocess,hashlib,zipfile,xml.etree.ElementTree as E
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from pelotocino_import.check import protected
from pelotocino.build import check_sequences
from check_playable import run_lua
OUT=ROOT/'dist/pelotocino-importado';DIST=ROOT/'dist'
PLACE='Forgotten-Pelotocino-MeshParts.rbxlx';ZIP='Forgotten-Pelotocino-MeshParts.zip'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()

def models():
 packages=[]
 for name in ['Pelotocino-R15.rbxmx','Pelotocino-NPC.rbxmx']:
  tree=E.parse(OUT/name);items=tree.findall('.//Item')
  refs=[n.attrib['referent']for n in items];assert len(refs)==len(set(refs))
  for ref in tree.findall('.//Ref'):assert ref.text in refs
  assert len([n for n in items if n.attrib['class']=='Part'])==16
  assert len([n for n in items if n.attrib['class']=='Motor6D'])==15
  package={n.find("Properties/string[@name='Name']").text:n.find('Properties/ProtectedString').text for n in items if n.attrib['class']=='ModuleScript'}
  assert set(package)=={'PelotocinoMeshData','PelotocinoMotion','PelotocinoRig','PelotocinoRenderer','PelotocinoMeshLibrary'}
  for key,source in package.items():assert source==(ROOT/'src/shared'/(key+'.luau')).read_text()
  for n in items:
   if n.attrib['class']=='Script':run_lua(n.find('Properties/ProtectedString').text,'plantilla '+name+' script syntax',execute=False)
  packages.append(package);check_sequences(tree)
 assert packages[0]==packages[1]
 check_sequences(E.parse(OUT/'Pelotocino-Animations.rbxmx'))
 place=E.parse(DIST/PLACE);refs=[n.attrib['referent']for n in place.findall('.//Item')if 'referent'in n.attrib]
 assert len(refs)==len(set(refs))
 for ref in place.findall('.//Ref'):assert ref.text in refs
 setup=[n for n in place.findall('.//Item[@class="ModuleScript"]')if n.find("Properties/string[@name='Name']").text=='PelotocinoSetup']
 assert len(setup)==1 and setup[0].find('Properties/ProtectedString').text==(ROOT/'tools/pelotocino_import/StudioInstall.luau').read_text()
 print('PASS: dos plantillas con fuentes idénticas, 15 articulaciones, diez clips y prueba con instalador actual')

def media():
 folder=OUT/'fuentes-3d';m=json.loads((folder/'mesh-manifest.json').read_text())
 assert m['source_geometry_sha256']==sha(ROOT/'assets/pelotocino/geometry.json')and m['geometry_changed']is False
 assert len(m['meshes'])==25 and m['triangles']==17496
 for name,digest in m['textures'].items():assert sha(folder/name)==digest
 assert m['fbx_sha256']==sha(folder/'Pelotocino-Importar.fbx')
 assert m['blend_sha256']==sha(folder/'Pelotocino-Importar.blend')
 checked=json.loads((OUT/'fbx-validation.json').read_text())
 assert checked['fbx_sha256']==m['fbx_sha256']and checked['studio_executed']is False
 assert checked['geometry_max_error']<1e-5 and checked['uv_and_base_color_image_checked']
 for name,digest in checked['images'].items():assert sha(OUT/'previews'/name)==digest
 print('PASS: FBX, texturas UV y vistas de la geometría original verificados')
 return checked

def main():
 initial=protected();logs=[]
 for p in (ROOT/'tools').rglob('*.py'):compile(p.read_text(),str(p),'exec')
 tasks=[('MeshParts_installation',[sys.executable,'tools/pelotocino_import/check.py']),
  ('rules_economy_objectives_maps_combat',[sys.executable,'tools/check_v2.py']),
  ('five_server_flows',[sys.executable,'tools/check_round_flow.py']),
  ('animation_effects_catalog',[sys.executable,'-c',"import sys;sys.path.insert(0,'tools');from check_v3 import motion,effects,catalog;motion();effects();catalog()"]),
  ('resources',[sys.executable,'tools/check_resources.py']),
  ('syntax',[sys.executable,'-c',"import sys;sys.path.insert(0,'tools');from check_playable import syntax_check;syntax_check()"]),
  ('exports',[sys.executable,'tools/pelotocino_import/export.py'])]
 for name,command in tasks:
  p=subprocess.run(command,cwd=ROOT,text=True,capture_output=True);logs.append(name+'\n'+p.stdout+p.stderr)
  print(p.stdout,end='',flush=True)
  if p.returncode:print(p.stderr,file=sys.stderr);raise SystemExit(p.returncode)
 models();checked=media();assert protected()==initial
 report={'delivery':'Pelotocino con MeshParts importadas','built_at':datetime.now(timezone.utc).isoformat(),
  'base_commit':'175ce29d12ab79398dd9602ece406fed3b005b81','studio_executed':False,'manual_import_required':True,
  'uploaded_asset_ids_included':False,'templates_before_import':True,'mesh_count_after_install':25,
  'backend':'Lua 5.4 adaptado con dobles de APIs; XML/ZIP; Blender FBX round-trip',
  'checks_passed':[name for name,_ in tasks]+['model_packages_identical','clip_sequences','fbx_geometry_textures','prior_files_unchanged'],
  'protected_files':initial,'fbx_validation':checked,
  'files':{p.relative_to(DIST).as_posix():{'bytes':p.stat().st_size,'sha256':sha(p)}for p in [DIST/PLACE,*sorted(OUT.glob('*.rbxmx'))]},
  'pending':['Importar y subir FBX/texturas desde Studio con el propietario correcto; ejecutar instalador en edición',
   'Verificar visibilidad, orientación, cámara, física, animaciones y guardado en Studio',
   'Probar combate/rastreador y replicación con varios clientes; revisar rendimiento y permisos online']}
 (OUT/'INFORME.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
 (OUT/'VALIDACION.txt').write_text('\n'.join(logs)+'\nPASS: plantillas, FBX, texturas y archivos protegidos. Importación y prueba real en Studio pendientes.\n')
 with zipfile.ZipFile(DIST/ZIP,'w',zipfile.ZIP_DEFLATED,compresslevel=9)as z:
  z.write(DIST/PLACE,PLACE)
  z.write(ROOT/'docs/pelotocino-importado/IMPORTAR.md','LEEME-IMPORTAR.md')
  z.write(OUT/'INSTALAR-EN-STUDIO.txt','INSTALAR-EN-STUDIO.txt')
  for p in sorted(OUT.glob('*.rbxmx')):z.write(p,p.name)
  for p in sorted((OUT/'fuentes-3d').rglob('*')):
   if p.is_file()and p.suffix!='.blend1':z.write(p,'fuentes-3d/'+p.relative_to(OUT/'fuentes-3d').as_posix())
  for folder in ['src','tools','assets','docs']:
   for p in sorted((ROOT/folder).rglob('*')):
    if p.is_file()and '__pycache__'not in p.parts:z.write(p,p.relative_to(ROOT))
  for p in sorted(OUT.rglob('*')):
   if p.is_file()and p.suffix!='.blend1':z.write(p,p.relative_to(ROOT))
  for name in ['README.md','default.project.json','backups/pre-pelotocino-import-protected.json','backups/pre-pelotocino-protected.json','dist/preview-scene-v4.json']:
   z.write(ROOT/name,name)
 with zipfile.ZipFile(DIST/ZIP)as z:
  assert z.testzip()is None and len(z.namelist())==len(set(z.namelist()))
  assert z.read(PLACE)==(DIST/PLACE).read_bytes()
  assert z.read('fuentes-3d/Pelotocino-Importar.fbx')==(OUT/'fuentes-3d/Pelotocino-Importar.fbx').read_bytes()
  for p in (ROOT/'src').rglob('*.luau'):assert z.read(p.relative_to(ROOT).as_posix())==p.read_bytes()
 (DIST/'SHA256-Pelotocino-MeshParts.txt').write_text('\n'.join(sha(DIST/n)+'  '+n for n in [PLACE,ZIP])+'\n')
 print('PASS: ZIP con prueba, plantillas, FBX, texturas, instalador y fuentes; contenido íntegro.')

if __name__=='__main__':main()
