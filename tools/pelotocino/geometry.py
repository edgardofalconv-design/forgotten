"""Authored rounded R15 surfaces and equipment from the user's turnaround.
No block/Part body generation and no external resource identifiers.
Coordinates are Roblox: Y up, front -Z. All surfaces are triangle meshes.
"""
import math,json,random
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'assets/pelotocino';OUT.mkdir(parents=True,exist_ok=True)
V=np.array
ANCHORS={'HumanoidRootPart':[0,3,0],'LowerTorso':[0,2.67,0],'UpperTorso':[0,3.43,0],'Head':[0,4.73,0]}
JOINTS=[['Root','HumanoidRootPart','LowerTorso',[0,2.67,0]],['Waist','LowerTorso','UpperTorso',[0,2.98,0]],['Neck','UpperTorso','Head',[0,4.12,0]]]
for side,name in [(-1,'Left'),(1,'Right')]:
 for limb,pos in [('UpperArm',[side*.97,3.49,0]),('LowerArm',[side*1.01,2.78,0]),('Hand',[side*1.02,2.25,-.03]),('UpperLeg',[side*.39,1.98,0]),('LowerLeg',[side*.39,1.07,0]),('Foot',[side*.39,.36,-.13])]:ANCHORS[name+limb]=pos
 for joint,parent,child,pos in [('Shoulder','UpperTorso',name+'UpperArm',[side*.85,3.94,0]),('Elbow',name+'UpperArm',name+'LowerArm',[side*1.00,3.05,0]),('Wrist',name+'LowerArm',name+'Hand',[side*1.02,2.46,-.01]),('Hip','LowerTorso',name+'UpperLeg',[side*.39,2.43,0]),('Knee',name+'UpperLeg',name+'LowerLeg',[side*.39,1.53,0]),('Ankle',name+'LowerLeg',name+'Foot',[side*.39,.62,-.05])]:JOINTS.append([name+joint,parent,child,pos])
SKIN=[224,223,217];BLACK=[23,25,29];BLUE=[31,107,185];DENIM=[21,29,36];LEATHER=[111,76,48];EDGE=[153,110,71];HAIR=[88,42,22];RIDGE=[137,70,34];SOLE=[216,218,214];METAL=[110,117,119]
MESHES={}
def add(name,anchor,vertices,faces,color,material='SmoothPlastic',group='body'):
 key=(anchor,material,group)
 if key not in MESHES:MESHES[key]={'name':anchor+'_'+group+'_'+material,'anchor':anchor,'group':group,'material':material,'vertices':[],'faces':[],'colors':[],'labels':[]}
 m=MESHES[key];offset=len(m['vertices']);m['labels'].append(name)
 for i,p in enumerate(vertices):
  m['vertices'].append([round(float(x),5) for x in p])
  # Baked micro-variation also used by the Roblox mesh vertex colors.
  noise=math.sin(p[0]*137+p[1]*83+p[2]*47)*math.cos(p[0]*57-p[1]*193)
  factor=1+noise*(.16 if material=='Fabric' else .045 if color in [LEATHER,EDGE] else .015)
  m['colors'].append([min(255,max(0,round(c*factor))) for c in color])
 for face in faces:
  for j in range(1,len(face)-1):m['faces'].append([offset+face[0],offset+face[j],offset+face[j+1]])
def loft(name,anchor,rings,color,material='SmoothPlastic',group='body',sides=24,power=3,center=(0,0,0)):
 verts=[];faces=[]
 for y,rx,rz in rings:
  for j in range(sides):
   a=j*2*math.pi/sides;c,s=math.cos(a),math.sin(a)
   verts.append([center[0]+rx*math.copysign(abs(c)**(2/power),c),center[1]+y,center[2]+rz*math.copysign(abs(s)**(2/power),s)])
 for i in range(len(rings)-1):
  for j in range(sides):a=i*sides+j;b=i*sides+(j+1)%sides;faces.append([a,a+sides,b+sides,b])
 faces.extend([list(range(sides)),list(range((len(rings)-1)*sides,len(rings)*sides))[::-1]])
 add(name,anchor,verts,faces,color,material,group)
