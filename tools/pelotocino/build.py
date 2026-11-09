"""Validate/package only Pelotocino, preserving every V1–V4 artifact.
No Studio execution, uploaded resource IDs or rendering permissions are implied.
"""
from pathlib import Path
from datetime import datetime, timezone
import sys, subprocess, hashlib, json, zipfile, math
import xml.etree.ElementTree as E

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from pelotocino.check import art
from check_playable import run_lua

DIST=ROOT/'dist'; OUT=DIST/'pelotocino'
PLACE='Forgotten-Pelotocino-R15.rbxlx'
ZIP='Forgotten-Pelotocino-R15.zip'
BASE='304894192ab5829fbd6f0a05e569bc699525c4e6'

def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def named(node):return node.find("Properties/string[@name='Name']").text

def check_models():
    packages=[]
    for filename in ['Pelotocino-R15.rbxmx','Pelotocino-NPC.rbxmx']:
        tree=E.parse(OUT/filename); nodes=tree.findall('.//Item')
        ids=[n.attrib['referent']for n in nodes]
        assert len(ids)==len(set(ids))
        for ref in tree.findall('.//Ref'):assert ref.text in ids
        physical=[n for n in nodes if n.attrib['class']=='Part']
        assert len(physical)==16
        assert all(n.find("Properties/float[@name='Transparency']").text=='1' for n in physical)
        motors=[n for n in nodes if n.attrib['class']=='Motor6D']; assert len(motors)==15
        graph={n.attrib['referent']:set()for n in physical}
        for n in motors:
            a=n.find("Properties/Ref[@name='Part0']").text;b=n.find("Properties/Ref[@name='Part1']").text
            graph[a].add(b);graph[b].add(a)
        reached=set();queue=[tree.find('.//Properties/Ref[@name="PrimaryPart"]').text]
        while queue:
            node=queue.pop()
            if node in reached:continue
            reached.add(node);queue.extend(graph[node]-reached)
        assert len(reached)==16
        h=next(n for n in nodes if n.attrib['class']=='Humanoid')
        assert h.find("Properties/token[@name='RigType']").text=='1'
        scripts={named(n):n.find('Properties/ProtectedString').text for n in nodes if n.attrib['class'] in ['Script','ModuleScript']}
        assert len(scripts)==7
        for name in ['PelotocinoMeshData','PelotocinoRig','PelotocinoMotion','PelotocinoRenderer','PelotocinoSurface']:
            assert scripts[name]==(ROOT/'src/shared'/(name+'.luau')).read_text()
        for file,name in [('Standalone.client.luau','PelotocinoAnimate'),('Standalone.server.luau','PelotocinoPreview')]:
            assert scripts[name]==(ROOT/'tools/pelotocino'/file).read_text()
            run_lua(scripts[name],filename+': '+name+' syntax',execute=False)
        packages.append(scripts)
        check_sequences(tree)
    assert packages[0]==packages[1],'NPC and playable rig must share all mesh/motion sources'
    check_sequences(E.parse(OUT/'Pelotocino-Animations.rbxmx'))
    print('PASS: R15/NPC idénticos, 16 cuerpos invisibles, 15 articulaciones conectadas, scripts y diez secuencias')

def check_sequences(tree):
    seq=[n for n in tree.findall('.//Item')if n.attrib['class']=='KeyframeSequence']
    assert {named(n)for n in seq}=={'idle','walk','run','sprint','jump','fall','pan','baconThrow','detector','hit'}
    for n in seq:
        keys=[k for k in n.findall('Item')if k.attrib['class']=='Keyframe']
        times=[float(k.find("Properties/float[@name='Time']").text)for k in keys]
        assert times[0]==0 and all(b>a for a,b in zip(times,times[1:]))
        for k in keys:
            poses=[p for p in k.findall('.//Item')if p.attrib['class']=='Pose'];assert len(poses)==16
            for frame in k.findall('.//CoordinateFrame'):
                assert all(math.isfinite(float(v.text))for v in frame)
        if named(n) in ['pan','baconThrow']:
            marked=[k for k in keys if k.find('Item[@class="KeyframeMarker"]')is not None]
            assert len(marked)==1
            assert abs(float(marked[0].find("Properties/float[@name='Time']").text)-(.22 if named(n)=='pan'else .45))<.02

