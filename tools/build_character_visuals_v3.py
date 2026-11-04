"""Original low-poly accessory geometry, shared by Roblox and the preview renderer.
No third-party meshes, guessed asset IDs or AI reinterpretations are used.
"""
from pathlib import Path
import math,json
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/v3';OUT.mkdir(exist_ok=True)
MODELS={};current=[]
def sub(a,b):return [a[i]-b[i] for i in range(3)]
def add(a,b):return [a[i]+b[i] for i in range(3)]
def mul(a,n):return [x*n for x in a]
def dot(a,b):return sum(x*y for x,y in zip(a,b))
def cross(a,b):return [a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]
def unit(a):return mul(a,1/math.sqrt(dot(a,a)))
def shape(name,anchor,size,pos,color,kind='Sphere',rotation=None,material='SmoothPlastic',visibility=None,label=None):
    item=dict(name=name,anchor=anchor,size=size,position=pos,color=color,kind=kind,material=material)
    if rotation:item['rotation']=rotation
    if visibility:item['visibility']=visibility
    if label:item['label']=label
    current.append(item);return item
def mesh(name,anchor,vertices,faces,color,material='SmoothPlastic',visibility=None):
    item=dict(name=name,anchor=anchor,vertices=[[round(v,5) for v in p] for p in vertices],faces=faces,color=color,kind='Mesh',material=material)
    if visibility:item['visibility']=visibility
    current.append(item)
def line(name,anchor,points,radius,color):
    for a,b in zip(points,points[1:]):
        current.append(dict(name=name,anchor=anchor,kind='Segment',start=a,end=b,radius=radius,color=color,material='SmoothPlastic'))
def tube(name,anchor,points,radii,color,sides=5,flatten=1,material='SmoothPlastic',visibility=None):
    vertices=[]
    for i,p in enumerate(points):
        tangent=unit(sub(points[min(i+1,len(points)-1)],points[max(i-1,0)]))
        ref=[0,0,1] if abs(tangent[2])<.9 else [1,0,0]
        u=unit(cross(tangent,ref));v=cross(tangent,u)
        for n in range(sides):
            a=n*math.tau/sides
            vertices.append(add(p,add(mul(u,math.cos(a)*radii[i]),mul(v,math.sin(a)*radii[i]*flatten))))
    faces=[]
    for i in range(len(points)-1):
        for n in range(sides):
            a=i*sides+n;b=i*sides+(n+1)%sides;c=b+sides;d=a+sides
            faces.extend([[a,b,c],[a,c,d]])
    for n in range(1,sides-1):
        faces.append([0,n+1,n]);a=(len(points)-1)*sides;faces.append([a,a+n,a+n+1])
    mesh(name,anchor,vertices,faces,color,material,visibility)
BLACK=[17,20,24];WHITE=[237,235,226];HAIR=[103,53,26];GOLD=[158,136,53];STEEL=[99,108,111];PURPLE=[64,49,78];CYAN=[57,180,213]
def bacon():
    shape('Cabellera','Head',[1.55,.72,1.4],[0,.48,.08],HAIR)
    shape('Cabello posterior Bacon','Head',[1.48,.9,.57],[0,.19,.47],HAIR)
    for i in range(-3,4):
        x=i*.205;end=.43 if i==0 else .35 if abs(i)==1 else .12 if abs(i)==2 else .05
        points=[[x*.7,.5,.5],[x*.93,.76,.24],[x*1.05,.72,-.61],[x*1.08,max(.39,end+.14),-.75],[x*1.03,end,-.71]]
        tube('Mechón Bacon '+str(i),'Head',points,[.13,.18,.18,.14,.06],HAIR,sides=6,flatten=.8)
        line('Veta de cabello','Head',[[p[0]-.035,p[1]+.025,p[2]-.035] for p in points],.012,[151,81,35])
    for side in [-1,1]:
        tube('Patilla curva','Head',[[side*.55,.65,.32],[side*.71,.35,.21],[side*.67,-.15,.18]],[.16,.17,.07],HAIR,sides=4)
def cane():
    shape('Baston','RightArm',[.14,2.7,.14],[0,-1.12,-.58],[107,69,38],kind='Cylinder',rotation=[0,0,90])
    tube('Empuñadura curva','RightArm',[[0,.23,-.58],[0,.52,-.58],[-.23,.64,-.58],[-.43,.5,-.58]],[.1,.1,.1,.08],[141,98,49],sides=6)
    shape('Contera','RightArm',[.19,.17,.19],[0,-2.48,-.58],[66,66,58],kind='Sphere')
