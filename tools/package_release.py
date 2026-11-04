"""Empaqueta el proyecto y las vistas finales, excluyendo cachés y metadatos Git."""
from pathlib import Path
import zipfile,hashlib,json,struct
ROOT=Path(__file__).resolve().parents[1]
def main():
    for name in ['01-sala','02-altillo','03-hogar']:
        p=ROOT/'dist/previews'/(name+'.png')
        data=p.read_bytes()
        assert data[:8]==b'\x89PNG\r\n\x1a\n'
        assert struct.unpack('>II',data[16:24])==(1280,820),(name,'render incompleto')
    files=[]
    for p in sorted(ROOT.rglob('*')):
        if not p.is_file() or any(x in p.parts for x in ['.git','__pycache__']):continue
        if p.suffix in ['.zip','.blend1','.pyc'] or p.name=='SHA256SUMS.json':continue
        files.append(p)
    hashes={str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in files}
    manifest=ROOT/'dist/SHA256SUMS.json';manifest.write_text(json.dumps(hashes,indent=2)+'\n');files.append(manifest)
    target=ROOT/'dist/Forgotten-Lobby-HD.zip'
    with zipfile.ZipFile(target,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for p in files:z.write(p,'Forgotten/'+str(p.relative_to(ROOT)))
    with zipfile.ZipFile(target) as z:
        assert z.testzip() is None
        assert 'Forgotten/dist/Forgotten.rbxlx' in z.namelist()
    print(f'{target}: {len(files)} archivos; {target.stat().st_size:,} bytes; integridad ZIP verificada.')
if __name__=='__main__':main()