def ell(name,anchor,center,size,color,material='SmoothPlastic',group='body',n=20):
 rings=[]
 for i in range(13):
  t=-math.pi/2+.015+(math.pi-.03)*i/12
  rings.append([math.sin(t)*size[1]/2,max(.002,math.cos(t)*size[0]/2),max(.002,math.cos(t)*size[2]/2)])
 loft(name,anchor,rings,color,material,group,n,2,center)
def tube(name,anchor,points,radii,color,material='SmoothPlastic',group='body',sides=8,flatten=1):
 verts=[];faces=[];pts=[V(p,dtype=float) for p in points];previous=None
 for i,p in enumerate(pts):
  t=pts[min(i+1,len(pts)-1)]-pts[max(0,i-1)];t=t/np.linalg.norm(t)
  ref=previous if previous is not None else V([1.,0.,0.]) if abs(t[0])<.9 else V([0.,1.,0.])
  u=ref-t*np.dot(ref,t);u/=np.linalg.norm(u);v=np.cross(t,u);previous=u
  for j in range(sides):
   a=j*2*math.pi/sides;verts.append(p+radii[i]*(math.cos(a)*u+math.sin(a)*v*flatten))
 for i in range(len(pts)-1):
  for j in range(sides):a=i*sides+j;b=i*sides+(j+1)%sides;faces.append([a,b,b+sides,a+sides])
 faces.extend([list(range(sides))[::-1],list(range((len(pts)-1)*sides,len(pts)*sides))])
 add(name,anchor,verts,faces,color,material,group)
def rounded(name,anchor,center,size,color,material='SmoothPlastic',group='body',r=.09):
 # Profile rings, not stacked boxes. Curved perimeter and round caps.
 x,y,z=[v/2 for v in size];r=min(r,x*.5,y*.5,z*.5)
 loft(name,anchor,[[-y,x-r,z-r],[-y+r*.3,x-r*.3,z-r*.3],[-y+r,x,z],[y-r,x,z],[y-r*.3,x-r*.3,z-r*.3],[y,x-r,z-r]],color,material,group,24,4,center)
def ribbon(name,anchor,points,width,color,group='body',depth=.032):
 # Rounded leather/cloth bands with a rectangular curved section.
 tube(name,anchor,points,[width/2]*len(points),color,'Fabric',group,8,depth/width)
# Complete continuous surfaces for the 15 articulated R15 body sections.
loft('Camiseta azul','UpperTorso',[[-.55,.56,.31],[-.45,.59,.34],[.05,.66,.36],[.38,.72,.34],[.53,.60,.29],[.63,.30,.27]],BLUE,'Fabric')
ell('Cuello','UpperTorso',[0,.65,0],[.43,.36,.45],SKIN)
loft('Cintura del pantalón','LowerTorso',[[-.28,.56,.32],[.1,.57,.33],[.32,.57,.32]],DENIM,'Fabric')
loft('Cabeza moldeada','Head',[[-.59,.43,.37],[-.56,.57,.47],[-.45,.65,.53],[.38,.65,.53],[.51,.59,.48],[.58,.44,.35]],SKIN,sides=40,power=4)
# Classic face, drawn as actual curved meshes (not a photo plane).
for x in [-.19,.19]:ell('Ojo clásico','Head',[x,.11,-.538],[.077,.17,.025],[13,13,14],n=12)
pts=[]
for i in range(19):
 a=math.pi+.16+(math.pi-.32)*i/18
 pts.append([.225*math.cos(a),-.10+.22*math.sin(a),-.542])