def scythe():
    shape('Asta guadaña','RightArm',[.14,4.9,.14],[0,.02,-.65],STEEL,'Cylinder',[0,0,90],'Metal')
    for y in [-.3,-.1,.1,.3]:shape('Empuñadura guadaña','RightArm',[.2,.13,.2],[0,y,-.65],BLACK,'Cylinder',[0,0,90])
    # A continuous curved blade, rather than a staircase of rectangular blocks.
    outline=[[-.02,2.49],[-.5,2.75],[-1.1,2.79],[-1.7,2.55],[-2.08,2.02],[-2.17,1.41],[-1.87,1.85],[-1.4,2.17],[-.85,2.28],[-.3,2.23]]
    outline=[[-x,y] for x,y in outline]
    center=[1,2.32];vertices=[[center[0],center[1],-.65]]+[[x,y,-.65] for x,y in outline]
    faces=[[0,i+1,(i+1)%len(outline)+1] for i in range(len(outline))]
    mesh('Hoja curva continua','RightArm',vertices,faces,[196,203,208],'Metal')
    tube('Lomo de guadaña','RightArm',[[x,y,-.65] for x,y in outline[:6]],[.1,.1,.09,.075,.045,.012],STEEL,5,material='Metal')
    for i in range(7):shape('Eslabón','RightArm',[.09,.16,.09],[.16,.3-i*.15,-.65],STEEL,'Sphere',material='Metal')
def marks():
    for name,anchor,pos,size in [
      ('CombatMark_Cicatriz','Head',[-.47,-.16,-.605],[.014,.15,.012]),
      ('CombatMark_Venda','Head',[.46,-.3,-.61],[.16,.06,.02]),
      ('CombatMark_Raspon','Torso',[-.7,-.63,-.512],[.2,.013,.012]),
      ('CombatMark_Desgaste','Torso',[-.65,-.69,-.512],[.14,.012,.012])]:
        shape(name,anchor,size,pos,[147,133,103] if 'Venda' not in name else [207,201,172],'Block',rotation=[0,0,17])
