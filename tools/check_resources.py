"""Validate preserved resource containers without claiming visual fidelity."""
from pathlib import Path
import json,struct
ROOT=Path(__file__).resolve().parents[1]
counts={'png':0,'fbx':0,'glb':0}
for folder in ['assets','dist']:
    for p in (ROOT/folder).rglob('*'):
        if not p.is_file():continue
        if p.suffix=='.png':
            data=p.read_bytes()
            assert data[:8]==b'\x89PNG\r\n\x1a\n',p
            w,h=struct.unpack('>II',data[16:24]);assert w>0 and h>0,p
            counts['png']+=1
        elif p.suffix=='.fbx':
            data=p.read_bytes();assert data.startswith(b'Kaydara FBX Binary'),p
            counts['fbx']+=1
        elif p.suffix=='.glb':
            data=p.read_bytes();magic,version,size=struct.unpack('<4sII',data[:12])
            assert magic==b'glTF' and version==2 and size==len(data),p
            length,kind=struct.unpack('<II',data[12:20]);assert kind==0x4E4F534A,p
            parsed=json.loads(data[20:20+length]);assert parsed.get('meshes'),p
            counts['glb']+=1
for p in (ROOT/'tools').glob('*.py'):compile(p.read_text(),str(p),'exec')
project=json.loads((ROOT/'default.project.json').read_text())
assert project['tree']['ServerScriptService']['Game']['$path']=='src/server'
for name in ['CharacterModels','CatalogCharacters','ReferenceCharacters']:
    assert project['tree']['ServerStorage'][name]['$ignoreUnknownInstances'] is True
sources=json.loads((ROOT/'assets/character_sources.json').read_text())
assert len(sources['active'])==6 and 'baller' not in sources['active']
assert sources['active']['junkbot']['bundle_id']==589 and sources['active']['yellowguy']['legacy_mesh'] is None
print('Recursos históricos conservados y contenedores válidos:',counts)