tube('Sonrisa clásica','Head',pts,[.018]*len(pts),[16,16,17],sides=6)
for side,name in [(-1,'Left'),(1,'Right')]:
 loft('Manga de chaqueta',name+'UpperArm',[[-.45,.26,.28],[-.37,.29,.31],[.28,.32,.32],[.42,.25,.26],[.46,.16,.2]],BLACK,'Fabric',power=2.7)
 loft('Antebrazo',name+'LowerArm',[[-.33,.225,.235],[-.24,.25,.25],[.20,.27,.27],[.33,.25,.25]],SKIN,power=2.8)
 loft('Puño doblado',name+'UpperArm',[[-.47,.28,.30],[-.41,.30,.32],[-.32,.30,.32]],BLACK,'Fabric',power=2.8)
 # Characteristic curved Roblox grip, open toward the front, with palm and thumb.
 ell('Palma',name+'Hand',[0,.10,.04],[.43,.37,.32],SKIN)
 pts=[]
 for i in range(23):
  a=math.radians(48+264*i/22)
  pts.append([-side*.18*math.cos(a),-.035+.19*math.sin(a),-.09])
 tube('Mano con agarre curvo',name+'Hand',pts,[.10]*len(pts),SKIN,sides=12)
 loft('Muslo de vaquero',name+'UpperLeg',[[-.48,.31,.34],[-.3,.32,.35],[.24,.34,.35],[.48,.32,.33]],DENIM,'Fabric',power=3.5)
 loft('Pantalón inferior',name+'LowerLeg',[[-.49,.30,.32],[-.33,.31,.33],[.32,.31,.34],[.48,.31,.34]],DENIM,'Fabric',power=3.5)
 for anchor,length in [(name+'UpperLeg',.74),(name+'LowerLeg',.76)]:
  for i in range(13):
   y=-length/2+i*length/12
   tube('Costura de vaquero',anchor,[[side*.31,y,.05],[side*.313,y+.026,.05]],[.005,.005],[78,80,76],'Fabric',sides=4)
 rounded('Zapatilla blanca',name+'Foot',[0,0,-.025],[.65,.44,.98],SOLE,r=.13)
 rounded('Suela de goma',name+'Foot',[0,-.15,-.04],[.68,.16,1.01],[193,197,195],r=.06)
 for i in range(10):
  x=-.27+i*.06;tube('Estría de suela',name+'Foot',[[x,-.18,-.544],[x,-.085,-.535]],[.009,.009],[230,231,225],sides=4)
 for i in range(3):tube('Cordón',name+'Foot',[[-.18,.185,-.12-i*.08],[.18,.185,-.12-i*.08]],[.016,.016],[230,231,225],sides=6)
 # Open jacket fronts and side panels follow the slim torso.
 for y in [-.3,-.1,.12,.32]:
  pass
 tube('Lateral chaqueta','UpperTorso',[[side*.53,-.67,.06],[side*.59,0,.06],[side*.60,.36,.04]],[.19,.22,.22],BLACK,'Fabric',sides=12,flatten=1.9)
 ribbon('Solapa abierta','UpperTorso',[[side*.39,-.65,-.357],[side*.35,-.05,-.382],[side*.33,.28,-.374],[side*.29,.46,-.31]],.27,BLACK,depth=.045)
 ribbon('Borde de solapa','UpperTorso',[[side*.29,-.38,-.389],[side*.23,.20,-.410],[side*.21,.44,-.33]],.025,[50,53,57],depth=.025)
# Back jacket panel, curved volume.
rounded('Espalda de chaqueta','UpperTorso',[0,-.07,.27],[1.22,1.33,.22],BLACK,'Fabric',r=.08)
# Dark chest mark inspired by the visible reference, authored rather than a copied logo.
for side in [-1,1]:
 tube('Gráfico de camiseta','UpperTorso',[[side*.04,.1,-.365],[side*.18,.19,-.365],[side*.26,.15,-.365],[side*.19,.02,-.372]],[.025,.028,.018,.010],[12,27,42],'Fabric',sides=6,flatten=.22)
