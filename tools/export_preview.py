"""Ejecuta el constructor mediante un adaptador geométrico Lua 5.4, sin simular Roblox."""
from pathlib import Path
import ctypes,re
ROOT=Path(__file__).resolve().parents[1]
MOCK=r'''
local nodes={}
local vmt={}
local function vec(x,y,z) return setmetatable({X=x or 0,Y=y or 0,Z=z or 0},vmt) end
vmt.__add=function(a,b)return vec(a.X+b.X,a.Y+b.Y,a.Z+b.Z)end
vmt.__sub=function(a,b)return vec(a.X-b.X,a.Y-b.Y,a.Z-b.Z)end
vmt.__div=function(a,b)return vec(a.X/b,a.Y/b,a.Z/b)end
vmt.__unm=function(a)return vec(-a.X,-a.Y,-a.Z)end
vmt.__mul=function(a,b)if type(a)=='number' then a,b=b,a end return vec(a.X*b,a.Y*b,a.Z*b)end
vmt.__index=function(a,k)
 if k=='Magnitude' then return math.sqrt(a.X*a.X+a.Y*a.Y+a.Z*a.Z) end
 if k=='Unit' then return a/math.sqrt(a.X*a.X+a.Y*a.Y+a.Z*a.Z) end
 if k=='Dot' then return function(self,b)return self.X*b.X+self.Y*b.Y+self.Z*b.Z end end
 if k=='Cross' then return function(self,b)return vec(self.Y*b.Z-self.Z*b.Y,self.Z*b.X-self.X*b.Z,self.X*b.Y-self.Y*b.X)end end
 if k=='Lerp' then return function(self,b,t)return self+(b-self)*t end end
end
Vector3={new=vec};Vector2={new=function(x,y)return {x,y}end};UDim2={fromScale=function(x,y)return {x,y}end}
UDim={new=function(a,b)return {a,b}end}
math.clamp=function(value,a,b)return math.max(a,math.min(b,value))end
local cmt={}
local function cf(p,r) return setmetatable({p=p or vec(),r=r or {1,0,0,0,1,0,0,0,1}},cmt)end
local function transform(r,p)return vec(r[1]*p.X+r[2]*p.Y+r[3]*p.Z,r[4]*p.X+r[5]*p.Y+r[6]*p.Z,r[7]*p.X+r[8]*p.Y+r[9]*p.Z)end
cmt.__mul=function(a,b)
 local r={};for i=0,2 do for j=0,2 do local n=0;for k=0,2 do n=n+a.r[i*3+k+1]*b.r[k*3+j+1] end;r[i*3+j+1]=n end end
 return cf(a.p+transform(a.r,b.p),r)
end
cmt.__index=function(a,k)
 if k=='Position' then return a.p elseif k=='Rotation' then return cf(vec(),a.r)
 elseif k=='Inverse' then return function(self)
  local r=self.r;local transposed={r[1],r[4],r[7],r[2],r[5],r[8],r[3],r[6],r[9]}
  return cf(transform(transposed,-self.p),transposed)
 end end
end
CFrame={new=function(x,y,z)if type(x)=='table' then return cf(x) end return cf(vec(x,y,z))end}
CFrame.fromMatrix=function(p,x,y,z)z=z or x:Cross(y);return cf(p,{x.X,y.X,z.X,x.Y,y.Y,z.Y,x.Z,y.Z,z.Z})end
CFrame.Angles=function(x,y,z)
 local cx,sx,cy,sy,cz,sz=math.cos(x),math.sin(x),math.cos(y),math.sin(y),math.cos(z),math.sin(z)
 return cf(nil,{1,0,0,0,cx,-sx,0,sx,cx})*cf(nil,{cy,0,sy,0,1,0,-sy,0,cy})*cf(nil,{cz,-sz,0,sz,cz,0,0,0,1})
end
CFrame.lookAt=function(a,b)
 local z=(a-b)/(a-b).Magnitude;local x=vec(z.Z,0,-z.X);x=x/x.Magnitude
 local y=vec(z.Y*x.Z-z.Z*x.Y,z.Z*x.X-z.X*x.Z,z.X*x.Y-z.Y*x.X)
 return cf(a,{x.X,y.X,z.X,x.Y,y.Y,z.Y,x.Z,y.Z,z.Z})
end
local color={};color.__index={Lerp=function(a,b,t)return setmetatable({R=a.R+(b.R-a.R)*t,G=a.G+(b.G-a.G)*t,B=a.B+(b.B-a.B)*t},color)end}
Color3={fromRGB=function(r,g,b)return setmetatable({R=r/255,G=g/255,B=b/255},color)end}
Enum=setmetatable({},{__index=function(t,k)local v=setmetatable({},{__index=function(_,n)return n end});rawset(t,k,v);return v end})
local omt={}
local function obj(class)
 local o=setmetatable({props={ClassName=class}},omt);table.insert(nodes,o);return o
end
omt.__newindex=function(o,k,v)
 if k=='Position' then o.props.CFrame=cf(v,o.props.CFrame and o.props.CFrame.r) else o.props[k]=v end
end
omt.__index=function(o,k)
 if k=='Position' then return o.props.CFrame and o.props.CFrame.p or vec() end
 if k=='FindFirstChild' then return function(self,name)for _,n in ipairs(nodes)do if n.Parent==self and n.Name==name then return n end end end end
 if k=='Destroy' then return function(self)self.Parent=nil;self.props.ClassName='Destroyed' end end
 if k=='IsA' then return function(self,class)return self.ClassName==class or (class=='BasePart' and self.ClassName=='Part') end end
 if k=='GetChildren' then return function(self)local t={};for _,n in ipairs(nodes)do if n.Parent==self then table.insert(t,n)end end;return t end end
 if k=='Triggered' then return {Connect=function()end} end
 return o.props[k]
end
Instance={new=function(class,parent)local o=obj(class);o.Parent=parent;return o end}
local function quote(s)return '"'..tostring(s):gsub('\\','\\\\'):gsub('"','\\"'):gsub('\n','\\n')..'"'end
local function json(v)
 if type(v)=='string'then return quote(v)end
 if type(v)=='number'then return tostring(v)end
 if type(v)=='table'then local t={};for _,x in ipairs(v)do table.insert(t,json(x))end;return '['..table.concat(t,',')..']'end
 return 'null'
end
local function xyz(v)return {v.X,v.Y,v.Z}end
local function rgb(c)return {c.R,c.G,c.B}end
local function dump(path)
 local f=assert(io.open(path,'w'));f:write('{"parts":[');local first=true
 for _,n in ipairs(nodes)do if n.ClassName=='Part' or n.ClassName=='SpawnLocation' then
  if not first then f:write(',')end;first=false
  local c=n.CFrame or cf();local col=n.Color or Color3.fromRGB(255,255,255)
  f:write('{"name":',quote(n.Name),',"size":',json(xyz(n.Size)),',"pos":',json(xyz(c.p)),',"rot":',json(c.r),',"color":',json(rgb(col)),',"material":',quote(n.Material or 'Plastic'),',"shape":',quote(n.Shape or 'Block'),',"alpha":',tostring(n.Transparency or 0),'}')
 end end
 f:write('],"lights":[');first=true
 for _,n in ipairs(nodes)do if n.ClassName=='PointLight' then
  if not first then f:write(',')end;first=false
  f:write('{"pos":',json(xyz(n.Parent.Position)),',"color":',json(rgb(n.Color)),',"brightness":',tostring(n.Brightness),',"range":',tostring(n.Range),'}')
 end end
 f:write('],"texts":[');first=true
 for _,n in ipairs(nodes)do if n.ClassName=='TextLabel' then
  local panel=n.Parent.Parent
  if not first then f:write(',')end;first=false
  f:write('{"text":',quote(n.Text),',"pos":',json(xyz(panel.Position)),',"size":',json(xyz(panel.Size)),',"rot":',json(panel.CFrame.r),',"face":',quote(n.Parent.Face),'}')
 end end
 f:write(']}');f:close()
end
'''
def normalize(s):
    s=re.sub(r'for (_,\w+) in (\{[^\n]+?\}) do',r'for \1 in ipairs(\2) do',s)
    return s.replace('pocket.CFrame*=CFrame.Angles(0,0,math.pi/2)','pocket.CFrame=pocket.CFrame*CFrame.Angles(0,0,math.pi/2)')
