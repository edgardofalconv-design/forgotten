"""Reuse only backpack/pan/tracker; do not export or create a body or hair."""
from pathlib import Path
import hashlib, json
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'dist/pelotocino-native-visual/accesorios'
OUT.mkdir(parents=True, exist_ok=True)
SOURCE = ROOT / 'assets/pelotocino/geometry.json'
data = json.loads(SOURCE.read_text())
specs = [s for s in data['meshes'] if s['group'] in ('backpack', 'pan', 'tracker')]
assert len(specs) == 7
SIZE, CELL = 1024, 12
COLS = SIZE // CELL
color = np.full((SIZE, SIZE, 3), 220, dtype=np.uint8)
rough = np.full((SIZE, SIZE), 204, dtype=np.uint8)
metal = np.zeros((SIZE, SIZE), dtype=np.uint8)
y, x = np.mgrid[:CELL, :CELL]
u, v = (x - 2) / (CELL - 5), (y - 2) / (CELL - 5)
weights = np.maximum(np.stack([1-u-v, u, v], axis=-1), 0)
weights /= weights.sum(axis=-1, keepdims=True)
offset = 0
for s in specs:
    s['first_face'] = offset
    verts = np.array(s['vertices'])
    colors = (np.array(s['colors']) / 255) ** 2.2
    for face in s['faces']:
        tx, ty = (offset % COLS) * CELL, (offset // COLS) * CELL
        assert ty + CELL <= SIZE
        rgb = weights @ colors[face]
        if s['material'] == 'Fabric':
            p = weights @ verts[face]
            xx = np.floor((.5 + p[:, :, 0] * .32) * 128) % 128
            yy = np.floor((.5 + p[:, :, 1] * .32) * 128) % 128
            noise = np.sin(xx * 12.9898 + yy * 78.233) * 43758.5453
            noise -= np.floor(noise)
            rgb *= (np.floor(219 + noise * 29)[:, :, None] / 255) ** 2.2
        color[ty:ty+CELL, tx:tx+CELL] = np.clip(np.round(rgb ** (1/2.2) * 255), 0, 255).astype(np.uint8)
        rough[ty:ty+CELL, tx:tx+CELL] = 204 if s['material'] == 'Fabric' else 90
        metal[ty:ty+CELL, tx:tx+CELL] = 153 if s['material'] == 'Metal' else 0
        offset += 1
for name, pixels in [('Color', color), ('Roughness', rough), ('Metalness', metal)]:
    Image.fromarray(pixels).save(OUT / (name + '.png'))
filtered = {'origin': 'Existing authored accessories only; no body, head or hair',
            'source_sha256': hashlib.sha256(SOURCE.read_bytes()).hexdigest(),
            'axes': data['axes'], 'meshes': specs}
(OUT/'accesorios-source.json').write_text(json.dumps(filtered, separators=(',', ':'))+'\n')
manifest = {'studio_executed': False, 'native_avatar_included': False,
            'source_sha256': filtered['source_sha256'], 'geometry_reused_unchanged': True,
            'groups': ['Backpack', 'Pan', 'Tracker'], 'triangles': offset,
            'atlas_size': SIZE, 'cell': CELL, 'columns': COLS}
(OUT/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
print('Accessory-only atlas:', offset, 'triangles; no body or hair.')
