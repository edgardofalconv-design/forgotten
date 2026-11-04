"""Exportador XML sin dependencias. Alternativa a rojo build para este proyecto."""
from pathlib import Path
import xml.etree.ElementTree as ET
from static_preview import populate
ROOT = Path(__file__).resolve().parents[1]

def build(target_name="Forgotten-V4.rbxlx"):
    tree = ET.Element('roblox', version='4')
    def item(parent, cls, name, source=None):
        node = ET.SubElement(parent, 'Item', {'class': cls})
        props = ET.SubElement(node, 'Properties')
        ET.SubElement(props, 'string', name='Name').text = name
        if source is not None:
            ET.SubElement(props, 'ProtectedString', name='Source').text = source
        return node
    workspace = item(tree, 'Workspace', 'Workspace')
    preview_count=populate(workspace, ROOT, ROOT/'dist/preview-scene-v4.json')
    lighting = item(tree, 'Lighting', 'Lighting')
    props = lighting.find('Properties')
    ET.SubElement(props, 'float', name='ClockTime').text='0.5'
    ET.SubElement(props, 'float', name='Brightness').text='2.1'
    ET.SubElement(props, 'bool', name='GlobalShadows').text='true'
    rs = item(tree, 'ReplicatedStorage', 'ReplicatedStorage')
    shared = item(rs, 'Folder', 'Shared')
    shared_paths = sorted((ROOT/'src/shared').glob('*.luau'))
    for path in shared_paths:
        item(shared, 'ModuleScript', path.stem, path.read_text())
    server = item(tree, 'ServerScriptService', 'ServerScriptService')
    game_script = item(server, 'Script', 'Game', (ROOT/'src/server/init.server.luau').read_text())
    server_modules = sorted(p for p in (ROOT/'src/server').glob('*.luau') if p.name != 'init.server.luau')
    for path in server_modules:
        item(game_script, 'ModuleScript', path.stem, path.read_text())
    storage = item(tree, 'ServerStorage', 'ServerStorage')
    for name in ['CharacterModels', 'CatalogCharacters', 'ReferenceCharacters']:
        item(storage, 'Folder', name)
    starter = item(tree, 'StarterPlayer', 'StarterPlayer')
    scripts = item(starter, 'StarterPlayerScripts', 'StarterPlayerScripts')
    item(scripts, 'LocalScript', 'UI', (ROOT/'src/client/init.client.luau').read_text())
    target = ROOT/'dist'/target_name
    assert target.name not in ['Forgotten.rbxlx','Forgotten-V2.rbxlx','Forgotten-V3.rbxlx'], 'V1, V2 y V3 se conservan; usa un nombre de versión nuevo.'
    target.parent.mkdir(exist_ok=True)
    ET.indent(tree)
    ET.ElementTree(tree).write(target, encoding='utf-8', xml_declaration=True)
    parsed = ET.parse(target)
    sources = parsed.findall('.//ProtectedString')
    assert len(sources) == len(shared_paths) + len(server_modules) + 2
    expected = shared_paths + [ROOT/'src/server/init.server.luau'] + server_modules + [ROOT/'src/client/init.client.luau']
    assert [s.text for s in sources] == [p.read_text() for p in expected]
    print(f'{target}: XML válido; {len(sources)} scripts y {preview_count} piezas de vista previa.')
if __name__ == '__main__':
    build()
