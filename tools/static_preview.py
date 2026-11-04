"""Escenario visible en edición; se sustituye por el constructor interactivo al jugar."""
from pathlib import Path
import json,xml.etree.ElementTree as E
MATERIALS={'Plastic':256,'SmoothPlastic':272,'Neon':288,'Wood':512,'WoodPlanks':528,'Slate':800,'Concrete':816,'Cobblestone':880,'Metal':1088,'Grass':1280,'Sand':1296,'Fabric':1312,'Ground':1360,'Glass':1568}
def populate(workspace,root,scene_path=None):
    path=scene_path or root/'dist/preview-scene.json'
    if not path.exists():return 0
    scene=json.loads(path.read_text())
    def item(parent,cls,name):
        n=E.SubElement(parent,'Item',{'class':cls});p=E.SubElement(n,'Properties');E.SubElement(p,'string',name='Name').text=name;return n,p
    def vector(props,tag,name,v):
        p=E.SubElement(props,tag,name=name)
        for k,x in zip(('X','Y','Z'),v):E.SubElement(p,k).text=str(x)
    def color(props,name,c):
        p=E.SubElement(props,'Color3',name=name)
        for k,x in zip(('R','G','B'),c):E.SubElement(p,k).text=str(x)
    def frame(props,pos,rot):
        p=E.SubElement(props,'CoordinateFrame',name='CFrame')
        for k,x in zip(('X','Y','Z'),pos):E.SubElement(p,k).text=str(x)
        for i,x in enumerate(rot):E.SubElement(p,'R'+str(i//3)+str(i%3)).text=str(x)
    model,_=item(workspace,'Model','LobbyPreview')
    for obj in scene['parts']:
        node,p=item(model,'Part',obj['name'])
        vector(p,'Vector3','size',obj['size']);frame(p,obj['pos'],obj['rot']);color(p,'Color',obj['color'])
        E.SubElement(p,'bool',name='Anchored').text='true'
        E.SubElement(p,'bool',name='CanCollide').text='false'
        E.SubElement(p,'float',name='Transparency').text=str(obj['alpha'])
        E.SubElement(p,'token',name='Material').text=str(MATERIALS.get(obj['material'],256))
        E.SubElement(p,'token',name='shape').text=str({'Ball':0,'Block':1,'Cylinder':2}.get(obj['shape'],1))
    for l in scene['lights']:
        anchor,p=item(model,'Part','PreviewLight')
        vector(p,'Vector3','size',[.1,.1,.1]);frame(p,l['pos'],[1,0,0,0,1,0,0,0,1])
        E.SubElement(p,'bool',name='Anchored').text='true';E.SubElement(p,'float',name='Transparency').text='1'
        _,p=item(anchor,'PointLight','Light');color(p,'Color',l['color'])
        E.SubElement(p,'float',name='Brightness').text=str(l['brightness']);E.SubElement(p,'float',name='Range').text=str(l['range']);E.SubElement(p,'bool',name='Shadows').text='true'
    return len(scene['parts'])
