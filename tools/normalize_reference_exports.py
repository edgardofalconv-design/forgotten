"""Normaliza los nombres de malla para evitar sufijos automáticos de Blender."""
from pathlib import Path
import bpy
from mathutils import Quaternion
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'dist/reference-characters'
bpy.ops.wm.open_mainfile(filepath=str(OUT/'Reference-reconstruction.blend'))
for rig in list(bpy.data.objects):
 if rig.type!='ARMATURE':continue
 id=rig.name
 if not (OUT/id).is_dir():continue
 location=rig.location.copy();pose={b.name:b.rotation_quaternion.copy() for b in rig.pose.bones}
 rig.location=(0,0,0)
 for b in rig.pose.bones:b.rotation_quaternion=Quaternion((1,0,0,0))
 children=[o for o in bpy.data.objects if o.parent==rig and o.type=='MESH']
 for o in children:
  anchor=o.vertex_groups[0].name;o.name=id+'__'+anchor+'_mesh'
 bpy.ops.object.select_all(action='DESELECT');rig.select_set(True)
 for o in children:o.select_set(True)
 bpy.context.view_layer.objects.active=rig
 bpy.ops.export_scene.fbx(filepath=str(OUT/id/(id+'.fbx')),use_selection=True,object_types={'MESH','ARMATURE'},add_leaf_bones=False,bake_anim=False,path_mode='COPY',embed_textures=True,axis_forward='-Z',axis_up='Y')
 bpy.ops.export_scene.gltf(filepath=str(OUT/id/(id+'.glb')),export_format='GLB',use_selection=True,export_animations=False)
 rig.location=location
 for name,q in pose.items():rig.pose.bones[name].rotation_quaternion=q
bpy.ops.file.pack_all();bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'Reference-reconstruction.blend'))