tube('Gráfico central','UpperTorso',[[0,.19,-.37],[0,-.03,-.38],[.08,-.13,-.38]],[.028,.025,.018],[12,27,42],'Fabric',sides=6,flatten=.22)
# Backpack: structured leather, curved flap, front and side pockets, buckles/stitches.
rounded('Mochila principal','UpperTorso',[0,-.02,.68],[1.06,1.20,.57],LEATHER,'Fabric','backpack',.13)
rounded('Solapa mochila','UpperTorso',[0,.30,.999],[1.02,.48,.12],LEATHER,'Fabric','backpack',.07)
rounded('Bolsillo exterior','UpperTorso',[0,-.34,1.02],[.76,.40,.14],[102,68,42],'Fabric','backpack',.05)
for side in [-1,1]:
 ribbon('Tirante mochila','UpperTorso',[[side*.42,-.40,-.42],[side*.49,0,-.45],[side*.52,.45,-.39],[side*.49,.62,-.12],[side*.47,.58,.38],[side*.39,.23,.68]],.14,LEATHER,'backpack',.07)
 pts=[[side*.49-.075,-.06,-.495],[side*.49+.075,-.06,-.495],[side*.49+.075,.08,-.495],[side*.49-.075,.08,-.495],[side*.49-.075,-.06,-.495]]
 tube('Hebilla frontal del tirante','UpperTorso',pts,[.014]*5,[139,124,103],'Metal','backpack',8)
 ribbon('Correa cierre','UpperTorso',[[side*.29,.42,1.075],[side*.29,-.48,1.12]],.08,[91,61,38],'backpack',.034)
 rounded('Bolsillo lateral','UpperTorso',[side*.58,-.16,.70],[.18,.60,.38],LEATHER,'Fabric','backpack',.06)
 for y in [-.05,.16]:
  pts=[[side*.29-.055,y-.05,1.142],[side*.29+.055,y-.05,1.142],[side*.29+.055,y+.05,1.142],[side*.29-.055,y+.05,1.142],[side*.29-.055,y-.05,1.142]]
  tube('Hebilla metálica','UpperTorso',pts,[.011]*5,METAL,'Metal','backpack',6)
 for i in range(11):
  y=-.48+i*.09
  tube('Pespunte mochila','UpperTorso',[[side*.45,y,.985],[side*.45,y+.035,.985]],[.006,.006],EDGE,'Fabric','backpack',4)
tube('Asa superior','UpperTorso',[[-.19,.59,.66],[-.16,.77,.66],[.16,.77,.66],[.19,.59,.66]],[.047]*4,LEATHER,'Fabric','backpack',8)
# Bacon hair: swept U-profile locks with curved ribs and varied lengths.
ell('Base cabello','Head',[0,.47,.08],[1.29,.48,1.05],HAIR,group='hair')
for i in range(7):
 x=-.54+i*.18;yend=[.10,-.08,.43,.38,.32,-.03,.12][i]
 points=[[x*.65+.07,.44,.35],[x*.85+.04,.66,.22],[x+.03,[.77,.83,.82,.87,.75,.76,.71][i],-.02],[x*1.02,.61,-.36],[x*1.07-.025,max(.40,yend+.07),-.54],[x*1.08-.04,yend,-.55]]
 group='tuft' if i==3 else 'hair'
 tube('Mechón Bacon ondulado','Head',points,[.115,.125,.13,.115,.105,.075],HAIR,group=group,sides=12,flatten=.50)
 for delta in [-.055,.035]:
  offsets=[(0,.045),(.055,.005),(.06,-.008),(.035,-.045),(.005,-.05),(0,-.038)]
  rib=[[p[0]+delta,p[1]+offsets[j][0],p[2]+offsets[j][1]] for j,p in enumerate(points)]
  tube('Veta del mechón','Head',rib,[.006]*6,RIDGE,group=group,sides=5)
for side in [-1,1]:
 for i in range(3):
  z=.05+i*.20
  points=[[side*.49,.55,z],[side*.69,.40,z],[side*.72,.04-i*.03,z],[side*.66,-.11-i*.03,z]]
  tube('Mechón lateral','Head',points,[.095,.11,.085,.045],HAIR,group='hair',sides=10)
  tube('Veta lateral','Head',[[p[0]+side*.06,p[1],p[2]-.03] for p in points],[.009]*4,RIDGE,group='hair',sides=5)
