from pathlib import Path
import xml.etree.ElementTree as E
from static_preview import populate
ROOT=Path(__file__).resolve().parents[1]
root=E.Element('roblox',version='4')
n=populate(root,ROOT,ROOT/'dist/character-scene.json')
root.find('./Item/Properties/string').text='Forgotten_Inspeccion_TPose'
E.indent(root)
target=ROOT/'dist/Personajes-T-pose.rbxmx'
E.ElementTree(root).write(target,encoding='utf-8',xml_declaration=True)
assert E.parse(target).find('./Item').attrib['class']=='Model'
print(f'{target}: {n} piezas estáticas, sin scripts ni cambios en animaciones de partida.')
