"""Check, export and package V2 without overwriting V1 artifacts."""
from pathlib import Path
from datetime import datetime
from zoneinfo import ZoneInfo
import hashlib,json,subprocess,sys,zipfile

ROOT=Path(__file__).resolve().parents[1]
PROTECTED={
    'Forgotten.rbxlx':'c3f63b1cf87499ed5f8e2fefe77544682ccac80c3643cc1273e52bab3d3b8159',
    'Forgotten-Primera-Prueba.zip':'dccfc55547d2facdf6cae75193da3dfe497f6fe05f95f0954dec5137c1745020'}

def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def protect():
    checked={}
    for name,expected in PROTECTED.items():
        path=ROOT/'dist'/name
        if path.exists():
            assert sha(path)==expected, 'La V1 protegida cambió: '+name
            checked[name]=expected
    return checked

def main():
    if (ROOT/'src/shared/CharacterMotion.luau').exists():
        raise SystemExit('La V2 está protegida. Este proyecto ya es V3; utiliza tools/validate_v3.py.')
    protected=protect()
    tasks=[('resources',[sys.executable,'tools/check_resources.py']),
           ('v2_behavior',[sys.executable,'tools/check_v2.py']),
           ('server_flow',[sys.executable,'tools/check_round_flow.py']),
           ('import_fallback',[sys.executable,'tools/check_import_fallback.py']),
           ('catalog_native_rig',[sys.executable,'tools/check_catalog_character.py']),
           ('preview',[sys.executable,'tools/export_preview.py']),
           ('place_xml',[sys.executable,'tools/build_place.py']),
           ('syntax_and_embedded_sources',[sys.executable,'-c',"import sys;sys.path.insert(0,'tools');from check_playable import syntax_check,check_export;syntax_check();check_export()"])]
    logs=[]
    for name,command in tasks:
        result=subprocess.run(command,cwd=ROOT,text=True,capture_output=True)
        logs.append(name+'\n'+result.stdout+result.stderr)
        print(result.stdout,end='',flush=True)
        if result.returncode:
            print(result.stderr,file=sys.stderr)
            raise SystemExit(result.returncode)
    protect()
    dist=ROOT/'dist'
    (dist/'VALIDACION-V2.txt').write_text('\n\n'.join(logs)+'\nNo se ha ejecutado Roblox Studio. Lua 5.4 y APIs simuladas no sustituyen al motor.\n')
    changed=[]
    backup=ROOT/'backups/primera-prueba-v1-completa.zip'
    if backup.exists():
        with zipfile.ZipFile(backup) as old:
            for group in ['src','tools','docs']:
                for p in sorted((ROOT/group).rglob('*')):
                    if p.is_file() and '__pycache__' not in p.parts:
                        name=str(p.relative_to(ROOT))
                        if name not in old.namelist() or old.read(name)!=p.read_bytes():changed.append(name)
            for name in ['README.md','default.project.json','CHANGELOG-V2.md']:
                if name not in old.namelist() or old.read(name)!=(ROOT/name).read_bytes():changed.append(name)
    report={'version':'V2-prueba','built_at':datetime.now(ZoneInfo('America/Santiago')).isoformat(),
            'studio_executed':False,'rojo_compiled':False,'backend':'Lua 5.4; explicit Roblox API doubles; adapted syntax, not Luau compiler',
            'checks_passed':[name for name,_ in tasks], 'script_count':len(list((ROOT/'src').rglob('*.luau'))),
            'changed_files':changed,'protected_v1_checked':protected,
            'place_sha256':sha(dist/'Forgotten-V2.rbxlx'),
            'pending':['Real Studio execution, multiplayer replication and physical collision tests',
                       'Live DataStore and original Junkbot catalog access',
                       'Final models, milestone art, portraits and authorized animation/audio assets',
                       'Art pass, device performance and balance playtests']}
    (dist/'INFORME-V2.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    quick='''FORGOTTEN V2 — ABRIR Y JUGAR

1. Extrae este ZIP en una carpeta de tu computador.
2. Abre Roblox Studio > Archivo > Abrir desde archivo > Forgotten-V2.rbxlx.
3. Pulsa Play/F5. En PERSONAJES elige un superviviente; en MAPAS vota un escenario.
4. Vuelve a JUGAR y pulsa PROBAR SOLO.
5. Repara dos generadores: cables en orden, interruptores indicados y tres tirones en verde.
6. Resuelve tres puzles, recoge sus cápsulas con E y llévalas al depósito junto a la salida.
7. Con los requisitos completos y 1:00 o menos, cruza físicamente la salida.

WASD: moverse. Espacio: saltar. Shift: correr. E: interactuar.
Q/R/F/G/T/Y: habilidades. Z/X: objetos. Clic: ataque del asesino.
M: menú. Tab: marcador. El HUD también tiene botones.

Multijugador: Test/Prueba > Server & Clients > 3 clientes para normal de 4:00.
Con 2 clientes se activa LMS: 1:30, puerta a 0:00 y escape físico.
El campamento es solo el lobby. La práctica no da monedas ni maestría.
La tienda usa 100 monedas iniciales experimentales.
Si dice Progreso de sesión, las compras no se guardarán al cerrar.

No necesitas PowerShell, Rojo ni pegar código.
Comprobado localmente con pruebas simuladas; falta probarlo realmente en Studio.
Hay modelos/skins provisionales. Faltan audios, retratos y animaciones finales.
Lee docs/V2_PRUEBAS_Y_PENDIENTES.md y CHANGELOG-V2.md.
La carpeta proyecto contiene las fuentes para seguir editando.
'''
    (dist/'COMO_ABRIR-V2.txt').write_text(quick)
    files={'Forgotten-V2.rbxlx':dist/'Forgotten-V2.rbxlx','LEEME.txt':dist/'COMO_ABRIR-V2.txt',
           'CHANGELOG-V2.md':ROOT/'CHANGELOG-V2.md','docs/V2_PRUEBAS_Y_PENDIENTES.md':ROOT/'docs/V2_PRUEBAS_Y_PENDIENTES.md',
           'VALIDACION-V2.txt':dist/'VALIDACION-V2.txt','INFORME-V2.json':dist/'INFORME-V2.json'}
    for folder in ['src','tools','docs','assets']:
        for path in sorted((ROOT/folder).rglob('*')):
            if path.is_file() and '__pycache__' not in path.parts:files['proyecto/'+str(path.relative_to(ROOT))]=path
    for name in ['README.md','CHANGELOG-V2.md','default.project.json','.gitignore']:
        files['proyecto/'+name]=ROOT/name
    target=dist/'Forgotten-V2.zip'
    with zipfile.ZipFile(target,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as output:
        for name,path in files.items():output.write(path,name)
    with zipfile.ZipFile(target) as package:
        assert package.testzip() is None
        assert package.read('Forgotten-V2.rbxlx')==(dist/'Forgotten-V2.rbxlx').read_bytes()
        assert 'proyecto/src/server/init.server.luau' in package.namelist()
    sums={name:sha(dist/name) for name in ['Forgotten-V2.rbxlx','Forgotten-V2.zip']}
    (dist/'SHA256-V2.json').write_text(json.dumps(sums,indent=2)+'\n')
    protect()
    print(f'V2 empaquetada: {target.stat().st_size:,} bytes; V1 protegida. Roblox Studio pendiente.')

if __name__=='__main__':main()