def check_media():
    previews=json.loads((OUT/'previews/manifest.json').read_text())
    assert previews['studio_executed'] is False and previews['geometry_sha256']==sha(ROOT/'assets/pelotocino/geometry.json')
    assert len(previews['images'])==5
    for name,digest in previews['images'].items():assert sha(OUT/'previews'/name)==digest
    demo=json.loads((OUT/'demo-manifest.json').read_text())
    for key,path in [('geometry','assets/pelotocino/geometry.json'),('samples','assets/pelotocino/animations.json'),('motion','src/shared/PelotocinoMotion.luau')]:
        assert demo[key+'_sha256']==sha(ROOT/path),'Demostración desactualizada: '+key
    assert demo['studio_executed']is False and demo['frames']==89 and demo['fps']==12
    # Frame files are optional source intermediates, deliberately excluded from delivery.
    if (OUT/'demo-frames').exists():
        for name,digest in demo['frame_sha256'].items():assert sha(OUT/'demo-frames'/name)==digest
    video=OUT/'Pelotocino-Animaciones-Blender.mp4'
    result=subprocess.run(['ffprobe','-v','error','-show_entries','stream=codec_name,nb_frames,width,height','-of','json',str(video)],capture_output=True,text=True,check=True)
    stream=json.loads(result.stdout)['streams'][0]
    assert stream['codec_name']=='h264' and int(stream['nb_frames'])==89 and stream['width']==640 and stream['height']==800
    print('PASS: cinco vistas y vídeo Blender de la geometría y las animaciones entregadas')
    return {'previews':previews,'demo':demo,'video_sha256':sha(video)}

def check_preserved_sources():
    # Includes every other character's art, all maps, economy, rules and skill values.
    paths=['src/shared/AbilityConfig.luau','src/shared/AbilityTiming.luau','src/shared/CharacterVisuals.luau',
           'src/shared/RoundRules.luau','src/shared/MapCatalog.luau','src/shared/EconomyConfig.luau',
           'src/shared/ChallengeRules.luau','src/shared/Stamina.luau','src/shared/Roster.luau',
           'src/shared/ShopCatalog.luau','src/shared/ProfileData.luau','src/shared/Music.luau','src/shared/Cosmetics.luau']
    paths=[p for p in paths if (ROOT/p).exists()]
    paths.extend(p.relative_to(ROOT).as_posix()for p in (ROOT/'assets/v4').rglob('*')if p.is_file())
    paths.extend(p.relative_to(ROOT).as_posix()for p in (ROOT/'src/server').rglob('*.luau')if p.name!='Abilities.luau')
    checked=[]
    if (ROOT/'.git').exists():
        for path in paths:
            old=subprocess.run(['git','show',BASE+':'+path],capture_output=True,check=True).stdout
            assert old==(ROOT/path).read_bytes(),'Modificación fuera del alcance: '+path
            checked.append(path)
    print('PASS: '+str(len(checked))+' fuentes de V4 preservadas (reglas, mapas y recursos de los demás personajes)')
    return checked

