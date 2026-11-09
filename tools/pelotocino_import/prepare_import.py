"""Bake existing vertex colors to portable UV atlases. Never changes geometry."""
from pathlib import Path
import json,hashlib,math
import numpy as np
from PIL import Image
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'dist/pelotocino-importado/fuentes-3d';OUT.mkdir(parents=True,exist_ok=True)
DATA=json.loads((ROOT/'assets/pelotocino/geometry.json').read_text())
SIZE=2048;CELL=12;COLS=SIZE//CELL
color=np.full((SIZE,SIZE,3),220,dtype=np.uint8)
rough=np.full((SIZE,SIZE),204,dtype=np.uint8);metal=np.zeros((SIZE,SIZE),dtype=np.uint8)
y,x=np.mgrid[:CELL,:CELL];u=(x-2)/(CELL-5);v=(y-2)/(CELL-5)
weights=np.stack([1-u-v,u,v],axis=-1);weights=np.maximum(weights,0);weights/=weights.sum(axis=-1,keepdims=True)
offset=0;meshes=[]
for spec in DATA['meshes']:
 verts=np.array(spec['vertices']);faces=np.array(spec['faces']);colors=(np.array(spec['colors'])/255)**2.2
 lo=verts.min(axis=0);hi=verts.max(axis=0)
 meshes.append({'name':spec['name'],'anchor':spec['anchor'],'group':spec['group'],'material':spec['material'],
  'center':((lo+hi)/2).tolist(),'size':(hi-lo).tolist(),'vertices':len(verts),'triangles':len(faces),'first_face':offset})
 for face in faces:
  tx=(offset%COLS)*CELL;ty=(offset//COLS)*CELL;assert ty+CELL<=SIZE
  rgb=weights@colors[face]
  if spec['material']=='Fabric':
   p=weights@verts[face]
   xx=np.floor((.5+p[:,:,0]*.32)*128)%128;yy=np.floor((.5+p[:,:,1]*.32)*128)%128
   noise=np.sin(xx*12.9898+yy*78.233)*43758.5453;noise-=np.floor(noise)
   gray=np.floor(219+noise*29)if spec['group']=='backpack'else np.floor(218+noise*12+np.where((xx+yy)%4<2,20,0))
   rgb*=(gray[:,:,None]/255)**2.2
  color[ty:ty+CELL,tx:tx+CELL]=np.clip(np.round(rgb**(1/2.2)*255),0,255).astype(np.uint8)
  rough[ty:ty+CELL,tx:tx+CELL]=204 if spec['material']=='Fabric'else 166 if spec['group']in['hair','tuft']else 90
  metal[ty:ty+CELL,tx:tx+CELL]=153 if spec['material']=='Metal'else 0
  offset+=1
for name,pixels in [('Pelotocino-Color',color),('Pelotocino-Roughness',rough),('Pelotocino-Metalness',metal)]:
 Image.fromarray(pixels).save(OUT/(name+'.png'))
manifest={'source_geometry_sha256':hashlib.sha256((ROOT/'assets/pelotocino/geometry.json').read_bytes()).hexdigest(),
 'geometry_changed':False,'studio_executed':False,'uploaded_asset_ids':False,'atlas_size':SIZE,'cell':CELL,'columns':COLS,
 'triangles':offset,'meshes':meshes,'textures':{p.name:hashlib.sha256(p.read_bytes()).hexdigest()for p in OUT.glob('*.png')}}
(OUT/'mesh-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print('Atlas preparados:',len(meshes),'mallas;',offset,'triángulos originales; 3 texturas',SIZE,'x',SIZE)
