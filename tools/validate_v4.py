"""Validate/export V4; never rebuild V1/V2/V3 or imply Roblox Studio execution."""
from pathlib import Path
from datetime import datetime,timezone
import hashlib,json,subprocess,sys,zipfile

ROOT=Path(__file__).resolve().parents[1]
DIST=ROOT/'dist'

def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def protect():
    checked={}
    for name,expected in json.loads((ROOT/'backups/pre-v4-protected.json').read_text()).items():
        path=DIST/name
        if path.exists():
            assert sha(path)==expected,'Se modificó una entrega protegida: '+name
            checked[name]=expected
        elif name=='Forgotten.rbxlx' and (DIST/'Forgotten-Primera-Prueba.zip').exists():
            with zipfile.ZipFile(DIST/'Forgotten-Primera-Prueba.zip') as old:
                assert hashlib.sha256(old.read(name)).hexdigest()==expected
            checked[name]=expected
    return checked

def main():
    if (ROOT/"src/shared/PelotocinoRig.luau").exists():
        raise SystemExit("V4 protegida: usa tools/pelotocino/build.py")
    DIST.mkdir(exist_ok=True)
    protected=protect()
    tasks=[('authored_geometry',[sys.executable,'tools/build_character_visuals_v4.py']),
           ('resources',[sys.executable,'tools/check_resources.py']),
           ('v2_regressions',[sys.executable,'tools/check_v2.py']),
           ('v4_motion_catalog_geometry',[sys.executable,'tools/check_v4.py']),
           ('server_five_flows',[sys.executable,'tools/check_round_flow.py']),
           ('import_fallback',[sys.executable,'tools/check_import_fallback.py']),
           ('junkbot_and_avatar_lifecycle',[sys.executable,'tools/check_catalog_character.py']),
           ('static_preview',[sys.executable,'tools/export_preview.py']),
           ('place_xml',[sys.executable,'tools/build_place.py']),
           ('syntax_and_embedded_sources',[sys.executable,'-c',"import sys;sys.path.insert(0,'tools');from check_playable import syntax_check,check_export;syntax_check();check_export()"])]
    logs=[]
    for name,command in tasks:
        result=subprocess.run(command,cwd=ROOT,text=True,capture_output=True)
        logs.append(name+'\n'+result.stdout+result.stderr)
        print(result.stdout,end='',flush=True)
        if result.returncode:
            print(result.stderr,file=sys.stderr);raise SystemExit(result.returncode)
    previews=DIST/'v4/previews'
    manifest=json.loads((previews/'manifest.json').read_text())
    assert manifest['studio_screenshot'] is False
    assert manifest['geometry_sha256']==sha(ROOT/'assets/v4/character-geometry.json'),'Regenera renders: la geometría cambió.'
    assert manifest['rig_sha256']==sha(ROOT/'assets/v4/rig-proportions.json'),'Regenera renders: cambiaron proporciones.'
    assert manifest['faces_sha256']==sha(ROOT/'assets/v4/faces.json'),'Regenera renders: cambió el rostro.'
    assert len(manifest['images'])==7
    for name,digest in manifest['images'].items():assert sha(previews/name)==digest,name
    protect()
    changed=[]
    backup=ROOT/'backups/forgotten-v3-completa.zip'
    if backup.exists():
        with zipfile.ZipFile(backup) as old:
            paths=[]
            for group in ['src','tools','docs','assets']:paths.extend(p for p in (ROOT/group).rglob('*') if p.is_file() and '__pycache__' not in p.parts)
            paths.extend(ROOT/name for name in ['README.md','default.project.json','CHANGELOG-V4.md'])
            for p in sorted(paths):
                name=p.relative_to(ROOT).as_posix()
                if name not in old.namelist() or old.read(name)!=p.read_bytes():changed.append(name)
    report={'version':'V4-prueba','built_at':datetime.now(timezone.utc).isoformat(),
            'studio_executed':False,'rojo_compiled':False,
            'backend':'Lua 5.4 with adapted syntax and explicit API doubles; XML export; Blender technical renders',
            'checks_passed':[name for name,_ in tasks]+['seven_previews_match_geometry'],
            'script_count':len(list((ROOT/'src').rglob('*.luau'))),
            'changed_files_vs_v3_backup':changed,'protected_v1_v2_v3_checked':protected,
            'place_sha256':sha(DIST/'Forgotten-V4.rbxlx'),
            'previews':manifest,
            'pending':['Roblox Studio physics, replication, camera and animation playtests',
                       'Live official catalog, EditableMesh permissions and DataStore',
                       'FPS/memory on desktop and mobile; final models/skins and published audio/portrait/PBR/animation assets',
                       'Expanded maps: routes, stairs, objective travel time and multiplayer balance',
                       'Balance of cane throw and short grab/escape timings']}
    (DIST/'INFORME-V4.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    (DIST/'VALIDACION-V4.txt').write_text('\n\n'.join(logs)+'\nSiete renders: hashes y geometría comprobados.\nNo se ha ejecutado Roblox Studio. Las pruebas locales no sustituyen al motor.\n')
    quick='''FORGOTTEN V4 — ABRIR Y JUGAR

1. Extrae este ZIP en una carpeta de tu computador.
2. Roblox Studio > Archivo > Abrir desde archivo > Forgotten-V4.rbxlx.
3. Pulsa Play/F5. PERSONAJES > elige un superviviente.
4. JUGAR > PROBAR SOLO. Los modelos actuales aparecen al jugar; la edición muestra una maqueta estática.
5. Repara dos generadores (cables, interruptores, tres tirones en verde).
6. Resuelve tres puzles, recoge cápsulas con E y deposítalas junto a la salida.
7. Con los requisitos y 1:00 o menos, atraviesa físicamente la puerta.

WASD: movimiento. Espacio: salto. Shift: correr. E: interactuar/liberarse.
Q/R/F/G/T/Y: habilidades. Z/X: objetos. Clic: ataque del asesino.
M: menú. Tab: marcador. Yellow Guy lanza el bastón con G y lo recupera solo.

Multijugador: Test/Prueba > Server & Clients > 3 clientes para una ronda normal.
Con 2 clientes: LMS de 1:30, puerta a 0:00 y escape físico.
El campamento es SOLO el lobby. La práctica no da monedas ni maestría.
Si dice Progreso de sesión, las compras no se guardan al cerrar.

No necesitas PowerShell, Rojo ni pegar código.
V1, V2 y V3 conservan sus entregas; este archivo es V4.
Pruebas locales y renders de Blender: NO se ha ejecutado Roblox Studio aquí.
Yellow Guy lleva piel amarilla, cabello rubio, chaqueta negra, camiseta azul,
pantalones oscuros y bastón. Los modelos propios son provisionales. Se intenta cargar el Junkbot y
Deathspeaker originales, y Pal Hair oficial, al jugar con acceso a Roblox.

Vistas: docs/V4_VISTAS.md y dist/v4/previews/ (siete PNG).
Pendientes: docs/V4_PRUEBAS_Y_PENDIENTES.md. Cambios: CHANGELOG-V4.md.
src/, tools/, assets/ y default.project.json contienen el proyecto editable.
'''
    (DIST/'COMO_ABRIR-V4.txt').write_text(quick)
    files={'Forgotten-V4.rbxlx':DIST/'Forgotten-V4.rbxlx','LEEME.txt':DIST/'COMO_ABRIR-V4.txt',
           'INFORME-V4.json':DIST/'INFORME-V4.json','VALIDACION-V4.txt':DIST/'VALIDACION-V4.txt',
           'backups/pre-v4-protected.json':ROOT/'backups/pre-v4-protected.json'}
    for folder in ['src','tools','docs','assets']:
        for path in sorted((ROOT/folder).rglob('*')):
            if path.is_file() and '__pycache__' not in path.parts:files[path.relative_to(ROOT).as_posix()]=path
    for name in ['README.md','CHANGELOG-V2.md','CHANGELOG-V3.md','CHANGELOG-V4.md','default.project.json','.gitignore']:files[name]=ROOT/name
    for name in list(manifest['images'])+['manifest.json']:files['dist/v4/previews/'+name]=previews/name
    target=DIST/'Forgotten-V4.zip'
    with zipfile.ZipFile(target,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as package:
        for name,path in sorted(files.items()):package.write(path,name)
    with zipfile.ZipFile(target) as package:
        assert package.testzip() is None
        assert package.read('Forgotten-V4.rbxlx')==(DIST/'Forgotten-V4.rbxlx').read_bytes()
        assert 'src/server/init.server.luau' in package.namelist()
        assert len([n for n in package.namelist() if n.startswith('dist/v4/previews/') and n.endswith('.png')])==7
    (DIST/'SHA256-V4.json').write_text(json.dumps({name:sha(DIST/name) for name in ['Forgotten-V4.rbxlx','Forgotten-V4.zip']},indent=2)+'\n')
    protect()
    print(f'V4: ZIP íntegro de {target.stat().st_size:,} bytes; {len(protected)} artefactos anteriores intactos. Studio pendiente.')

if __name__=='__main__':main()
