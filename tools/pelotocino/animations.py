"""Bake the actual procedural Luau motion to portable animation samples."""
import sys,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from check_playable import run_lua,module
from export_preview import MOCK
out=ROOT/'assets/pelotocino/animations.json'
specs=[['idle',2.4,0],['walk',1.1,16],['run',.72,22],['sprint',.65,26],['pan',.72,0],['baconThrow',1.15,0],['detector',1.6,0],['hit',.4,0],['jump',.65,0],['fall',.65,0]]
source=MOCK+module('PelotocinoMotion.luau','Motion')+'\nlocal file=assert(io.open('+json.dumps(str(out))+',"w"))\nfile:write("{")\n'
for i,(name,duration,speed) in enumerate(specs):
 source+='file:write('+json.dumps((',' if i else '')+json.dumps(name)+':[')+')\n'
 for frame in range(round(duration*30)+1):
  t=min(duration,frame*duration/round(duration*30))
  action=name if name in ['pan','baconThrow','detector'] else ''
  state='idle' if action or (name=='hit' and t>=.22) else name
  source+=f'do local pose=Motion.sample("{state}",{t/duration*2*3.141592653589793},{speed},"{action}",{t},{{stateTime={t}}});file:write('+json.dumps((',' if frame else '')+'{"time":'+str(t)+',"pose":{')+')\n'
  source+='local first=true;for key,value in pairs(pose)do if not first then file:write(",")end;first=false;file:write(quote(key),":",json(value))end;file:write("}}")end\n'
 source+='file:write("]")\n'
source+='file:write("}\\n");file:close()'
run_lua(source,'muestras de las animaciones reales exportadas')
print(out)
