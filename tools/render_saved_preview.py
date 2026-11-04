"""Vuelve a renderizar la escena guardada sin reconstruir geometría."""
from pathlib import Path
import bpy,sys
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[1]
path=ROOT/'dist/previews'
bpy.ops.wm.open_mainfile(filepath=str(path/'Forgotten-preview.blend'))
# Ensure generated box coordinates and roughness maps in previously saved scenes.
for mat in bpy.data.materials:
 if not mat.use_nodes:continue
 nodes=mat.node_tree.nodes;links=mat.node_tree.links
 images=[n for n in nodes if n.type=='TEX_IMAGE']
 if not images:continue
 coords=nodes.new('ShaderNodeTexCoord')
 for node in images:links.new(coords.outputs['Generated'],node.inputs['Vector'])
 color=next((n for n in images if n.image and n.image.name.endswith('_color.png')),None)
 if color:
  filename=color.image.name.replace('_color.png','_roughness.png')
  rough=nodes.new('ShaderNodeTexImage');rough.image=bpy.data.images.load(str(ROOT/'assets/textures'/filename),check_existing=True);rough.image.colorspace_settings.name='Non-Color';rough.projection='BOX'
  links.new(coords.outputs['Generated'],rough.inputs['Vector']);links.new(rough.outputs['Color'],nodes.get('Principled BSDF').inputs['Roughness'])
s=bpy.context.scene;s.render.engine='CYCLES';s.cycles.use_denoising=False
s.cycles.samples=64;s.cycles.use_adaptive_sampling=True;s.cycles.adaptive_threshold=.06
s.render.resolution_percentage=100;s.view_settings.exposure=1.65
if '--check' in sys.argv:s.cycles.samples=8;s.render.resolution_percentage=40
c=s.camera
views=[('01-sala',(24,13,-29),(-4,10,13),23),('02-altillo',(5,29,-8),(0,7,19),24),('03-hogar',(3,8,9),(23,7,29),29)]
def v(p):return Vector((p[0],-p[2],p[1]))
if '--save-only' in sys.argv:
 name,location,target,lens=views[0]
 c.location=v(location);c.rotation_euler=(v(target)-c.location).to_track_quat('-Z','Y').to_euler();c.data.lens=lens
 bpy.ops.file.pack_all()
 bpy.ops.wm.save_as_mainfile(filepath=str(path/'Forgotten-preview.blend'))
 sys.exit(0)
for name,location,target,lens in views:
 c.location=v(location);c.rotation_euler=(v(target)-c.location).to_track_quat('-Z','Y').to_euler();c.data.lens=lens
 s.render.filepath=str((Path('/tmp') if '--check' in sys.argv else path)/(name+'.png'))
 bpy.ops.render.render(write_still=True)
