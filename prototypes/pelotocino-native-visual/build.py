"""Package the isolated native-avatar workshop. Never builds the FORGOTTEN game."""
from pathlib import Path
import hashlib, json, subprocess, zipfile, xml.etree.ElementTree as E

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT/'dist/pelotocino-native-visual'
BASE = '5d78fda53c928fdd173583409c21cdf4862b2dd2'
PLACE = 'Pelotocino-R15-Taller.rbxlx'
MODEL = 'Herramientas-Pelotocino-R15.rbxmx'
ZIP = 'Pelotocino-R15-Prototipo-Visual.zip'
serial = 0

def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()

def prop(node, kind, name, value):
    item = E.SubElement(node.find('Properties'), kind, name=name)
    item.text = str(value).lower() if isinstance(value, bool) else str(value)
    return item

def item(parent, kind, name):
    global serial
    serial += 1
    node = E.SubElement(parent, 'Item', {'class': kind, 'referent': 'RBX_NATIVE_'+str(serial)})
    E.SubElement(node, 'Properties'); prop(node, 'string', 'Name', name)
    return node

def vec(node, name, values):
    p = prop(node, 'Vector3', name, ''); p.text = None
    for axis, value in zip('XYZ', values): E.SubElement(p, axis).text = str(value)

def frame(node, name, position):
    p = prop(node, 'CoordinateFrame', name, ''); p.text = None
    for axis, value in zip('XYZ', position): E.SubElement(p, axis).text = str(value)
    for i in range(3):
        for j in range(3): E.SubElement(p, f'R{i}{j}').text = str(int(i == j))

def package(parent):
    folder = item(parent, 'Folder', 'PelotocinoVisualWorkshop')
    for name in ['Config', 'Catalog', 'Workshop']:
        node = item(folder, 'ModuleScript', name)
        prop(node, 'ProtectedString', 'Source', (HERE/(name+'.luau')).read_text())
    return folder

def save(root, name):
    E.indent(root); E.ElementTree(root).write(OUT/name, encoding='utf-8', xml_declaration=True)

def main():
    OUT.mkdir(parents=True, exist_ok=True)
    # Every existing tracked file is protected, not only V4 or gameplay constants.
    paths = subprocess.check_output(['git','ls-tree','-r','--name-only',BASE], cwd=ROOT, text=True).splitlines()
    changed = subprocess.check_output(['git','diff',BASE,'--name-only','--', *paths], cwd=ROOT, text=True)
    assert not changed, 'Previous tracked files modified: '+changed
    protected = {path: sha(ROOT/path) for path in paths}
    root = E.Element('roblox', version='4')
    world = item(root, 'Workspace', 'Workspace')
    prop(world, 'bool', 'StreamingEnabled', False)
    floor = item(world, 'Part', 'Suelo_Taller')
    vec(floor, 'size', (30, 1, 20)); frame(floor, 'CFrame', (0, -.5, 0))
    prop(floor, 'bool', 'Anchored', True); prop(floor, 'bool', 'Locked', True)
    color = prop(floor, 'Color3', 'Color', ''); color.text = None
    for k, v in zip('RGB', (.13, .15, .18)): E.SubElement(color, k).text = str(v)
    light = item(root, 'Lighting', 'Lighting')
    prop(light, 'float', 'Brightness', 2); prop(light, 'float', 'ClockTime', 12)
    storage = item(root, 'ReplicatedStorage', 'ReplicatedStorage'); package(storage)
    server = item(root, 'ServerScriptService', 'ServerScriptService')
    script = item(server, 'Script', 'VisualReviewOnly')
    prop(script, 'ProtectedString', 'Source', (HERE/'Review.server.luau').read_text())
    player = item(root, 'StarterPlayer', 'StarterPlayer')
    scripts = item(player, 'StarterPlayerScripts', 'StarterPlayerScripts')
    local = item(scripts, 'LocalScript', 'VisualViews')
    prop(local, 'ProtectedString', 'Source', (HERE/'Views.client.luau').read_text())
    save(root, PLACE)
    root = E.Element('roblox', version='4'); package(root); save(root, MODEL)
    (OUT/'LEEME.md').write_text((HERE/'README.md').read_text())
    (OUT/'INSTALAR.txt').write_text('Con Play detenido, selecciona el Rig R15 nativo y el Model FBX de accesorios (Ctrl+clic).\nAbre Command Bar (Ctrl+9), pega y ejecuta:\n\nrequire(game:GetService("ReplicatedStorage").PelotocinoVisualWorkshop.Workshop).install()\n\nConsulta LEEME.md antes de empezar. El montaje oficial requiere Roblox Studio.\n')
    report = {'base_commit': BASE, 'native_avatar_assembled_in_studio': False,
              'studio_executed': False, 'avatar_screenshots_included': False,
              'accessories_rendered_in_blender': True,
              'scope': 'Visual workshop only; native rig and catalog assets require manual Studio assembly',
              'animations_changed': False, 'gameplay_changed': False,
              'protected_previous_files': protected,
              'assets': json.loads((OUT/'accesorios/manifest.json').read_text()),
              'manual_validation': ['Official native R15, Pal Hair and clothing retrieval',
                  'FBX import and resource permissions', 'Backpack fit and reference likeness',
                  'Front/side/back captures in Studio', 'Save and reopen installed avatar']}
    (OUT/'INFORME.json').write_text(json.dumps(report, indent=2, ensure_ascii=False)+'\n')
    subprocess.run(['python3', str(HERE/'check.py')], cwd=ROOT, check=True)
    with zipfile.ZipFile(OUT/ZIP, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        for p in sorted(OUT.rglob('*')):
            if p.is_file() and p.name not in [ZIP, 'SHA256.txt'] and p.suffix != '.blend1':
                archive.write(p, p.relative_to(OUT))
        for p in sorted(HERE.iterdir()):
            if p.is_file(): archive.write(p, 'fuentes-taller/'+p.name)
    with zipfile.ZipFile(OUT/ZIP) as archive:
        assert archive.testzip() is None
        assert len(archive.namelist()) == len(set(archive.namelist()))
        assert archive.read(PLACE) == (OUT/PLACE).read_bytes()
        assert archive.read('accesorios/Accesorios-Pelotocino.fbx') == (OUT/'accesorios/Accesorios-Pelotocino.fbx').read_bytes()
    (OUT/'SHA256.txt').write_text('\n'.join(sha(OUT/name)+'  '+name for name in [PLACE, MODEL, ZIP, 'accesorios/Accesorios-Pelotocino.fbx'])+'\n')
    assert protected == {p: sha(ROOT/p) for p in paths}
    print('PASS: isolated XML/model/ZIP workshop; all', len(protected), 'previous tracked files unchanged.')

if __name__ == '__main__': main()
