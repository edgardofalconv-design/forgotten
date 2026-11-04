# Reutiliza el renderizador de la geometría real con cámaras de inspección.
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
s=(ROOT/'tools/render_preview.py').read_text()
s=s.replace("dist/preview-scene.json","dist/character-scene.json")
s=s.replace("dist/previews","dist/characters")
s=s.replace("sc.cycles.samples=48","sc.cycles.samples=32")
s=s.replace("sc.render.resolution_x=1280;sc.render.resolution_y=820","sc.render.resolution_x=1800;sc.render.resolution_y=900")
s=s.replace("sc.view_settings.exposure=1.1","sc.view_settings.exposure=1.2")
a=s.index("views=[");s=s[:a]+'''
area('Luz de estudio',(0,12,-15),(0,4,0),16000,(.85,.92,1),30)
area('Lateral',(24,12,-8),(10,4,0),5000,(1,.85,.65),15)
area('Lateral izquierda',(-24,12,-8),(-10,4,0),5000,(.75,.85,1),15)
views=[('01-seis-personajes',(0,9,-40),(0,4.5,0),50),('02-asesinos',(16,8,-28),(16,4.5,0),18),('03-supervivientes',(-8,8,-35),(-8,4.5,0),34)]
camera.data.type='ORTHO'
for name,location,target,width in views:
 camera.location=pos(location);camera.rotation_euler=(pos(target)-camera.location).to_track_quat('-Z','Y').to_euler();camera.data.ortho_scale=width
 sc.render.filepath=str(out/(name+'.png'));bpy.ops.render.render(write_still=True)
bpy.ops.wm.save_as_mainfile(filepath=str(out/'Personajes-T-pose.blend'))
'''
exec(compile(s,str(ROOT/'tools/render_preview.py'),'exec'))