def main():
    out=ROOT/'dist/preview-scene-v4.json'
    roster=(ROOT/'src/shared/Roster.luau').read_text()
    source=normalize((ROOT/'src/shared/Lobby.luau').read_text())
    appearance=(ROOT/'src/shared/Appearance.luau').read_text()
    bootstrap='\nlocal appearances=(function()\n'+appearance+'\nend)()\nscript={Parent={Appearance=true}}\nrequire=function()return appearances end\nfor _,id in ipairs({"guest666","tubers93","pelotocino","yellowguy","junkbot","deathspeaker"}) do local specs=appearances.describe(id);local count=0;for _,v in ipairs(specs) do if v.name:find("CombatMark_") then count=count+1 end end;assert(count==((id=="guest666" or id=="tubers93") and 0 or 4),id) end\n'
    world_source=(ROOT/'src/server/World.luau').read_text()
    helpers='local World={}\nfunction World.part'+world_source.split('function World.part',1)[1].split('function World.build',1)[0]
    camp='local camp=Instance.new("Model")'+world_source.split('local camp=Instance.new("Model")',1)[1].split('local npcPositions',1)[0]
    extension=(ROOT/'src/server/Camp.luau').read_text()
    script=(MOCK+bootstrap+'\nlocal roster=(function()\n'+roster+'\nend)()\nlocal build=(function()\n'+source
        +'\nend)()\nlocal world=Instance.new("Folder")\nlocal remote={FireClient=function()end}\nbuild(world,roster,remote,{},false)\n'
        +helpers+'\n'+camp+'\nlocal Camp=(function()\n'+extension+'\nend)()\nCamp.extend(world,remote,World)\ndump('+repr(str(out))+')')
    lib=ctypes.CDLL('liblua5.4.so.0');lib.luaL_newstate.restype=ctypes.c_void_p
    lib.luaL_openlibs.argtypes=[ctypes.c_void_p];lib.luaL_loadstring.argtypes=[ctypes.c_void_p,ctypes.c_char_p]
    lib.lua_pcallk.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int,ctypes.c_int,ctypes.c_longlong,ctypes.c_void_p]
    lib.lua_tolstring.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_void_p];lib.lua_tolstring.restype=ctypes.c_char_p
    lib.lua_close.argtypes=[ctypes.c_void_p]
    state=lib.luaL_newstate();lib.luaL_openlibs(state)
    status=lib.luaL_loadstring(state,script.encode())
    if not status:status=lib.lua_pcallk(state,0,0,0,0,None)
    if status:raise RuntimeError(lib.lua_tolstring(state,-1,None).decode())
    lib.lua_close(state)
    import json
    scene=json.loads(out.read_text());assert len(scene['parts'])>1000
    print(f"{len(scene['parts'])} piezas, {len(scene['lights'])} luces exportadas desde el constructor real. No es ejecución en Roblox.")
if __name__=='__main__':main()
