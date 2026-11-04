"""Comprueba que una plantilla ausente/incompatible no modifica el avatar."""
from pathlib import Path
import ctypes
ROOT=Path(__file__).resolve().parents[1]
source=(ROOT/'src/shared/ImportedAppearance.luau').read_text()
script='local Imported=(function()\n'+source+'\nend)()\n'+r'''
Enum={HumanoidRigType={R6='R6'}}
local touched=false
Instance={new=function()touched=true;error('Mutacion antes de validar')end}
local storage={FindFirstChild=function()return nil end}
game={GetService=function()return storage end}
assert(Imported.apply({},'guest666',false)==false)
local template={GetAttribute=function(_,key)return key=='ReferenceFormat' and 1 or nil end,FindFirstChild=function()return nil end}
local templates={FindFirstChild=function()return template end}
storage.FindFirstChild=function()return templates end
local r15={FindFirstChildOfClass=function()return {RigType='R15'}end}
assert(Imported.apply(r15,'guest666',false)==false)
local incomplete={FindFirstChildOfClass=function()return {RigType='R6'}end,FindFirstChild=function()return nil end}
assert(Imported.apply(incomplete,'guest666',false)==false)
assert(not touched)
'''
l=ctypes.CDLL('liblua5.4.so.0');l.luaL_newstate.restype=ctypes.c_void_p;l.luaL_openlibs.argtypes=[ctypes.c_void_p]
l.luaL_loadstring.argtypes=[ctypes.c_void_p,ctypes.c_char_p];l.lua_pcallk.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int,ctypes.c_int,ctypes.c_longlong,ctypes.c_void_p]
l.lua_tolstring.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_void_p];l.lua_tolstring.restype=ctypes.c_char_p
state=l.luaL_newstate();l.luaL_openlibs(state);status=l.luaL_loadstring(state,script.encode())
if not status:status=l.lua_pcallk(state,0,0,0,0,None)
if status:raise RuntimeError(l.lua_tolstring(state,-1,None).decode())
print('Tres casos de fallback pasan sin modificar avatar. No prueba física ni importación en Studio.')
