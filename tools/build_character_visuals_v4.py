"""V4 evolves the V3 authored geometry; it never writes V3 resource files."""
from pathlib import Path
import copy,json,math
import build_character_visuals_v3 as base

ROOT=Path(__file__).resolve().parents[1]
FACES={'yellowguy':[]}
for index,x in enumerate([.35,.55]):
 for name,pos,size,color,angle in [
  ('Ojo',[x,.43],[.13,.095],[234,229,206],0),
  ('Pupila',[x+.055,.43],[.035,.085],[51,40,26],0),
  ('Ceja',[x-.02,.36],[.15,.032],[83,55,21],-12 if index==0 else 8),
  ('Párpado',[x,.425],[.13,.015],[83,55,21],-4 if index==0 else 3)]:
  FACES['yellowguy'].append(dict(name=name,position=pos,size=size,color=color,rotation=angle))
FACES['yellowguy'].append(dict(name='Boca',position=[.43,.71],size=[.18,.018],color=[83,55,21],rotation=-5))
PROFILES={
 'pelotocino':{'torso':[1.44,2,.72],'arm':[.68,2,.72],'leg':[.70,2,.78],'armX':1.06,'legX':.36},
 'yellowguy':{'torso':[1.40,2,.72],'arm':[.66,2,.70],'leg':[.68,2,.76],'armX':1.03,'legX':.35},
 'tubers93':{'torso':[1.76,2,.86],'arm':[.82,2,.84],'leg':[.85,2,.88],'armX':1.29,'legX':.44},
 'guest666':{'torso':[1.86,2,.92],'arm':[.88,2,.90],'leg':[.90,2,.94],'armX':1.37,'legX':.46}}

def loft(spec):
 """One continuous chamfered, tapered surface replaces the rectangular shell."""
 x,y,z=spec['size'];vertices=[]
 for level,scale in [(-y/2,.89),(y/2,1)]:
  hx,hz=x*scale/2,z*scale/2;r=min(x,z)*.16
  for a,b in [(-hx+r,-hz),(hx-r,-hz),(hx,-hz+r),(hx,hz-r),(hx-r,hz),(-hx+r,hz),(-hx,hz-r),(-hx,-hz+r)]:vertices.append([a,level,b])
 faces=[]
 for i in range(8):
  j=(i+1)%8;faces.extend([[i,j,j+8],[i,j+8,i+8]])
 for i in range(1,7):faces.extend([[0,i+1,i],[8,8+i,8+i+1]])
 return dict(name=spec['name'],anchor=spec['anchor'],kind='Mesh',body=True,color=spec['color'],material=spec['material'],vertices=vertices,faces=faces)

