from pathlib import Path
import ctypes
from export_preview import MOCK, ROOT
appearance=(ROOT/'src/shared/Appearance.luau').read_text()
roster=(ROOT/'src/shared/Roster.luau').read_text()
code=MOCK+'\nlocal A=(function()\n'+appearance+'\nend)()\nlocal roster=(function()\n'+roster+'\nend)()\n'+r'''
local world=Instance.new("Model");world.Name="CharacterInspection"
local function part(parent,name,size,pos,color)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=pos;p.Color=color;p.Material="SmoothPlastic";p.Parent=parent;return p
end
for i,e in ipairs(roster) do
 local m=Instance.new("Model");m.Name=e.name;m.Parent=world
 local x=(3.5-i)*8
 part(m,"Torso",vec(2,2.4,1.2),vec(x,3.4,0),e.color)
 part(m,"Head",vec(1.5,1.5,1.5),vec(x,5.5,0),e.color)
 for _,side in ipairs({-1,1}) do
  part(m,side<0 and "LeftLeg" or "RightLeg",vec(.9,2,1),vec(x+side*.55,1.2,0),e.color)
  local arm=part(m,side<0 and "LeftArm" or "RightArm",vec(.8,2.6,1),vec(x+side*2.3,4,0),e.color)
  arm.CFrame=arm.CFrame*CFrame.Angles(0,0,side*math.pi/2)
 end
 A.apply(m,e.id,true)
 local panel=part(world,"Nombre",vec(7,1,.1),vec(x,8.5,0),Color3.fromRGB(30,35,45))
 local g=Instance.new("SurfaceGui");g.Face="Front";g.Parent=panel
 local t=Instance.new("TextLabel");t.Text=e.name;t.Parent=g
end
part(world,"Suelo",vec(60,.2,18),vec(0,0,0),Color3.fromRGB(70,77,89))
'''+"\ndump('"+str(ROOT/'dist/character-scene.json')+"')"
l=ctypes.CDLL('liblua5.4.so.0');l.luaL_newstate.restype=ctypes.c_void_p
l.luaL_openlibs.argtypes=[ctypes.c_void_p];l.luaL_loadstring.argtypes=[ctypes.c_void_p,ctypes.c_char_p]
l.lua_pcallk.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int,ctypes.c_int,ctypes.c_longlong,ctypes.c_void_p]
l.lua_tolstring.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_void_p];l.lua_tolstring.restype=ctypes.c_char_p
s=l.luaL_newstate();l.luaL_openlibs(s);status=l.luaL_loadstring(s,code.encode())
if not status:status=l.lua_pcallk(s,0,0,0,0,None)
if status:raise RuntimeError(l.lua_tolstring(s,-1,None).decode())
print('Seis apariencias actuales exportadas en pose T.')