def main():
    protected=art();preserved=check_preserved_sources(); logs=[]
    for p in (ROOT/'tools').rglob('*.py'):compile(p.read_text(),str(p),'exec')
    tasks=[
      ('resources',[sys.executable,'tools/check_resources.py']),
      ('rules_economy_maps_combat',[sys.executable,'tools/check_v2.py']),
      ('pelotocino_mesh_rig_equipment',[sys.executable,'tools/pelotocino/check.py']),
      ('server_five_flows',[sys.executable,'tools/check_round_flow.py']),
      ('animation_catalog_effects',[sys.executable,'-c',"import sys;sys.path.insert(0,'tools');from check_v3 import motion,catalog,effects;motion();catalog();effects()"]),
      ('catalog_lifecycle',[sys.executable,'tools/check_catalog_character.py']),
      ('import_fallback',[sys.executable,'tools/check_import_fallback.py']),
      ('place_xml',[sys.executable,'tools/build_place.py']),
      ('standalone_exports',[sys.executable,'tools/pelotocino/export_model.py']),
      ('syntax_embedded_sources',[sys.executable,'-c',"import sys;sys.path.insert(0,'tools');from check_playable import syntax_check,check_export;syntax_check();check_export('"+PLACE+"')"])]
    for name,command in tasks:
        result=subprocess.run(command,cwd=ROOT,capture_output=True,text=True)
        logs.append(name+'\n'+result.stdout+result.stderr)
        print(result.stdout,end='',flush=True)
        if result.returncode:
            print(result.stderr,file=sys.stderr);raise SystemExit(result.returncode)
    check_models();media=check_media();assert art()==protected
    report={'delivery':'Pelotocino R15 sobre V4','built_at':datetime.now(timezone.utc).isoformat(),
      'studio_executed':False,'rojo_compiled':False,'base_commit':BASE,
      'validation':'Lua 5.4 con sintaxis adaptada y dobles explícitos de APIs; XML/ZIP; renders Blender',
      'checks_passed':[name for name,_ in tasks]+['same_NPC_player','ten_keyframe_sequences','five_previews_video'],
      'scripts':len(list((ROOT/'src').rglob('*.luau'))),'protected_deliveries':protected,'preserved_sources':preserved,
      'files':{p.relative_to(DIST).as_posix():{'sha256':sha(p),'bytes':p.stat().st_size}for p in [DIST/PLACE,*sorted(OUT.glob('*.rbxmx')),OUT/'Pelotocino-Meshes.fbx',OUT/'Pelotocino.blend',OUT/'Pelotocino-Animaciones-Blender.mp4']},
      'media':media,'pending':['Prueba real en Roblox Studio: permisos Mesh & Image APIs, física, cámara y replicación',
        'Comparar fidelidad visual con la referencia; no se certifica 1:1',
        'Importación/publicación de MeshParts y animaciones definitivas bajo el propietario, si se desea eliminar EditableMesh',
        'Perfilado de FPS/memoria en ordenador y móvil, y DataStore real']}
    (DIST/'INFORME-Pelotocino-R15.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    (DIST/'VALIDACION-Pelotocino-R15.txt').write_text('\n'.join(logs)+'\nPASS: modelos, medios y entregas protegidas. Roblox Studio no ejecutado.\n')
    readme=(ROOT/'docs/pelotocino/ABRIR_Y_PROBAR.md').read_text()
    with zipfile.ZipFile(DIST/ZIP,'w',zipfile.ZIP_DEFLATED,compresslevel=9)as z:
        z.write(DIST/PLACE,PLACE);z.writestr('LEEME-PELOTOCINO.md',readme)
        for p in sorted(OUT.glob('*.rbxmx')):z.write(p,p.name)
        for name in ['Pelotocino-Meshes.fbx','Pelotocino.blend']:z.write(OUT/name,'fuentes-3d/'+name)
        # Preserve relative paths so source rebuilds and preview links work after extraction.
        for folder in ['src','tools','assets','docs']:
            for p in sorted((ROOT/folder).rglob('*')):
                if p.is_file()and '__pycache__' not in p.parts:z.write(p,p.relative_to(ROOT))
        for name in ['README.md','default.project.json','backups/pre-pelotocino-protected.json',
                     'dist/preview-scene-v4.json','dist/INFORME-Pelotocino-R15.json','dist/VALIDACION-Pelotocino-R15.txt']:
            z.write(ROOT/name,name)
        for p in sorted(OUT.rglob('*')):
            if p.is_file()and 'demo-frames'not in p.parts and p.suffix!='.blend1':z.write(p,p.relative_to(ROOT))
    with zipfile.ZipFile(DIST/ZIP)as z:
        assert z.testzip()is None
        assert len(z.namelist())==len(set(z.namelist()))
        assert z.read(PLACE)==(DIST/PLACE).read_bytes()
        for p in (ROOT/'src').rglob('*.luau'):assert z.read(p.relative_to(ROOT).as_posix())==p.read_bytes()
        assert all(not name.startswith('/') and '..'not in Path(name).parts for name in z.namelist())
    (DIST/'SHA256-Pelotocino-R15.txt').write_text('\n'.join(sha(DIST/name)+'  '+name for name in [PLACE,ZIP])+'\n')
    print('PASS: ZIP íntegro, fuentes actuales y .rbxlx coincidente: '+str(DIST/ZIP))

if __name__=='__main__':main()