def build():
 data=copy.deepcopy(base.MODELS)
 authored=[];saved=base.current;base.current=authored
 skin=[245,205,48];gold=[199,149,48]
 for anchor,size in [('Torso',[2,2,1]),('LeftArm',[1,2,1]),('RightArm',[1,2,1]),('LeftLeg',[1,2,1]),('RightLeg',[1,2,1])]:
  s=base.shape('Avatar '+anchor,anchor,size,[0,0,0],skin if 'Arm' in anchor else base.BLACK,'RoundedBlock');s['body']=True
 base.shape('Base de cabello rubio','Head',[1.46,.66,1.3],[0,.47,.08],gold)
 for index in range(5):
  x=-.52+index*.26;rise=1.03+(4-index)*.035
  points=[[x,.52,.4],[x-.12,rise,.12],[x-.25,rise+.12,-.27],[x-.39,.77,-.61]]
  base.tube('Mechón rubio elevado '+str(index),'Head',points,[.18,.23,.21,.055],[204+index*5,153+index*5,49+index*3],sides=6,flatten=.8)
 for side in [-1,1]:
  base.tube('Patilla rubia','Head',[[side*.57,.51,.17],[side*.7,.26,.15],[side*.64,-.05,.12]],[.14,.15,.05],gold,sides=5)
  s=base.shape('Manga de chaqueta','LeftArm' if side<0 else 'RightArm',[1.025,1.05,1.025],[0,.48,0],base.BLACK,'RoundedBlock');s['radius']=.06
  base.mesh('Solapa de chaqueta','Torso',[[side*.4,.94,-.52],[side*.83,.72,-.53],[side*.47,.13,-.54]],[[0,1,2]],[34,39,45],'Fabric')
  s=base.shape('Zapato oscuro','LeftLeg' if side<0 else 'RightLeg',[1.02,.3,1.2],[0,-.85,-.06],[37,40,44],'RoundedBlock');s['radius']=.08
 base.current=saved
 for spec in data['yellowguy']:
  if not spec['name'].startswith('CombatMark'):
   spec['weapon']='cane'
   if 'position' in spec:spec['position'][2]+=.15
   for point in spec.get('vertices',[]):point[2]+=.15
 data['yellowguy']+=authored
 for id,profile in PROFILES.items():
  for index,s in enumerate(data[id]):
   anchor=s['anchor'];head=anchor=='Head'
   if s['name']=='Manga de chaqueta':s['size'][1]=1.16;s['material']='Fabric'
   if s.get('body') and (anchor=='Torso' or 'Leg' in anchor):s['material']='Fabric'
   if s['name'] in ['Mochila','Bolsillo de mochila']:s['material']='Fabric'
   factors=[1,1,1] if head else [profile['torso'][0]/2,1,profile['torso'][2]] if anchor=='Torso' else [profile['arm'][0],1,profile['arm'][2]] if 'Arm' in anchor else [profile['leg'][0],1,profile['leg'][2]]
   # Weapons retain their dimensions and reach; clothing follows the new body.
   weapon=s.get('weapon')=='cane' or any(word in s['name'].lower() for word in ['guadaña','eslabón','sartén']) or s['name']=='Mango de sartén'
   if weapon:continue
   for key in ['position','size','start','end']:
    if key in s:s[key]=[round(v*factors[i],5) for i,v in enumerate(s[key])]
   if 'vertices' in s:s['vertices']=[[round(v*factors[i],5) for i,v in enumerate(p)] for p in s['vertices']]
   if s.get('body'):data[id][index]=loft(s)
  if id=='pelotocino':
   # Two collar surfaces shape the neck opening; these replace the old flat lapels.
   for side in [-1,1]:
    data[id].append(dict(name='Solapa de chaqueta',anchor='Torso',kind='Mesh',material='Fabric',color=[34,39,45],
     vertices=[[side*.30,.95,-.375],[side*.62,.78,-.38],[side*.34,.18,-.39]],faces=[[0,1,2]]))
 # Surface materials and restrained edge wear; identity is kept distinct.
 for s in data['junkbot']:
  if s['name'] in ['Peto robot','Placa tibial','Hombrera robot','Cadera mecánica']:s['material']='CorrodedMetal'
  if s['name']=='Cabeza robot':
   vertices=[];faces=[];sides=10
   for y,width,depth in [(-.58,.43,.40),(-.16,.64,.54),(.49,.58,.48)]:
    for n in range(sides):
     angle=n*math.tau/sides;vertices.append([math.cos(angle)*width,y,math.sin(angle)*depth+.02])
   for ring in range(2):
    for n in range(sides):
     a=ring*sides+n;b=ring*sides+(n+1)%sides;faces.extend([[a,b,b+sides],[a,b+sides,a+sides]])
   for n in range(1,sides-1):faces.extend([[0,n+1,n],[20,20+n,20+n+1]])
   shaped=dict(name=s['name'],anchor='Head',kind='Mesh',vertices=vertices,faces=faces,color=s['color'],material='Metal');s.clear();s.update(shaped)
  if s['name']=='Órbita robot':s['position'][2]=-.60
  if s['name']=='Visor verde':s['position'][2]=-.68
  if s['name'] in ['Órbita robot','Visor verde']:s['rotation']=[0,0,17 if s['position'][0]>0 else -17]
 for s in data['deathspeaker']:
  if s['name'] in ['Coraza curva','Hombrera labrada']:s['color']=[116,127,148]
  if s['name']=='Hueco capucha':s['color']=[7,15,23]
  if s['name']=='Ojo espectral':
   x=s['position'][0];side=1 if x>0 else -1
   eye=dict(name=s['name'],anchor='Head',kind='Mesh',material='Neon',color=s['color'],
    vertices=[[x-side*.16,.17,-.71],[x+side*.17,.11,-.71],[x+side*.08,.015,-.715],[x-side*.11,.04,-.715]],faces=[[0,1,2],[0,2,3]])
   s.clear();s.update(eye)
 authored=[];saved=base.current;base.current=authored
 base.shape('Máscara espectral','Head',[1.05,.62,.16],[0,-.27,-.64],[28,55,65])
 for i in range(-2,3):base.mesh('Detalle mandibular','Head',[[i*.12-.035,-.29,-.735],[i*.12+.035,-.29,-.735],[i*.12,-.42,-.735]],[[0,1,2]],[135,170,181])
 base.current=saved;data['deathspeaker']+=authored
 # Lightweight open chain links replace the former solid beads.
 data['tubers93']=[s for s in data['tubers93'] if s['name']!='Eslabón']
 for link in range(7):
  cy=.3-link*.15
  points=[[.16-.05,cy-.07,-.65],[.16+.05,cy-.07,-.65],[.16+.05,cy+.07,-.65],[.16-.05,cy+.07,-.65]]
  if link%2:points=[[.16,p[1],-.65+p[0]-.16] for p in points]
  for a,b in zip(points,points[1:]+points[:1]):data['tubers93'].append(dict(name='Eslabón abierto',anchor='RightArm',kind='Segment',start=a,end=b,radius=.014,color=base.STEEL,material='Metal'))
 return data

def main():
 out=ROOT/'assets/v4';out.mkdir(exist_ok=True)
 data=build()
 (out/'character-geometry.json').write_text(json.dumps(data,ensure_ascii=False,separators=(',',':'))+'\n')
 (out/'rig-proportions.json').write_text(json.dumps(PROFILES,indent=2)+'\n')
 (out/'faces.json').write_text(json.dumps(FACES,ensure_ascii=False,indent=2)+'\n')
 (ROOT/'src/shared/CharacterVisualData.luau').write_text('-- V4 authored surfaces. Generated by tools/build_character_visuals_v4.py.\nreturn '+base.lua(data)+'\n')
 (ROOT/'src/shared/RigProfileData.luau').write_text('-- V4 rig dimensions shared with the renderer.\nreturn '+base.lua(PROFILES)+'\n')
 (ROOT/'src/shared/FaceData.luau').write_text('-- V4 original facial artwork shared with the renderer.\nreturn '+base.lua(FACES)+'\n')
 print('V4: cuatro cuerpos estilizados; Yellow Guy sigue la descripción explícita del usuario.')

if __name__=='__main__':main()