for i in range(7):
 x=-.5+i/6
 tube('Mechón posterior','Head',[[x,.52,.35],[x,.30,.57],[x,-.04,.55]],[.10,.105,.065],HAIR,group='hair',sides=10)
# Pan coordinates relative to a grip at origin; handle points up into palm, bowl down.
# axis normal -Z, elliptical dish lip and inside bottom, authored lathe.
verts=[];faces=[];rings=[(0,-.74,.0),(.39,-.74,.0),(.48,-.74,-.06),(.50,-.74,-.13),(.46,-.74,-.15),(.40,-.74,-.09),(.02,-.74,-.09)]
for radius,y,z in rings:
 for i in range(40):a=i*2*math.pi/40;verts.append([math.cos(a)*max(radius,.002),y+math.sin(a)*max(radius,.002),z])
for k in range(len(rings)-1):
 for i in range(40):a=k*40+i;b=k*40+(i+1)%40;faces.append([a,b,b+40,a+40])
add('Sartén cóncava','RightHand',verts,faces,[59,63,66],'Metal','pan')
tube('Mango sartén','RightHand',[[0,.12,0],[0,-.12,0],[0,-.32,0]],[.077,.085,.060],[31,31,30],group='pan',sides=12)
for x in [-.045,.045]:ell('Remache sartén','RightHand',[x,-.32,-.07],[.035,.035,.023],METAL,'Metal','pan',12)
# Scanner with inset screen, antenna and rubber grip, no placeholder box.
rounded('Carcasa rastreador','LeftHand',[0,0,-.08],[.44,.64,.19],[39,51,49],'Metal','tracker',.06)
rounded('Marco pantalla','LeftHand',[0,.10,-.192],[.34,.31,.035],[12,20,19],'SmoothPlastic','tracker',.02)
rounded('Cristal pantalla','LeftHand',[0,.10,-.214],[.28,.24,.014],[37,107,71],'Neon','tracker',.01)
for x in [-.09,.09]:ell('Botón rastreador','LeftHand',[x,-.18,-.19],[.065,.065,.032],[122,133,103],group='tracker',n=12)
tube('Antena rastreador','LeftHand',[[.13,.30,-.02],[.13,.55,-.02]],[.022,.014],[58,65,61],'Metal','tracker',8)
# Normalize accumulated vertices into an interchange mesh with explicit normals.
meshes=[]
for m in MESHES.values():
 verts=np.array(m['vertices']);norm=np.zeros_like(verts)
 for face in m['faces']:
  a,b,c=verts[face];n=np.cross(b-a,c-a)
  if np.linalg.norm(n)>1e-12:
   for idx in face:norm[idx]+=n
 lengths=np.linalg.norm(norm,axis=1);lengths[lengths<1e-10]=1
 m['normals']=(norm/lengths[:,None]).round(5).tolist();meshes.append(m)
data={'version':1,'reference':'Official image supplied by the user on 2026-11-08; own interpretation, not a 1:1 certified copy.','axes':'Y up, front -Z','anchors':ANCHORS,'joints':JOINTS,'meshes':meshes,'hipHeight':1.87}
(OUT/'geometry.json').write_text(json.dumps(data,separators=(',',':'))+'\n')
def lua(v):
 if v is None:return 'nil'
 if isinstance(v,bool):return 'true' if v else 'false'
 if isinstance(v,str):return json.dumps(v,ensure_ascii=False)
 if isinstance(v,(int,float)):return str(v)
 if isinstance(v,list):return '{'+','.join(lua(x) for x in v)+'}'
 return '{'+','.join('['+lua(k)+']='+lua(x) for k,x in v.items())+'}'
(ROOT/'src/shared/PelotocinoMeshData.luau').write_text('-- Authored mesh data; no uploaded IDs or Part-based surface fallback.\nreturn '+lua(data)+'\n')
print('Pelotocino:',len(meshes),'mallas;',sum(len(m['vertices']) for m in meshes),'vértices;',sum(len(m['faces']) for m in meshes),'triángulos')