for id in ['pelotocino','yellowguy','junkbot','deathspeaker','guest666','tubers93']:
    current=[];MODELS[id]=current
    if id in ['pelotocino','guest666','tubers93']:
        for anchor,size in [('Torso',[2,2,1]),('LeftArm',[1,2,1]),('RightArm',[1,2,1]),('LeftLeg',[1,2,1]),('RightLeg',[1,2,1])]:
            tint=BLACK if id=='guest666' or anchor=='Torso' or 'Leg' in anchor else WHITE
            body=shape('Avatar '+anchor,anchor,size,[0,0,0],tint,'RoundedBlock');body['radius']=.09;body['body']=True
    if id in ['pelotocino','tubers93']:
        bacon()
        for leg in ['LeftLeg','RightLeg']:
            sole=shape('Zapatilla clásica',leg,[1.02,.3,1.2],[0,-.85,-.06],WHITE,'RoundedBlock');sole['radius']=.1
        for side in [-1,1]:
            arm='LeftArm' if side<0 else 'RightArm'
            sleeve=shape('Manga de chaqueta',arm,[1.025,1.05,1.025],[0,.48,0],BLACK,'RoundedBlock');sleeve['radius']=.06
            line('Costura de chaqueta','Torso',[[side*.72,.88,-.52],[side*.7,0,-.53],[side*.72,-.9,-.52]],.012,[65,67,65])
        if id=='pelotocino':
            backpack=shape('Mochila','Torso',[1.5,1.7,.68],[0,-.02,.79],[94,77,50],'RoundedBlock');backpack['radius']=.15
            pocket=shape('Bolsillo de mochila','Torso',[1.1,.75,.32],[0,-.35,1.12],[70,59,43],'RoundedBlock');pocket['radius']=.1
            line('Cremallera mochila','Torso',[[-.48,.02,1.29],[.48,.02,1.29]],.018,[159,149,119])
            shape('Tirador mochila','Torso',[.055,.15,.04],[.35,-.06,1.32],[159,149,119],'Block',material='Metal')
            for side in [-1,1]:tube('Correa de mochila','Torso',[[side*.66,-.86,-.54],[side*.66,.8,-.54],[side*.63,1.05,0],[side*.58,.7,.9]],[.07]*4,[108,89,56],4,flatten=.25)
            shape('Sartén','RightArm',[.9,.13,.9],[0,-.8,-1.6],[57,61,65],'Cylinder',[0,0,90],'Metal',visibility='pan')
            shape('Mango de sartén','RightArm',[.12,1.1,.12],[0,-.8,-.7],[55,40,29],'Cylinder',[0,90,0],visibility='pan')
        else:
            scythe()
            shape('Pechera triste','Torso',[1.5,.74,.04],[0,.43,-.54],[191,143,40],'Block',label='︵ ︵\n︵')
    elif id=='yellowguy':cane()
    elif id=='guest666':
        shape('Copa de gorra','Head',[1.52,.62,1.35],[0,.63,.08],[29,27,28])
        shape('Visera moldeada','Head',[1.38,.09,.87],[0,.44,-.6],[113,35,39])
        shape('Insignia gorra','Head',[.31,.29,.025],[0,.7,-.59],BLACK,'Block',label='R')
        for side in [-1,1]:shape('Banda roja','LeftArm' if side<0 else 'RightArm',[1.015,.16,1.015],[0,.45,0],[108,30,36],'Block')
    elif id=='junkbot':
        shape('Cabeza robot','Head',[1.28,1.2,1.12],[0,0,.02],GOLD)
        for side in [-1,1]:
            shape('Órbita robot','Head',[.44,.48,.13],[side*.26,.03,-.49],[38,45,37])
            shape('Visor verde','Head',[.28,.32,.09],[side*.26,.03,-.56],[66,143,75],material='Neon')
            mesh('Antena lateral','Head',[[side*.55,.25,.1],[side*.65,1.05,.23],[side*.42,.7,.15]],[[0,1,2]],GOLD,'Metal')
        mesh('Cresta dorsal','Head',[[-.1,.28,.4],[-.1,2,.6],[-.1,1.9,0],[-.1,.4,-.2],[.1,.28,.4],[.1,2,.6],[.1,1.9,0],[.1,.4,-.2]],[[0,1,2],[0,2,3],[4,6,5],[4,7,6],[1,5,6],[1,6,2],[0,4,5],[0,5,1]],GOLD,'Metal')
        for y in [.6,.8,1,1.2,1.4,1.6]:shape('Cresta verde','Head',[.23,.055,.15],[0,y,-.01],[71,111,65],'Block')
        shape('Peto robot','Torso',[1.65,1.15,1.17],[0,.42,-.16],GOLD,material='Metal')
        shape('Núcleo abdominal','Torso',[.72,1.7,.72],[0,-.15,0],[42,48,43],'Cylinder',[0,0,90],'Metal')
        shape('Cadera mecánica','Torso',[1.57,.38,.95],[0,-.98,0],[77,83,72],material='Metal')
        shape('Panel de energía','Torso',[.64,.27,.07],[0,.48,-.77],[64,130,76],'Block')
        for y in [-.3,-.5,-.7,-.9]:shape('Anillo abdominal','Torso',[1.18,.14,1.04],[0,y,0],[71,75,66],'Cylinder',[0,0,90],'Metal')
        for side in [-1,1]:
            arm='LeftArm' if side<0 else 'RightArm';leg='LeftLeg' if side<0 else 'RightLeg'
            shape('Brazo mecánico',arm,[.67,1.75,.67],[0,0,0],[63,69,65],'Cylinder',[0,0,90],'Metal')
            shape('Junta de codo',arm,[.78,.55,.78],[0,-.1,0],STEEL,material='Metal')
            shape('Hombrera robot',arm,[1.23,.62,1.2],[0,.75,0],GOLD,material='Metal')
            shape('Pistón',arm,[.22,1.05,.22],[side*.35,-.15,0],STEEL,'Cylinder',[0,0,90],'Metal')
            shape('Pinza mecánica',arm,[.67,.38,.62],[0,-1.04,0],[82,88,78],material='Metal')
            for finger in [-1,1]:shape('Dedo mecánico',arm,[.16,.34,.22],[finger*.2,-1.29,-.08],[110,116,99],'Cylinder',[0,0,90],'Metal')
            shape('Rodillera',leg,[1.04,.52,1.05],[0,.22,-.12],GOLD,material='Metal')
            shape('Pierna articulada',leg,[.74,1.8,.74],[0,0,0],[70,75,66],'Cylinder',[0,0,90],'Metal')
            shape('Placa tibial',leg,[.63,.85,.25],[0,-.35,-.42],GOLD,material='Metal')
            shape('Pie mecánico',leg,[1.1,.48,1.45],[0,-.85,-.2],[53,59,54],material='Metal')
    elif id=='deathspeaker':
        shape('Capucha','Head',[1.62,1.6,1.45],[0,.05,.2],PURPLE)
        shape('Hueco capucha','Head',[1.3,1.23,.25],[0,0,-.54],[14,23,32])
        for side in [-1,1]:
            shape('Ojo espectral','Head',[.27,.16,.06],[side*.27,.08,-.69],CYAN,rotation=[0,0,side*-14],material='Neon')
            tube('Cuerno curvo','Head',[[side*.55,.5,.1],[side*.89,.84,.09],[side*1.02,1.3,.08],[side*.87,1.72,.02]],[.21,.17,.11,.012],[35,42,48],5)
            shape('Punta espectral','Head',[.12,.24,.14],[side*.89,1.6,.02],CYAN,'Wedge',rotation=[0,0,side*20],material='Neon')
            arm='LeftArm' if side<0 else 'RightArm'
            shape('Brazo espectral',arm,[.69,1.8,.69],[0,0,0],[33,65,75],'Cylinder',[0,0,90])
            shape('Hombrera labrada',arm,[1.6,.78,1.5],[side*.04,.88,0],[146,149,173],material='Metal')
            for j in range(3):tube('Espina de armadura',arm,[[side*(-.25+j*.3),1.03,0],[side*(-.15+j*.34),1.47,.05],[side*(-.2+j*.35),1.66,.04]],[.13,.09,.005],CYAN,4)
            shape('Brazal espectral',arm,[1.09,.8,1.11],[0,-.5,0],PURPLE,material='Metal')
            shape('Mano espectral',arm,[.67,.6,.68],[0,-1.05,0],[33,65,75])
            for finger in [-1,0,1]:
                tube('Dedo espectral',arm,[[finger*.19,-1.05,-.16],[finger*.2,-1.37,-.24],[finger*.23,-1.51,-.37]],[.075,.06,.008],CYAN,4)
        shape('Coraza curva','Torso',[2.02,1.4,.7],[0,.36,-.43],[142,145,168],material='Metal')
        shape('Cuerpo bajo armadura','Torso',[1.65,1.7,1.05],[0,-.05,.02],[27,49,60])
        shape('Engaste gema','Torso',[.56,.58,.18],[0,.68,-.77],PURPLE,material='Metal')
        shape('Gema espectral','Torso',[.36,.4,.12],[0,.68,-.88],CYAN,material='Neon')
        # Authored cloth silhouette: tapered and uneven hem, not stacked rectangular blocks.
        vertices=[[-.88,-.6,-.55],[.88,-.6,-.55],[-.8,-2.75,-.55],[-.36,-2.38,-.65],[0,-3.15,-.55],[.45,-2.55,-.61],[.8,-2.8,-.55],[-.9,-.6,.5],[.9,-.6,.5],[-.7,-2.8,.45],[.7,-2.75,.45]]
        faces=[[0,1,3],[1,5,3],[0,3,2],[3,5,4],[1,6,5],[0,7,9],[0,9,2],[1,8,10],[1,10,6],[7,8,10],[7,10,9]]
        mesh('Túnica espectral','Torso',vertices,faces,[32,66,76],'Fabric')
        mesh('Tabardo','Torso',[[-.75,.3,-.86],[.75,.3,-.86],[0,-2.3,-.85]],[[0,1,2]],PURPLE,'Fabric')
        line('Borde bordado del tabardo','Torso',[[-.7,.22,-.89],[0,-2.16,-.89],[.7,.22,-.89]],.028,[129,134,155])
        for y in [-.25,-.65,-1.05]:
            width=(1.8+y)*.26
            line('Ornamento espectral','Torso',[[-width,y,-.9],[0,y-.25,-.91],[width,y,-.9]],.021,[116,121,145])
    if id not in ['guest666','tubers93']:marks()

def lua(value):
    if value is None:return 'nil'
    if isinstance(value,bool):return 'true' if value else 'false'
    if isinstance(value,str):return json.dumps(value,ensure_ascii=False)
    if isinstance(value,(int,float)):return str(value)
    if isinstance(value,list):return '{'+','.join(lua(v) for v in value)+'}'
    return '{'+','.join('['+lua(k)+']='+lua(v) for k,v in value.items())+'}'

def main():
    (OUT/'character-geometry.json').write_text(json.dumps(MODELS,ensure_ascii=False,separators=(',',':'))+'\n')
    (ROOT/'src/shared/CharacterVisualData.luau').write_text('-- Original V3 geometry; generated by tools/build_character_visuals_v3.py. No external IDs.\nreturn '+lua(MODELS)+'\n')
    for id,items in MODELS.items():
        print(id,':',len(items),'groups;',sum(len(x.get('faces',[])) for x in items),'authored triangles')
if __name__=='__main__':main()
