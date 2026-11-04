from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import random
OUT=Path(__file__).resolve().parents[1]/'assets/characters';OUT.mkdir(exist_ok=True)
font='/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
for name in ['bacon_face','tux_face','guest_logo','guest_cap','sad_badge']:
 im=Image.new('RGBA',(1024,1024),(0,0,0,0));d=ImageDraw.Draw(im)
 if name=='bacon_face':
  for x in [350,655]:d.ellipse((x-19,330,x+19,438),fill=(14,14,14))
  d.arc((320,420,710,700),0,180,fill=(16,16,16),width=19)
 elif name=='tux_face':
  for x,slant in [(320,-1),(700,1)]:
   d.polygon([(x-135,410),(x+110,380),(x+115,480),(x-120,480)],fill=(229,225,204))
   d.ellipse((x-10,387,x+40,475),fill=(47,47,47));d.line([(x-130,410),(x+100,383)],fill=(63,44,21),width=15)
   d.line([(x-140,315),(x+100,285 if slant==1 else 330)],fill=(80,48,19),width=29)
  d.arc((280,520,830,690),5,150,fill=(108,68,29),width=12)
  d.arc((750,485,830,750),260,340,fill=(149,100,44),width=5)
 elif name=='guest_logo':
  f=ImageFont.truetype(font,165)
  d.text((30,380),'ROBLOX',font=f,fill='white',stroke_width=17,stroke_fill=(170,23,31))
 elif name=='guest_cap':
  d.text((315,230),'R',font=ImageFont.truetype(font,500),fill='white',stroke_width=18,stroke_fill=(140,25,31))
 elif name=='sad_badge':
  d.arc((150,130,440,480),0,170,fill=(111,75,9),width=40)
  d.arc((580,130,870,480),10,180,fill=(111,75,9),width=40)
  d.arc((290,580,740,950),190,350,fill=(111,75,9),width=40)
 if name=='guest_cap':
  im=im.crop(im.getbbox()).resize((1024,1024),Image.Resampling.LANCZOS)
 im.save(OUT/(name+'.png'))
print('Texturas faciales y emblemas originales dibujados a partir de las referencias.')
