"""Single unskinned FBX: 25 named, centered meshes + baked UV/PBR textures."""
import bpy,json,hashlib
from pathlib import Path
from mathutils import Vector,Matrix
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'dist/pelotocino-importado/fuentes-3d'
D=json.loads((ROOT/'assets/pelotocino/geometry.json').read_text());manifest=json.loads((OUT/'mesh-manifest.json').read_text())
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
M=Matrix(((1,0,0),(0,0,-1),(0,1,0)))
images={key:bpy.data.images.load(str(OUT/('Pelotocino-'+name+'.png')))for key,name in [('Base Color','Color'),('Roughness','Roughness'),('Metallic','Metalness')]}
for key,img in images.items():
 if key!='Base Color':img.colorspace_settings.name='Non-Color'
material=bpy.data.materials.new('Pelotocino_Baked');material.use_nodes=True
nodes=material.node_tree.nodes;shader=nodes.get('Principled BSDF')
for key,img in images.items():
 node=nodes.new('ShaderNodeTexImage');node.image=img;material.node_tree.links.new(node.outputs['Color'],shader.inputs[key])
shader.inputs['Specular IOR Level'].default_value=.25
for spec,meta in zip(D['meshes'],manifest['meshes']):
 center=Vector(meta['center']);mesh=bpy.data.meshes.new(spec['name'])
 mesh.from_pydata([M@(Vector(v)-center)for v in spec['vertices']],[],spec['faces']);mesh.update()
 uv=mesh.uv_layers.new(name='UVMap');size=manifest['atlas_size'];cell=manifest['cell'];cols=manifest['columns']
 for i,face in enumerate(mesh.polygons):
  index=meta['first_face']+i;tx=(index%cols)*cell;ty=(index//cols)*cell
  corners=[(2,2),(cell-3,2),(2,cell-3)]
  for loop,pt in zip(face.loop_indices,corners):uv.data[loop].uv=((tx+pt[0]+.5)/size,1-(ty+pt[1]+.5)/size)
  face.use_smooth=True
 mesh.normals_split_custom_set([M@Vector(spec['normals'][loop.vertex_index])for loop in mesh.loops])
 mesh.materials.append(material);obj=bpy.data.objects.new(spec['name'],mesh);bpy.context.collection.objects.link(obj)
 obj.location=M@(Vector(D['anchors'][spec['anchor']])+center)
 obj['R15Anchor']=spec['anchor'];obj['PelotocinoOriginalGeometry']=True
bpy.ops.object.select_all(action='SELECT')
bpy.context.scene.unit_settings.system='NONE'
bpy.ops.export_scene.fbx(filepath=str(OUT/'Pelotocino-Importar.fbx'),use_selection=True,object_types={'MESH'},
 axis_forward='-Z',axis_up='Y',apply_unit_scale=True,global_scale=1,mesh_smooth_type='FACE',bake_anim=False,
 path_mode='COPY',embed_textures=True,use_custom_props=True)
for img in images.values():img.pack()
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'Pelotocino-Importar.blend'))
manifest['fbx_sha256']=hashlib.sha256((OUT/'Pelotocino-Importar.fbx').read_bytes()).hexdigest()
manifest['blend_sha256']=hashlib.sha256((OUT/'Pelotocino-Importar.blend').read_bytes()).hexdigest()
(OUT/'mesh-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print('FBX exportado con 25 mallas separadas, UV, Color/Roughness/Metalness. Studio no ejecutado.')
