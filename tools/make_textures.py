"""Mapas PBR originales, repetibles y sin descargas (512 px)."""
from pathlib import Path
import numpy as np
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]/'assets/textures'
ROOT.mkdir(parents=True,exist_ok=True)
n=512;y,x=np.mgrid[0:n,0:n]/n;rng=np.random.default_rng(93)
noise=np.zeros((n,n))
for f,a in [(3,.3),(9,.15),(23,.07),(57,.03)]:
 for _ in range(4):
  k,l=rng.integers(1,f+1,2);noise+=a*np.sin(2*np.pi*(x*k+y*l)+rng.random()*6.28)/4
wood=.5+.19*np.sin(2*np.pi*(x*25+.23*np.sin(2*np.pi*y*2)+noise))+.11*np.sin(2*np.pi*x*83)+noise*.25
stone=.5+noise*.7+.07*np.sin(2*np.pi*(x*42+y*31))
fabric=.5+.2*np.sin(2*np.pi*x*128)*np.sin(2*np.pi*y*128)+noise*.1
metal=.5+noise*.3+.08*np.sin(2*np.pi*y*180)
for name,h,base,rough in [('oak',wood,[130,94,61],.65),('limestone',stone,[116,111,99],.88),('woven',fabric,[103,122,105],.95),('aged_brass',metal,[160,118,53],.38)]:
 h=np.clip(h,0,1)
 color=np.clip(np.array(base)[None,None,:]*(.67+h[:,:,None]*.6),0,255).astype('uint8')
 Image.fromarray(color).save(ROOT/(name+'_color.png'))
 dx=(np.roll(h,-1,1)-np.roll(h,1,1))*1.5;dy=(np.roll(h,-1,0)-np.roll(h,1,0))*1.5
 normal=np.stack([-dx,-dy,np.ones_like(h)],axis=-1);normal/=np.linalg.norm(normal,axis=-1,keepdims=True)
 Image.fromarray(((normal*.5+.5)*255).astype('uint8')).save(ROOT/(name+'_normal.png'))
 Image.fromarray((np.clip(rough+(h-.5)*.16,0,1)*255).astype('uint8')).save(ROOT/(name+'_roughness.png'))
print('12 mapas PBR originales de 512x512 generados.')
